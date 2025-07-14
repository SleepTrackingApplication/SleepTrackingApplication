package repository

import "backend/internal/models"

type UserRepository interface {
	Create(user *models.User) error
	FindByUsername(username string) (*models.User, error)
	FindByID(id uint64) (*models.User, error)
}
