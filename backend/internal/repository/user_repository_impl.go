package repository

import (
	"backend/internal/models"

	"gorm.io/gorm"
)

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

func (r *userRepository) FindByUsername(username string) (*models.User, error) {
	var user models.User
	err := r.db.Where("username = ?", username).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) FindByID(id uint64) (*models.User, error) {
	var user models.User
	err := r.db.First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}
func (r *userRepository) UpdateUser(user *models.User) error {
	return r.db.Model(user).Updates(map[string]interface{}{
		"rating":     user.Rating,
		"balance":    user.Balance,
		"updated_at": user.UpdatedAt,
	}).Error
}

func (r *userRepository) GetLeaderboard(limit int) ([]*models.User, error) {
	var users []*models.User
	err := r.db.Select("username, rating").Order("rating DESC").Limit(limit).Find(&users).Error
	if err != nil {
		return nil, err
	}
	return users, nil
}
func (r *userRepository) GetPositionInLeaderboard(user *models.User) (int64, error) {
	var count int64
	err := r.db.Model(&models.User{}).Where("rating > ?", user.Rating).Count(&count).Error
	if err != nil {
		return 0, err
	}
	return count + 1, nil
}
