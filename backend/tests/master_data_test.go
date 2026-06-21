package tests

import (
	"furniflow-backend/dtos"
	"furniflow-backend/validators"
	"testing"
)

func TestMasterDataValidation(t *testing.T) {
	// Test Valid
	validReq := dtos.MasterDataRequest{
		Code: "KG",
		Name: "Kilogram",
		SortOrder: 1,
		IsActive: true,
	}

	err := validators.ValidateMasterDataRequest(&validReq)
	if err != nil {
		t.Errorf("Expected valid struct, got error: %v", err)
	}

	// Test Invalid (Missing required Code)
	invalidReq := dtos.MasterDataRequest{
		Name: "Kilogram",
	}

	err = validators.ValidateMasterDataRequest(&invalidReq)
	if err == nil {
		t.Errorf("Expected validation error for missing Code, got nil")
	}

	// Test Invalid (Code too short)
	invalidReqCode := dtos.MasterDataRequest{
		Code: "K",
		Name: "Kilogram",
	}

	err = validators.ValidateMasterDataRequest(&invalidReqCode)
	if err == nil {
		t.Errorf("Expected validation error for short Code, got nil")
	}
}
