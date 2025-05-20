package main

import (
	"bytes"
	"context"
	"crypto/ecdsa"
	"encoding/json"
	"fmt"
	"log"
	"math/big"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
)

func postRemainingTime(seconds int64) {
	postData := map[string]int64{
		"seconds": seconds,
	}

	jsonData, err := json.Marshal(postData)
	if err != nil {
		log.Printf("[POST] JSON marshal failed: %v", err)
		return
	}

	resp, err := http.Post("https://rebrtnty.baby/time", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		log.Printf("[POST] Send failed: %v", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Printf("[POST] Remote server returned status %d", resp.StatusCode)
	} else {
		log.Printf("[POST] Sent seconds=%d", seconds)
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())

	rpcURL := "https://bsc-dataseed.binance.org/"
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	privateKeyHex := os.Getenv("PRIVATE_KEY")
	if privateKeyHex == "" {
		log.Fatal("PRIVATE_KEY env var not set")
	}
	contractAddress := "0x66A533161b391FEB7D80A02E0EAC461ee3b583Ef"

	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		log.Fatalf("Failed to connect to BSC RPC: %v", err)
	}
	defer client.Close()

	privateKey, err := crypto.HexToECDSA(privateKeyHex)
	if err != nil {
		log.Fatalf("Invalid private key: %v", err)
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatalf("Cannot assert public key type")
	}
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)

	chainID := big.NewInt(56) // BSC主网chainID

	contractABI, err := abi.JSON(strings.NewReader(`[{"inputs":[{"internalType":"uint256","name":"randN","type":"uint256"}],"name":"endGame","outputs":[],"stateMutability":"nonpayable","type":"function"}]`))
	if err != nil {
		log.Fatalf("Failed to parse contract ABI: %v", err)
	}

	contractAddr := common.HexToAddress(contractAddress)

	stopChan := make(chan os.Signal, 1)
	signal.Notify(stopChan, syscall.SIGINT, syscall.SIGTERM)

	ticker := time.NewTicker(90 * time.Second)
	defer ticker.Stop()

	fmt.Println("Start calling endGame every 90 seconds...")

	// 记录上一次调用时间，用来算剩余秒数
	var lastCallTime time.Time

	for {
		select {
		case now := <-ticker.C:
			randN := big.NewInt(int64(rand.Intn(1000000)))
			fmt.Printf("Calling endGame with randN=%s\n", randN.String())

			inputData, err := contractABI.Pack("endGame", randN)
			if err != nil {
				log.Printf("Failed to pack input: %v", err)
				continue
			}

			nonce, err := client.PendingNonceAt(context.Background(), fromAddress)
			if err != nil {
				log.Printf("Failed to get nonce: %v", err)
				continue
			}

			gasLimit, err := client.EstimateGas(context.Background(), ethereum.CallMsg{
				From: fromAddress,
				To:   &contractAddr,
				Data: inputData,
			})
			if err != nil {
				log.Printf("Failed to estimate gas: %v", err)
				continue
			}
			gasLimit += 20000

			gasPrice, err := client.SuggestGasPrice(context.Background())
			if err != nil {
				log.Printf("Failed to suggest gas price: %v", err)
				continue
			}

			tx := types.NewTransaction(nonce, contractAddr, big.NewInt(0), gasLimit, gasPrice, inputData)

			signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
			if err != nil {
				log.Printf("Failed to sign tx: %v", err)
				continue
			}

			err = client.SendTransaction(context.Background(), signedTx)
			if err != nil {
				log.Printf("Failed to send tx: %v", err)
				continue
			}

			fmt.Printf("Transaction sent: %s\n", signedTx.Hash().Hex())

			receipt, err := bind.WaitMined(context.Background(), client, signedTx)
			if err != nil {
				log.Printf("Failed to wait for tx mining: %v", err)
				continue
			}
			fmt.Printf("Transaction mined in block %d\n", receipt.BlockNumber.Uint64())

			// 计算剩余秒数，假设周期固定90秒
			var remainingSeconds int64
			if lastCallTime.IsZero() {
				remainingSeconds = 90
			} else {
				elapsed := now.Sub(lastCallTime)
				remaining := 90*time.Second - elapsed
				if remaining < 0 {
					remaining = 0
				}
				remainingSeconds = int64(remaining.Seconds())
			}
			lastCallTime = now

			// POST 剩余时间到远程服务器（异步发送不阻塞）
			go postRemainingTime(remainingSeconds)

		case <-stopChan:
			fmt.Println("Exiting...")
			return
		}
	}
}
