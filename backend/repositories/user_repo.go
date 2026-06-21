package repositories

import (
	"furniflow-backend/models"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) FindByUsernameAndTenant(username string, tenantID string) (*models.User, error) {
	var user models.User
	err := r.db.Preload("Roles.Permissions").
		Where("username = ? AND tenant_id = ? AND is_active = ?", username, tenantID, true).
		First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) FindByID(id string) (*models.User, error) {
	var user models.User
	if err := r.db.Preload("Roles.Permissions").Where("id = ?", id).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetAll(tenantID string) ([]models.User, error) {
	var users []models.User
	if err := r.db.Where("tenant_id = ?", tenantID).Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}

func (r *UserRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

func (r *UserRepository) Update(user *models.User) error {
	return r.db.Save(user).Error
}

func (r *UserRepository) UpdateProfile(userID string, firstName string, lastName *string, email string, mobile *string, designation *string, department *string) error {
	return r.db.Model(&models.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"first_name":  firstName,
		"last_name":   lastName,
		"email":       email,
		"mobile":      mobile,
		"designation": designation,
		"department":  department,
	}).Error
}

func (r *UserRepository) Delete(id string, tenantID string) error {
	return r.db.Where("id = ? AND tenant_id = ?", id, tenantID).Delete(&models.User{}).Error
}
