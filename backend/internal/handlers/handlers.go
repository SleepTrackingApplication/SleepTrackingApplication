package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"

	"backend/internal/models"
	"backend/internal/repository"
	"backend/internal/services/auth"

	"github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
)

type Handler struct {
	authService     auth.AuthService
	sleepPeriodRepo repository.SleepPeriodRepository
}

func NewHandler(authService auth.AuthService, sleepPeriodRepo repository.SleepPeriodRepository) *Handler {
	return &Handler{
		authService:     authService,
		sleepPeriodRepo: sleepPeriodRepo,
	}
}

func (h *Handler) SetupRoutes(r *mux.Router) {
	r.HandleFunc("/", h.homeHandler)
	r.HandleFunc("/auth/register", h.registerHandler).Methods("POST")
	r.HandleFunc("/auth/login", h.loginHandler).Methods("POST")

	protected := r.PathPrefix("/sleep").Subrouter()
	protected.Use(h.authMiddleware)
	protected.HandleFunc("/period", h.createSleepPeriodHandler).Methods("POST")
	protected.HandleFunc("/periods", h.getSleepPeriodsHandler).Methods("GET")
	protected.HandleFunc("/periods/{user_id}", h.getSleepPeriodsByUserIDHandler).Methods("GET")
}

func (h *Handler) homeHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, Sleep Tracker Backend! Database connected.")
}

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
	json.NewEncoder(w).Encode(map[string]interface{}{"id": user.ID, "username": user.Username})
}

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
	json.NewEncoder(w).Encode(map[string]string{"token": token})
}

func (h *Handler) createSleepPeriodHandler(w http.ResponseWriter, r *http.Request) {
	userID, err := getUserIDFromToken(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}
	var input struct {
		StartPeriod time.Time `json:"start_period"`
		EndPeriod   time.Time `json:"end_period"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	sleepPeriod := &models.SleepPeriod{
		UserID:      userID,
		StartPeriod: input.StartPeriod,
		EndPeriod:   input.EndPeriod,
	}
	if err := h.sleepPeriodRepo.Create(sleepPeriod); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(sleepPeriod)
}

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
	json.NewEncoder(w).Encode(periods)
}

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
	json.NewEncoder(w).Encode(periods)
}

func getUserIDFromToken(r *http.Request) (uint64, error) {
	tokenString := r.Header.Get("Authorization")
	if tokenString == "" {
		return 0, fmt.Errorf("missing token")
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
