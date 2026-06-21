package tests

import (
	"furniflow-backend/dtos"
	"furniflow-backend/validators"
	"testing"
)

func TestProductValidation(t *testing.T) {
	validReq := dtos.ProductRequest{
		ProductCode: "P-123",
		ProductName: "Test Product",
		BasePrice:   15.5,
	}

	err := validators.ValidateProductRequest(&validReq)
	if err != nil {
		t.Errorf("Expected valid struct, got error: %v", err)
	}

	invalidReq := dtos.ProductRequest{
		ProductCode: "P-123",
		BasePrice:   -10, // Invalid negative price
	}

	err = validators.ValidateProductRequest(&invalidReq)
	if err == nil {
		t.Errorf("Expected validation error for missing Name and negative price, got nil")
	}
}
