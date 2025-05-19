package main

import (
	"encoding/json"
	"log"
	"net/http"
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

	// 可选：提供静态网页测试接口（如 index.html）
	r.Static("/", "./web")

	// 路由绑定
	r.POST("/orders", createOrder)
	r.GET("/orders", getOrders)
	r.GET("/orders/all", getAllOrders) // ✅ 新增：查询全部订单
	r.DELETE("/orders", deleteOrder)

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
