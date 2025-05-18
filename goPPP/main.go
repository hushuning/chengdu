package main

import (
    "encoding/json"
    "log"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "gorm.io/driver/sqlite"
    "gorm.io/gorm"
)

// Order represents a signed limit order stored in the database.
type Order struct {
    ID          uint      `gorm:"primaryKey" json:"id"`
    UserAddress string    `json:"user_address"`
    OrderData   string    `json:"order_data"`   // raw JSON of the order
    Signature   string    `gorm:"uniqueIndex" json:"signature"`
    CreatedAt   time.Time `json:"created_at"`
}

// CreateOrderInput defines the expected payload for creating an order.
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

    // 自动迁移 Order 结构到数据库
    if err := db.AutoMigrate(&Order{}); err != nil {
        log.Fatal("failed migrate database:", err)
    }

    r := gin.Default()

    r.POST("/orders", createOrder)
    r.GET("/orders", getOrders)
    r.DELETE("/orders", deleteOrder)

    // 启动 HTTP 服务器，监听 8080 端口
    r.Run(":8080")
}

// createOrder handles POST /orders
// 接收 JSON: { user_address, order_data, signature }
// 存入数据库后返回完整的订单记录
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

// getOrders handles GET /orders?user_address={address}
// 返回该地址所有未取消的订单记录
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

// deleteOrder handles DELETE /orders?signature={signature}
// 根据签名删除对应的挂单
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
