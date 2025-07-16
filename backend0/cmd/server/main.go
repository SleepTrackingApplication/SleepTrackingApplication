package main

import (
    "log"
    "net/http"
    "os"

    "backend/internal/handlers"
    "backend/internal/models"
    "backend/internal/repository"
    "backend/internal/services/auth"

    _ "backend/docs"

    "github.com/gorilla/mux"
    httpSwagger "github.com/swaggo/http-swagger"
    "github.com/rs/cors"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

func main() {
    dbHost := os.Getenv("DB_HOST")
    if dbHost == "" {
        dbHost = "localhost"
    }

    password := os.Getenv("POSTGRES_PASSWORD")
    if password == "" {
        password = "postgres"
    }

    dsn := "host=" + dbHost + " user=postgres password=" + password + " dbname=sleep_tracker port=5432 sslmode=disable"
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        log.Fatalf("Failed to connect to database: %v", err)
    }

    db.AutoMigrate(&models.User{}, &models.SleepPeriod{})

    userRepo := repository.NewUserRepository(db)
    sleepPeriodRepo := repository.NewSleepPeriodRepository(db)
    authService := auth.NewAuthService(userRepo)

    handler := handlers.NewHandler(authService, sleepPeriodRepo)
    r := mux.NewRouter()
    handler.SetupRoutes(r)

    r.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)

    // CORS настройка
    c := cors.New(cors.Options{
        AllowedOrigins:   []string{"*"},
        AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        AllowedHeaders:   []string{"Authorization", "Content-Type"},
        AllowCredentials: true,
    })

    handlerWithCORS := c.Handler(r)

    log.Println("Starting server on :8080")
    if err := http.ListenAndServe(":8080", handlerWithCORS); err != nil {
        log.Fatal(err)
    }
}
