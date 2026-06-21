package dtos

// LoginRequest defines the expected payload for authentication
type LoginRequest struct {
	Username string `json:"username" validate:"required"`
	Password string `json:"password" validate:"required"`
	TenantID string `json:"tenant_id" validate:"required"`
}

// AuthResponse defines the standard success response for login
type AuthResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	User         UserDTO `json:"user"`
	Permissions  []string `json:"permissions"`
}

// RefreshRequest defines payload for token refresh
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

// UserDTO defines the user payload
type UserDTO struct {
	ID        string `json:"id"`
	Username  string `json:"username"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	TenantID  string `json:"tenant_id"`
}
