package validators

import (
	"furniflow-backend/dtos"
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

func ValidateMasterDataRequest(req *dtos.MasterDataRequest) error {
	return validate.Struct(req)
}
