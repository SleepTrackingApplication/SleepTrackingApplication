package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
	"net/http"
	"os"
	"strconv"
	"time"

	"backend/internal/models"
	"backend/internal/repository"
	"backend/internal/services/auth"

	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/mux"
)

type Handler struct {
	authService     auth.AuthService
	sleepPeriodRepo repository.SleepPeriodRepository
	userRepo        repository.UserRepository
}

func NewHandler(
	authService auth.AuthService,
	sleepPeriodRepo repository.SleepPeriodRepository,
	userRepo repository.UserRepository,
) *Handler {
	return &Handler{
		authService:     authService,
		sleepPeriodRepo: sleepPeriodRepo,
		userRepo:        userRepo,
	}
}

func (h *Handler) SetupRoutes(r *mux.Router) {
	r.HandleFunc("/", h.homeHandler)
	//Все запросы на бек через /api
	r.HandleFunc("/api/auth/register", h.registerHandler).Methods("POST") //р
	r.HandleFunc("/api/auth/login", h.loginHandler).Methods("POST")
	r.HandleFunc("/api/auth/logout", h.logoutHandler).Methods("POST")

	protected := r.PathPrefix("/api").Subrouter()
	//Middleware для проверки токена JWT
	protected.Use(h.authMiddleware)
	protected.HandleFunc("/auth/me", h.getMeHandler).Methods("GET")                                   // Информация о текущем пользователе
	protected.HandleFunc("/sleep/period", h.createSleepPeriodHandler).Methods("POST")                 // Создание нового перида сна для текущего пользователя
	protected.HandleFunc("/sleep/periods", h.getSleepPeriodsHandler).Methods("GET")                   //Извлекаем id из токена и возвращаем
	protected.HandleFunc("/sleep/periods/{user_id}", h.getSleepPeriodsByUserIDHandler).Methods("GET") // Получаем id в запросе, но все равно проверяем, равен ли он id из токена
	protected.HandleFunc("/leaderboard", h.getLeaderboardHandler).Methods("GET")                      //Топ
	protected.HandleFunc("/myposition", h.getMyPositionHandler).Methods("GET")                        //Позиция текущего пользователя в топе
	protected.HandleFunc("/balance/decrease", h.decreaseBalanceHandler).Methods("POST")               //Уменьшение баланса
}

// HomeHandler godoc
// @Summary Health check
// @Description Check if server is running and database is connected
// @Tags health
// @Produce plain
// @Success 200 {string} string "Server started and Database connected."
// @Router / [get]
func (h *Handler) homeHandler(w http.ResponseWriter, r *http.Request) {
	if _, err := fmt.Fprintf(w, "Server started and Database connected."); err != nil {
		log.Printf("Failed to write response: %v", err)
	}
}

