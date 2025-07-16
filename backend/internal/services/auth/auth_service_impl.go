package auth

import (
	"backend/internal/models"
	"backend/internal/repository"
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
)

type authService struct {
	userRepo repository.UserRepository
	jwtKey   []byte
}

func NewAuthService(userRepo repository.UserRepository) AuthService {
	if err := godotenv.Load(); err != nil {
		panic("Error loading .env file")
	}

	jwtKey := []byte(os.Getenv("JWT_KEY"))
	if len(jwtKey) == 0 {
		panic("JWT_KEY is not set in environment")
	}

	return &authService{
		userRepo: userRepo,
		jwtKey:   jwtKey,
	}
}

func (s *authService) Register(username, password string) (*models.User, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &models.User{
		Username: username,
		Password: string(hashedPassword),
	}
	if err := s.userRepo.Create(user); err != nil {
		return nil, err
	}
	return user, nil
}

func (s *authService) Login(username, password string) (string, error) {
	user, err := s.userRepo.FindByUsername(username)
	if err != nil {
		return "", errors.New("invalid credentials")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return "", errors.New("invalid credentials")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString(s.jwtKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}
