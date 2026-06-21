package validators

import (
	"furniflow-backend/dtos"
)

func ValidateProductRequest(req *dtos.ProductRequest) error {
	return validate.Struct(req)
}
