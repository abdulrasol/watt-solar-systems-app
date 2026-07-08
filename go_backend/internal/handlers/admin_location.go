package handlers

import (
	"net/http"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"

	"github.com/gin-gonic/gin"
)

// GetCountries godoc
// @Summary      Get all countries
// @Description  Retrieves all countries
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  response.APIResponse{body=[]models.CountryOut}
// @Router       /admin/countries [get]
func (h *AdminHandler) GetCountries(c *gin.Context) {
	var countries []models.Country
	database.DB.Find(&countries)

	var result []models.CountryOut
	for _, country := range countries {
		result = append(result, models.CountryOut{
			ID:        country.ID,
			Name:      country.Name,
			Code:      country.Code,
			CreatedAt: country.CreatedAt.Format("2006-01-02T15:04:05Z"),
		})
	}

	c.JSON(http.StatusOK, result)
}

// CreateCountry godoc
// @Summary      Create a country
// @Description  Creates a new country
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        country body models.CountryOut true "Country data"
// @Success      200  {object}  response.APIResponse{body=models.CountryOut}
// @Router       /admin/countries [post]
func (h *AdminHandler) CreateCountry(c *gin.Context) {
	var req models.CountryOut
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	country := models.Country{
		Name: req.Name,
		Code: req.Code,
	}

	database.DB.Create(&country)

	response.Success(c, http.StatusOK, "Country created successfully.", models.CountryOut{
		ID:        country.ID,
		Name:      country.Name,
		Code:      country.Code,
		CreatedAt: country.CreatedAt.Format("2006-01-02T15:04:05Z"),
	})
}

// UpdateCountry godoc
// @Summary      Update a country
// @Description  Updates an existing country by ID
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        id path string true "Country ID"
// @Param        country body models.CountryOut true "Country update data"
// @Success      200  {object}  response.APIResponse{body=models.CountryOut}
// @Router       /admin/countries/{id} [put]
func (h *AdminHandler) UpdateCountry(c *gin.Context) {
	id := c.Param("id")
	var req models.CountryOut
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var country models.Country
	if err := database.DB.First(&country, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Country not found.", nil)
		return
	}

	country.Name = req.Name
	country.Code = req.Code
	database.DB.Save(&country)

	response.Success(c, http.StatusOK, "Country updated successfully.", models.CountryOut{
		ID:        country.ID,
		Name:      country.Name,
		Code:      country.Code,
		CreatedAt: country.CreatedAt.Format("2006-01-02T15:04:05Z"),
	})
}

// DeleteCountry godoc
// @Summary      Delete a country
// @Description  Deletes an existing country by ID
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Param        id path string true "Country ID"
// @Success      200  {object}  response.APIResponse
// @Router       /admin/countries/{id} [delete]
func (h *AdminHandler) DeleteCountry(c *gin.Context) {
	id := c.Param("id")

	var country models.Country
	if err := database.DB.First(&country, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Country not found.", nil)
		return
	}

	database.DB.Delete(&country)
	response.Success(c, http.StatusOK, "Country deleted successfully.", gin.H{})
}

// GetCities godoc
// @Summary      Get all cities
// @Description  Retrieves all cities, optionally filtered by country_id
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Param        country_id query int false "Filter by Country ID"
// @Success      200  {object}  response.APIResponse{body=[]models.CityOut}
// @Router       /admin/cities [get]
func (h *AdminHandler) GetCities(c *gin.Context) {
	countryID := c.Query("country_id")

	var cities []models.City
	query := database.DB.Preload("Country")
	if countryID != "" {
		query = query.Where("country_id = ?", countryID)
	}
	query.Find(&cities)

	var result []models.CityOut
	for _, city := range cities {
		result = append(result, models.CityOut{
			ID:   city.ID,
			Name: city.Name,
			Country: models.CountryOut{
				ID:        city.Country.ID,
				Name:      city.Country.Name,
				Code:      city.Country.Code,
				CreatedAt: city.Country.CreatedAt.Format("2006-01-02T15:04:05Z"),
			},
			Code:      city.Code,
			CreatedAt: city.CreatedAt.Format("2006-01-02T15:04:05Z"),
		})
	}

	c.JSON(http.StatusOK, result)
}

// CreateCity godoc
// @Summary      Create a city
// @Description  Creates a new city
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        city body models.CitySchema true "City data"
// @Success      200  {object}  response.APIResponse{body=models.CityOut}
// @Router       /admin/cities [post]
func (h *AdminHandler) CreateCity(c *gin.Context) {
	var req models.CitySchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var country models.Country
	if err := database.DB.First(&country, req.CountryID).Error; err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid country ID.", nil)
		return
	}

	city := models.City{
		Name:      req.Name,
		CountryID: req.CountryID,
		Code:      req.Code,
	}

	database.DB.Create(&city)
	database.DB.Preload("Country").First(&city, city.ID) // Load country for response

	response.Success(c, http.StatusOK, "City created successfully.", models.CityOut{
		ID:   city.ID,
		Name: city.Name,
		Country: models.CountryOut{
			ID:        city.Country.ID,
			Name:      city.Country.Name,
			Code:      city.Country.Code,
			CreatedAt: city.Country.CreatedAt.Format("2006-01-02T15:04:05Z"),
		},
		Code:      city.Code,
		CreatedAt: city.CreatedAt.Format("2006-01-02T15:04:05Z"),
	})
}

// UpdateCity godoc
// @Summary      Update a city
// @Description  Updates an existing city by ID
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        id path string true "City ID"
// @Param        city body models.CityUpdateSchema true "City update data"
// @Success      200  {object}  response.APIResponse{body=models.CityOut}
// @Router       /api/admin/cities/{id} [put]
func (h *AdminHandler) UpdateCity(c *gin.Context) {
	id := c.Param("id")
	var req models.CityUpdateSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var city models.City
	if err := database.DB.Preload("Country").First(&city, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "City not found.", nil)
		return
	}

	if req.Name != nil {
		city.Name = *req.Name
	}
	if req.CountryID != nil {
		var country models.Country
		if err := database.DB.First(&country, *req.CountryID).Error; err != nil {
			response.Error(c, http.StatusBadRequest, "Invalid country ID.", nil)
			return
		}
		city.CountryID = *req.CountryID
	}
	if req.Code != nil {
		city.Code = *req.Code
	}

	database.DB.Save(&city)
	database.DB.Preload("Country").First(&city, city.ID)

	response.Success(c, http.StatusOK, "City updated successfully.", models.CityOut{
		ID:   city.ID,
		Name: city.Name,
		Country: models.CountryOut{
			ID:        city.Country.ID,
			Name:      city.Country.Name,
			Code:      city.Country.Code,
			CreatedAt: city.Country.CreatedAt.Format("2006-01-02T15:04:05Z"),
		},
		Code:      city.Code,
		CreatedAt: city.CreatedAt.Format("2006-01-02T15:04:05Z"),
	})
}

// DeleteCity godoc
// @Summary      Delete a city
// @Description  Deletes an existing city by ID
// @Tags         Admin API
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "City ID"
// @Success      200  {object}  response.APIResponse
// @Router       /api/admin/cities/{id} [delete]
func (h *AdminHandler) DeleteCity(c *gin.Context) {
	id := c.Param("id")

	var city models.City
	if err := database.DB.First(&city, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "City not found.", nil)
		return
	}

	database.DB.Delete(&city)
	response.Success(c, http.StatusOK, "City deleted successfully.", gin.H{})
}
