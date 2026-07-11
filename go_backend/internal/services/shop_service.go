package services

import (
	"fmt"

	"watt/internal/database"
	"watt/internal/models"
)

// ValidateCart validates the cart and calculates pricing, tiers, options, and delivery.
func ValidateCart(req models.CartValidateRequest, buyerUserID uint) (models.CartValidateResponse, error) {
	var resp models.CartValidateResponse
	resp.Errors = make([]string, 0)

	// 1. Verify seller company
	var seller models.Company
	if err := database.DB.Preload("CompanyType").First(&seller, req.SellerCompanyID).Error; err != nil {
		return resp, fmt.Errorf("seller company not found")
	}
	if seller.Status != "active" || !seller.HasValidSubscription() {
		resp.Errors = append(resp.Errors, "seller company is inactive or subscription expired")
		return resp, nil
	}

	channel := req.OrderType
	if channel != "b2b" {
		channel = "b2c"
	}

	if channel == "b2b" && !seller.AllowsB2B {
		resp.Errors = append(resp.Errors, "seller does not allow B2B orders")
	}
	if channel == "b2c" && !seller.AllowsB2C {
		resp.Errors = append(resp.Errors, "seller does not allow B2C orders")
	}

	// 2. Verify buyer for b2b
	if channel == "b2b" {
		var member models.CompanyMember
		if err := database.DB.Where("user_id = ?", buyerUserID).Preload("Company").First(&member).Error; err != nil {
			resp.Errors = append(resp.Errors, "user is not a member of any company for b2b order")
		} else {
			if member.Role != "owner" && member.Role != "manager" {
				resp.Errors = append(resp.Errors, "user role not authorized for b2b orders")
			}
			if member.CompanyID == seller.ID {
				resp.Errors = append(resp.Errors, "cannot order from own company")
			}
		}
	}

	// 3. Calculate Items (Tiers & Options)
	var subtotal float64

	for _, item := range req.Items {
		var product models.Product
		if err := database.DB.Preload("PricingTiers").Preload("Options").First(&product, item.ProductID).Error; err != nil {
			resp.Errors = append(resp.Errors, fmt.Sprintf("product ID %d not found", item.ProductID))
			continue
		}

		if product.CompanyID == nil || *product.CompanyID != seller.ID {
			resp.Errors = append(resp.Errors, fmt.Sprintf("product ID %d does not belong to seller", item.ProductID))
			continue
		}

		if product.Status != "active" {
			resp.Errors = append(resp.Errors, fmt.Sprintf("product ID %d is inactive", item.ProductID))
			continue
		}

		if product.StockQuantity < item.Quantity {
			resp.Errors = append(resp.Errors, fmt.Sprintf("product ID %d has insufficient stock", item.ProductID))
			continue
		}

		// Determine base unit price
		unitPrice := product.RetailPrice
		if channel == "b2b" {
			unitPrice = product.WholesalePrice
		}

		// Apply pricing tiers (find the highest quantity tier that is <= item.Quantity)
		tierPrice := unitPrice
		highestTierQty := 0
		for _, tier := range product.PricingTiers {
			if item.Quantity >= tier.Quantity && tier.Quantity > highestTierQty {
				tierPrice = tier.UnitPrice
				highestTierQty = tier.Quantity
			}
		}
		if highestTierQty > 0 {
			unitPrice = tierPrice
		}

		// Add options cost
		optionsCost := 0.0
		if len(item.SelectedOptions) > 0 {
			var options []models.ProductOption
			database.DB.Where("id IN ?", item.SelectedOptions).Find(&options)
			for _, opt := range options {
				if channel == "b2b" {
					optionsCost += opt.WholesalePrice
				} else {
					optionsCost += opt.RetailPrice
				}
			}
		}

		unitPrice += optionsCost
		totalLinePrice := unitPrice * float64(item.Quantity)
		subtotal += totalLinePrice
	}

	resp.Subtotal = subtotal

	// 4. Calculate Delivery
	deliveryCost := 0.0
	if req.DeliveryOptionID != nil {
		var del models.DeliveryOption
		if err := database.DB.First(&del, *req.DeliveryOptionID).Error; err != nil {
			resp.Errors = append(resp.Errors, "delivery option not found")
		} else {
			if del.CompanyID != seller.ID {
				resp.Errors = append(resp.Errors, "delivery option does not belong to seller")
			} else if !del.IsActive {
				resp.Errors = append(resp.Errors, "delivery option is inactive")
			} else {
				deliveryCost = del.Cost
			}
		}
	}
	resp.DeliveryCost = deliveryCost

	resp.Total = resp.Subtotal + resp.DeliveryCost + resp.Tax

	return resp, nil
}
