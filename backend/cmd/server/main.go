package main

import (
	"log"
	"net/http"
	"os"

	"backend/internal/handlers"
	"backend/internal/models"
	"backend/internal/repository"
	"backend/internal/services/auth"

	"github.com/gorilla/mux"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	// Настройка базы данных
	dsn := "host=db user=postgres password=" + os.Getenv("POSTGRES_PASSWORD") + " dbname=sleep_tracker port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Автомиграция моделей
	db.AutoMigrate(&models.User{}, &models.SleepPeriod{})

	// Инициализация репозиториев и сервисов
	userRepo := repository.NewUserRepository(db)
	sleepPeriodRepo := repository.NewSleepPeriodRepository(db)
	authService := auth.NewAuthService(userRepo)

	// Инициализация хендлера и настройка роутов
	handler := handlers.NewHandler(authService, sleepPeriodRepo)
	r := mux.NewRouter()
	handler.SetupRoutes(r)

	// Запуск сервера
	log.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal(err)
	}
}
