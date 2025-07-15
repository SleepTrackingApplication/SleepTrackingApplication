package repository

import "backend/internal/models"

type UserRepository interface {
	Create(user *models.User) error
	FindByUsername(username string) (*models.User, error)
	FindByID(id uint64) (*models.User, error)
	UpdateUser(user *models.User) error
	GetLeaderboard(limit int) ([]*models.User, error)
	GetPositionInLeaderboard(*models.User) (int64, error)
}
