package tests

import (
	"furniflow-backend/dtos"
	"furniflow-backend/validators"
	"testing"
)

func TestCustomerValidation(t *testing.T) {
	// Test Valid
	email := "test@example.com"
	validReq := dtos.CustomerRequest{
		Name: "Test Customer",
		Email: &email,
	}

	err := validators.ValidateCustomerRequest(&validReq)
	if err != nil {
		t.Errorf("Expected valid struct, got error: %v", err)
	}

	// Test Invalid (Missing required Name)
	invalidReq := dtos.CustomerRequest{
		Email: &email,
	}

	err = validators.ValidateCustomerRequest(&invalidReq)
	if err == nil {
		t.Errorf("Expected validation error for missing Name, got nil")
	}

	// Test Invalid (Bad Email)
	badEmail := "not-an-email"
	invalidEmailReq := dtos.CustomerRequest{
		Name: "Test Customer",
		Email: &badEmail,
	}

	err = validators.ValidateCustomerRequest(&invalidEmailReq)
	if err == nil {
		t.Errorf("Expected validation error for bad email, got nil")
	}
}
