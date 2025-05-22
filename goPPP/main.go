package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// Order 模型定义
type Order struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	UserAddress string    `json:"user_address"`
	OrderData   string    `json:"order_data"`
	Signature   string    `gorm:"uniqueIndex" json:"signature"`
	CreatedAt   time.Time `json:"created_at"`
}

// CreateOrderInput 用于创建订单的请求体
type CreateOrderInput struct {
	UserAddress string          `json:"user_address" binding:"required"`
	OrderData   json.RawMessage `json:"order_data" binding:"required"`
	Signature   string          `json:"signature" binding:"required"`
}

var db *gorm.DB

// 计时器相关变量
var (
	mu           sync.Mutex
	deadlineTime time.Time
)

type TimeInput struct {
	Seconds int64 `json:"seconds" binding:"required,gt=0"`
}

// 设置倒计时
func setTime(c *gin.Context) {
	var input TimeInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	mu.Lock()
	deadlineTime = time.Now().Add(time.Duration(input.Seconds) * time.Second)
	mu.Unlock()

	c.JSON(http.StatusOK, gin.H{"message": "deadline set", "deadline": deadlineTime.Format(time.RFC3339)})
}

// 获取剩余时间
func getRemainingTime(c *gin.Context) {
	mu.Lock()
	defer mu.Unlock()

	now := time.Now()
	if deadlineTime.IsZero() || now.After(deadlineTime) {
		c.JSON(http.StatusOK, gin.H{"remaining_seconds": 0})
		return
	}

	remaining := int64(deadlineTime.Sub(now).Seconds())
	c.JSON(http.StatusOK, gin.H{"remaining_seconds": remaining})
}

func main() {
	var err error
	db, err = gorm.Open(sqlite.Open("orders.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("failed to connect database:", err)
	}

	if err := db.AutoMigrate(&Order{}); err != nil {
		log.Fatal("failed migrate database:", err)
	}

	r := gin.Default()

	// 允许跨域请求（CORS）
	r.Use(cors.Default())

	// 静态文件（可选）
	r.Static("/static", "./web")

	// 订单路由
	r.POST("/orders", createOrder)
	r.GET("/orders", getOrders)
	r.GET("/orders/all", getAllOrders)
	// 删除订单，使用路径参数 :id
	r.DELETE("/orders/:id", deleteOrder)

	// 倒计时路由
	r.POST("/time", setTime)
	r.GET("/time", getRemainingTime)

	r.Run(":8080")
}

// 创建订单处理
func createOrder(c *gin.Context) {
	var input CreateOrderInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	order := Order{
		UserAddress: input.UserAddress,
		OrderData:   string(input.OrderData),
		Signature:   input.Signature,
		CreatedAt:   time.Now(),
	}
	if err := db.Create(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, order)
}

// 获取指定用户的订单
func getOrders(c *gin.Context) {
	userAddress := c.Query("user_address")
	if userAddress == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_address query parameter required"})
		return
	}

	var orders []Order
	if err := db.Where("user_address = ?", userAddress).Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, orders)
}

// 获取所有订单
func getAllOrders(c *gin.Context) {
	var orders []Order
	if err := db.Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, orders)
}

// 删除订单处理，使用路径参数 :id
func deleteOrder(c *gin.Context) {
	idStr := c.Param("id")
	if idStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "id path parameter required"})
		return
	}

	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	if err := db.Delete(&Order{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "order deleted", "id": id})
}
