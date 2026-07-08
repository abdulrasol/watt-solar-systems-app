import os
import re

schema_content = """
type AdminCompanyTypeCreateSchema struct {
	CType string `json:"ctype" binding:"required"`
	Name  string `json:"name" binding:"required"`
}

type AdminCompanyTypeUpdateSchema struct {
	CType string `json:"ctype"`
	Name  string `json:"name"`
}
"""

with open("internal/models/company_schemas.go", "a") as f:
    f.write(schema_content)

mapping = {
    "AdminCreateCompanyType": "models.AdminCompanyTypeCreateSchema",
    "AdminUpdateCompanyType": "models.AdminCompanyTypeUpdateSchema",
    "AdminCreateServiceType": "models.ServiceTypeCreateSchema",
    "AdminUpdateServiceType": "models.ServiceTypeUpdateSchema",
    "AdminCreateCatalogService": "models.CompanyServiceCatalogCreateSchema",
    "AdminUpdateCatalogService": "models.CompanyServiceCatalogUpdateSchema",
}

filepath = "internal/handlers/companies/admin_types_api.go"
with open(filepath, "r") as f:
    content = f.read()

for func_name, schema in mapping.items():
    # Replace the swagger annotation // @Param request body object true "Payload" with the proper schema
    content = re.sub(
        r"(// @Summary " + func_name + r".*?)(// @Param request body object true \"Payload\")",
        r"\1// @Param request body " + schema + r" true \"Payload\"",
        content,
        flags=re.DOTALL
    )

    if func_name == "AdminCreateCompanyType":
        content = re.sub(r"var payload struct \{[^}]+\}", f"var payload {schema}", content)
    elif func_name == "AdminUpdateCompanyType":
        content = re.sub(r"var payload struct \{[^}]+\}", f"var payload {schema}", content)
    elif func_name == "AdminCreateServiceType":
        content = re.sub(r"var payload struct \{[^}]+\}", f"var payload {schema}", content)
    elif func_name == "AdminUpdateServiceType":
        content = re.sub(r"var payload struct \{[^}]+\}", f"var payload {schema}", content)

with open(filepath, "w") as f:
    f.write(content)

print("Swagger fixed with exact schemas.")
