package main

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type Order struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	UserAddress string    `json:"user_address"`
	OrderData   string    `json:"order_data"`
	Signature   string    `gorm:"uniqueIndex" json:"signature"`
	CreatedAt   time.Time `json:"created_at"`
}

type CreateOrderInput struct {
	UserAddress string          `json:"user_address" binding:"required"`
	OrderData   json.RawMessage `json:"order_data" binding:"required"`
	Signature   string          `json:"signature" binding:"required"`
}

var db *gorm.DB

// 计时器相关
var (
	mu           sync.Mutex
	deadlineTime time.Time
)

type TimeInput struct {
	Seconds int64 `json:"seconds" binding:"required,gt=0"`
}

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

	// 静态网页接口
	r.Static("/static", "./web")

	// 订单路由
	r.POST("/orders", createOrder)
	r.GET("/orders", getOrders)
	r.GET("/orders/all", getAllOrders)
	r.DELETE("/orders", deleteOrder)

	// 新增倒计时相关路由
	r.POST("/time", setTime)
	r.GET("/time", getRemainingTime)

	r.Run(":8080")
}

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

func getAllOrders(c *gin.Context) {
	var orders []Order
	if err := db.Find(&orders).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, orders)
}

func deleteOrder(c *gin.Context) {
	signature := c.Query("signature")
	if signature == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "signature query parameter required"})
		return
	}

	if err := db.Where("signature = ?", signature).Delete(&Order{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"deleted_signature": signature})
}
