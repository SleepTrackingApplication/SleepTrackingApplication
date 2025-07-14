package auth

import "backend/internal/models"

type AuthService interface {
	Register(username, password string) (*models.User, error)
	Login(username, password string) (string, error) // Возвращает JWT
}
