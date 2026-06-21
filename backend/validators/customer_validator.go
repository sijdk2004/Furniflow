package validators

import (
	"furniflow-backend/dtos"
)

func ValidateCustomerRequest(req *dtos.CustomerRequest) error {
	return validate.Struct(req)
}
