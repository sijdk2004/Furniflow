package services

import (
	"errors"
	"time"

	"os"

	"furniflow-backend/dtos"
	"furniflow-backend/models"
	"furniflow-backend/repositories"

	"github.com/golang-jwt/jwt/v5"

	"golang.org/x/crypto/bcrypt"
)

var JWTSecret = []byte(getEnv("JWT_SECRET", "furniflow-super-secret-key-replace-in-prod"))

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

type AuthService struct {
	userRepo *repositories.UserRepository
}

func NewAuthService(repo *repositories.UserRepository) *AuthService {
	return &AuthService{userRepo: repo}
}

func (s *AuthService) Authenticate(req dtos.LoginRequest) (*dtos.AuthResponse, error) {
	user, err := s.userRepo.FindByUsernameAndTenant(req.Username, req.TenantID)
	if err != nil {
		return nil, errors.New("invalid credentials or inactive account")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password))
	if err != nil {
		return nil, errors.New("invalid credentials")
	}

	accessToken, err := s.generateToken(user.ID.String(), user.TenantID, 15*time.Minute, "access")
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateToken(user.ID.String(), user.TenantID, 7*24*time.Hour, "refresh")
	if err != nil {
		return nil, err
	}

	var perms []string
	for _, role := range user.Roles {
		for _, p := range role.Permissions {
			perms = append(perms, p.PermissionCode)
		}
	}
	// For POC: Ensure admin gets PLATFORM_ADMIN role
	if req.Username == "admin" {
		perms = append(perms, "PLATFORM_ADMIN")
	}

	return &dtos.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User: dtos.UserDTO{
			ID:        user.ID.String(),
			Username:  user.Username,
			FirstName: user.FirstName,
			LastName:  *user.LastName,
			TenantID:  user.TenantID,
		},
		Permissions: perms,
	}, nil
}

func (s *AuthService) generateToken(userID, tenantID string, exp time.Duration, tokenType string) (string, error) {
	claims := jwt.MapClaims{
		"user_id":   userID,
		"tenant_id": tenantID,
		"exp":       time.Now().Add(exp).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(JWTSecret)
}

func (s *AuthService) RefreshTokens(refreshTokenStr string) (*dtos.AuthResponse, error) {
	// Minimal mock implementation as requested by user
	token, err := jwt.Parse(refreshTokenStr, func(token *jwt.Token) (interface{}, error) {
		return JWTSecret, nil
	})

	if err != nil || !token.Valid {
		return nil, errors.New("invalid refresh token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, errors.New("invalid token claims")
	}

	userID := claims["user_id"].(string)
	tenantID := claims["tenant_id"].(string)

	accessToken, err := s.generateToken(userID, tenantID, 15*time.Minute, "access")
	if err != nil {
		return nil, err
	}

	newRefreshToken, err := s.generateToken(userID, tenantID, 7*24*time.Hour, "refresh")
	if err != nil {
		return nil, err
	}

	return &dtos.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		// Omit user details for refresh in this minimal implementation
	}, nil
}

func (s *AuthService) ChangePassword(userID string, currentPassword string, newPassword string) error {
	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return errors.New("user not found")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(currentPassword))
	if err != nil {
		return errors.New("incorrect current password")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return errors.New("failed to hash password")
	}

	user.PasswordHash = string(hashedPassword)
	return s.userRepo.Update(user)
}

func (s *AuthService) GetUserByID(userID string) (*models.User, error) {
	return s.userRepo.FindByID(userID)
}

func (s *AuthService) UpdateProfile(userID string, firstName string, lastName *string, email string, mobile *string, designation *string, department *string) error {
	return s.userRepo.UpdateProfile(userID, firstName, lastName, email, mobile, designation, department)
}
