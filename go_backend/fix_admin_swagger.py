import os
import re

mapping = {
    "AdminCreateCompanyType": ("POST", "/admin/companies/types", "Admin Companies API"),
    "AdminUpdateCompanyType": ("PUT", "/admin/companies/types/{id}", "Admin Companies API"),
    "AdminDeleteCompanyType": ("DELETE", "/admin/companies/types/{id}", "Admin Companies API"),
    "AdminCreateServiceType": ("POST", "/admin/companies/service-types", "Admin Companies API"),
    "AdminUpdateServiceType": ("PUT", "/admin/companies/service-types/{id}", "Admin Companies API"),
    "AdminDeleteServiceType": ("DELETE", "/admin/companies/service-types/{id}", "Admin Companies API"),
    "AdminCreateCatalogService": ("POST", "/admin/companies/catalog/services", "Admin Companies API"),
    "AdminUpdateCatalogService": ("PUT", "/admin/companies/catalog/services/{id}", "Admin Companies API"),
    "AdminDeleteCatalogService": ("DELETE", "/admin/companies/catalog/services/{id}", "Admin Companies API"),
}

filepath = "internal/handlers/companies/admin_types_api.go"
with open(filepath, "r") as f:
    content = f.read()

for func_name, (method, route, tag) in mapping.items():
    pattern = r"(// " + func_name + r" handles " + method + r" .*?\n)(func " + func_name + r"\(c \*gin\.Context\))"
    
    swagger_comment = f"// @Summary {func_name}\n"
    swagger_comment += f"// @Description {func_name}\n"
    swagger_comment += f"// @Tags {tag}\n"
    swagger_comment += f"// @Accept json\n"
    swagger_comment += f"// @Produce json\n"
    
    if method in ["POST", "PUT"]:
        swagger_comment += f"// @Param request body object true \"Payload\"\n"
        
    for match in re.findall(r"\{([^\}]+)\}", route):
        swagger_comment += f"// @Param {match} path int true \"{match}\"\n"
        
    swagger_comment += f"// @Security Bearer\n"
    swagger_comment += f"// @Success 200 {{object}} response.APIResponse\n"
    swagger_comment += f"// @Router {route} [{method.lower()}]\n"
    
    replacement = r"\1" + swagger_comment + r"\2"
    content = re.sub(pattern, replacement, content)

with open(filepath, "w") as f:
    f.write(content)

print("Swagger admin types fixed.")