// DecreaseBalanceHandler godoc
// @Summary Decrease user balance
// @Description Decrease the balance of the authenticated user by a specified amount
// @Tags balance
// @Accept json
// @Produce json
// @Param amount body DecreaseBalanceRequest true "Amount to decrease"
// @Success 200 {object} BalanceResponse
// @Failure 400 {string} string "Bad Request"
// @Failure 401 {string} string "Unauthorized"
// @Failure 500 {string} string "Internal Server Error"
// @Security BearerAuth
// @Router /api/balance/decrease [post]
func (h *Handler) decreaseBalanceHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := getUserIDFromToken(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	var input struct {
		Amount int64 `json:"amount"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if input.Amount <= 0 {
		http.Error(w, "Amount must be positive", http.StatusBadRequest)
		return
	}

	user, err := h.userRepo.FindByID(userID)
	if err != nil {
		http.Error(w, "User not found", http.StatusInternalServerError)
		return
	}

	if user.Balance < input.Amount {
		http.Error(w, "Insufficient balance", http.StatusBadRequest)
		return
	}

	user.Balance -= input.Amount
	user.UpdatedAt = time.Now()

	if err := h.userRepo.UpdateUser(user); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := struct {
		Balance int64 `json:"balance"`
	}{
		Balance: user.Balance,
	}

	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// GetMyPositionHandler godoc
// @Summary Get my position in leaderboard
// @Description Retrieve the position of the authenticated user in the leaderboard
// @Tags leaderboard
// @Produce json
// @Success 200 {object} PositionResponse
// @Failure 401 {string} string "Unauthorized"
// @Failure 500 {string} string "Internal Server Error"
// @Security BearerAuth
// @Router /api/myposition [get]
func (h *Handler) getMyPositionHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := getUserIDFromToken(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	user, err := h.userRepo.FindByID(userID)
	if err != nil {
		http.Error(w, "User not found", http.StatusInternalServerError)
		return
	}

	position, err := h.userRepo.GetPositionInLeaderboard(user)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := struct {
		Position int64 `json:"position"`
	}{
		Position: position,
	}

	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// GetLeaderboardHandler godoc
// @Summary Get leaderboard
// @Description Retrieve the top users by rating
// @Tags leaderboard
// @Produce json
// @Param limit query int false "Limit the number of results (default 10, max 100)"
// @Success 200 {array} models.User
// @Failure 400 {string} string "Bad Request"
// @Failure 500 {string} string "Internal Server Error"
// @Router /api/leaderboard [get]
func (h *Handler) getLeaderboardHandler(w http.ResponseWriter, r *http.Request) {
	limitStr := r.URL.Query().Get("limit")
	var limit int
	var err error

	if limitStr != "" {
		limit, err = strconv.Atoi(limitStr)
		if err != nil {
			http.Error(w, "Invalid limit parameter", http.StatusBadRequest)
			return
		}
		if limit <= 0 || limit > 100 {
			http.Error(w, "Limit must be between 1 and 100", http.StatusBadRequest)
			return
		}
	} else {
		limit = 10
	}

	leaderboard, err := h.userRepo.GetLeaderboard(limit)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(leaderboard); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// RegisterHandler godoc
// @Summary Register a new user
// @Description Create a new user account
// @Tags auth
// @Accept json
// @Produce json
// @Param user body RegisterRequest true "User registration data"
// @Success 201 {object} UserResponse
// @Failure 400 {string} string "Bad Request"
// @Failure 409 {string} string "Username already exists"
// @Failure 500 {string} string "Internal Server Error"
// @Router /api/auth/register [post]
func (h *Handler) registerHandler(w http.ResponseWriter, r *http.Request) {
	if h.authService == nil {
		http.Error(w, "Internal server error: auth service not initialized", http.StatusInternalServerError)
		return
	}

	var input struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	user, err := h.authService.Register(input.Username, input.Password)
	if err != nil {
		if err.Error() == "ERROR: duplicate key value violates unique constraint \"uni_users_username\" (SQLSTATE 23505)" {
			http.Error(w, "Username already exists", http.StatusConflict)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}

	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(map[string]interface{}{"id": user.ID, "username": user.Username}); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// LoginHandler godoc
// @Summary User login
// @Description Authenticate user and return JWT token
// @Tags auth
// @Accept json
// @Produce json
// @Param credentials body LoginRequest true "User credentials"
// @Success 200 {object} TokenResponse
// @Failure 400 {string} string "Bad Request"
// @Failure 401 {string} string "Unauthorized"
// @Router /api/auth/login [post]
func (h *Handler) loginHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	token, err := h.authService.Login(input.Username, input.Password)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(map[string]string{"token": token}); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// LogoutHandler godoc
// @Summary Logout user
// @Description Remove the JWT token from the client side
// @Tags auth
// @Success 200 {string} string "Logged out successfully"
// @Router /api/auth/logout [post]
func (h *Handler) logoutHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	if _, err := fmt.Fprintf(w, "Logged out successfully"); err != nil {
		log.Printf("Failed to write response: %v", err)
	}
}

// GetMeHandler godoc
// @Summary Get current user data
// @Description Retrieve data of the authenticated user
// @Tags auth
// @Produce json
// @Success 200 {object} models.User
// @Failure 401 {string} string "Unauthorized"
// @Failure 500 {string} string "Internal Server Error"
// @Security BearerAuth
// @Router /api/auth/me [get]
func (h *Handler) getMeHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := getUserIDFromToken(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	user, err := h.userRepo.FindByID(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(user); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// CreateSleepPeriodHandler godoc
// @Summary Create a new sleep period
// @Description Add a new sleep period for the authenticated user and increse user's balance and rating
// @Tags sleep
// @Accept json
// @Produce json
// @Param sleep body CreateSleepPeriodRequest true "Sleep period data"
// @Success 201 {object} models.SleepPeriod
// @Failure 400 {string} string "Bad Request"
// @Failure 401 {string} string "Unauthorized"
// @Failure 500 {string} string "Internal Server Error"
// @Security BearerAuth
// @Router /api/sleep/period [post]
func (h *Handler) createSleepPeriodHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := getUserIDFromToken(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}
	var input struct {
		StartPeriod time.Time `json:"start_period"`
		EndPeriod   time.Time `json:"end_period"`
		Duration    int64     `json:"duration"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	if input.Duration < 0 {
		http.Error(w, "Duration cannot be negative", http.StatusBadRequest)
		return
	}
	sleepPeriod := &models.SleepPeriod{
		UserID:      userID,
		StartPeriod: input.StartPeriod,
		EndPeriod:   input.EndPeriod,
		Duration:    input.Duration,
	}

	if err := h.sleepPeriodRepo.Create(sleepPeriod); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	//Increase user's balance and rating
	user, err := h.userRepo.FindByID(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	hours := math.Round(float64(input.Duration) / 60.0)
	user.Balance += int64(hours)
	user.Rating += int64(hours)
	user.UpdatedAt = time.Now()
	if err := h.userRepo.UpdateUser(user); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(sleepPeriod); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// GetSleepPeriodsHandler godoc
// @Summary Get user's sleep periods
// @Description Retrieve all sleep periods for the authenticated user
// @Tags sleep
// @Produce json
// @Success 200 {array} models.SleepPeriod
// @Failure 401 {string} string "Unauthorized"
// @Failure 500 {string} string "Internal Server Error"
// @Security BearerAuth
// @Router /api/sleep/periods [get]
func (h *Handler) getSleepPeriodsHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := getUserIDFromToken(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}
	periods, err := h.sleepPeriodRepo.GetByUserID(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(periods); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// GetSleepPeriodsByUserIDHandler godoc
// @Summary Get sleep periods by user ID
// @Description Retrieve sleep periods for a specific user (must be the authenticated user)
// @Tags sleep
// @Produce json
// @Param user_id path int true "User ID"
// @Success 200 {array} models.SleepPeriod
// @Failure 400 {string} string "Bad Request"
// @Failure 401 {string} string "Unauthorized"
// @Failure 403 {string} string "Forbidden"
// @Failure 500 {string} string "Internal Server Error"
// @Security BearerAuth
// @Router /api/sleep/periods/{user_id} [get]
func (h *Handler) getSleepPeriodsByUserIDHandler(w http.ResponseWriter, r *http.Request) {
	// Извлекаем user_id из URL
	vars := mux.Vars(r)
	userIDStr, ok := vars["user_id"]
	if !ok {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	userID, err := strconv.ParseUint(userIDStr, 10, 64)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	// Проверяем, что запрашиваемый user_id совпадает с authenticated user_id
	authUserID, err := getUserIDFromToken(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	if userID != authUserID {
		http.Error(w, "Permission denied: cannot access other users' data", http.StatusForbidden)
		return
	}

	// Получаем периоды для указанного user_id
	periods, err := h.sleepPeriodRepo.GetByUserID(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(periods); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

func getUserIDFromToken(r *http.Request) (uint64, error) {
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		return 0, fmt.Errorf("missing token")
	}

	// Убираем "Bearer " префикс если есть
	if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
		tokenString = tokenString[7:]
	}

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(os.Getenv("JWT_KEY")), nil
	})
	if err != nil || !token.Valid {
		return 0, fmt.Errorf("invalid token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return 0, fmt.Errorf("invalid token claims")
	}

	userID, ok := claims["user_id"].(float64)
	if !ok {
		return 0, fmt.Errorf("user_id not found in token")
	}
	return uint64(userID), nil
}

func (h *Handler) authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		tokenString := r.Header.Get("Authorization")
		if tokenString == "" {
			http.Error(w, "Missing token", http.StatusUnauthorized)
			return
		}

		// Убираем "Bearer " префикс если есть
		if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
			tokenString = tokenString[7:]
		}

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte(os.Getenv("JWT_KEY")), nil
		})
		if err != nil || !token.Valid {
			http.Error(w, "Invalid token", http.StatusUnauthorized)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// Request/Response models for Swagger documentation
// Request/Response models for Swagger documentation
type RegisterRequest struct {
	Username string `json:"username" example:"john_doe"`
	Password string `json:"password" example:"password123"`
}

type LoginRequest struct {
	Username string `json:"username" example:"john_doe"`
	Password string `json:"password" example:"password123"`
}

type UserResponse struct {
	ID       uint64 `json:"id" example:"1"`
	Username string `json:"username" example:"john_doe"`
}

type TokenResponse struct {
	Token string `json:"token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

type CreateSleepPeriodRequest struct {
	StartPeriod string `json:"start_period" example:"2023-12-01T22:00:00Z"`
	EndPeriod   string `json:"end_period" example:"2023-12-02T06:00:00Z"`
	Duration    int64  `json:"duration" example:"28800"`
}

type DecreaseBalanceRequest struct {
	Amount int64 `json:"amount" example:"10"`
}

type BalanceResponse struct {
	Balance int64 `json:"balance" example:"90"`
}

type PositionResponse struct {
	Position int64 `json:"position" example:"5"`
}
