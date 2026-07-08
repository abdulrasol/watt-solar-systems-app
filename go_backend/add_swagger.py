import os
import re

mapping = {
    "RegisterCompany": ("POST", "/api/v1/companies/register", "Companies"),
    "GetCompanyTypes": ("GET", "/api/v1/companies/types", "Companies"),
    "GetServiceCatalog": ("GET", "/api/v1/companies/catalog/services", "Companies"),
    "GetSubscriptionPlans": ("GET", "/api/v1/companies/subscriptions", "Companies"),
    "GetCompanySummary": ("GET", "/api/v1/companies/{company_id}/summary", "Companies"),
    "GetCompanyWorks": ("GET", "/api/v1/companies/{company_id}/works", "Companies Works"),
    "CreateCompanyWork": ("POST", "/api/v1/companies/{company_id}/works", "Companies Works"),
    "UpdateCompanyWork": ("PUT", "/api/v1/companies/{company_id}/works/{work_id}", "Companies Works"),
    "DeleteCompanyWork": ("DELETE", "/api/v1/companies/{company_id}/works/{work_id}", "Companies Works"),
    "DeleteCompanyWorkImage": ("DELETE", "/api/v1/companies/{company_id}/works/images/{image_id}", "Companies Works"),
    "GetCompanyMembers": ("GET", "/api/v1/companies/{company_id}/members", "Companies Members"),
    "InviteMember": ("POST", "/api/v1/companies/{company_id}/members/invite", "Companies Members"),
    "CreateNewMember": ("POST", "/api/v1/companies/{company_id}/members/create", "Companies Members"),
    "RemoveMember": ("DELETE", "/api/v1/companies/{company_id}/members/{member_id}", "Companies Members"),
    "GetExpenses": ("GET", "/api/v1/companies/{company_id}/expense", "Companies Finance"),
    "CreateExpense": ("POST", "/api/v1/companies/{company_id}/expense", "Companies Finance"),
    "DeleteExpense": ("DELETE", "/api/v1/companies/{company_id}/expense/{expense_id}", "Companies Finance"),
    "GetFinancialTransactions": ("GET", "/api/v1/companies/{company_id}/finance", "Companies Finance"),
    "CreateFinancialTransaction": ("POST", "/api/v1/companies/{company_id}/finance", "Companies Finance"),
    "DeleteFinancialTransaction": ("DELETE", "/api/v1/companies/{company_id}/finance/{tx_id}", "Companies Finance"),
    "GetDeliveryOptions": ("GET", "/api/v1/companies/{company_id}/delivery", "Companies Delivery"),
    "CreateDeliveryOption": ("POST", "/api/v1/companies/{company_id}/delivery", "Companies Delivery"),
    "DeleteDeliveryOption": ("DELETE", "/api/v1/companies/{company_id}/delivery/{option_id}", "Companies Delivery"),
    "GetContacts": ("GET", "/api/v1/companies/{company_id}/contacts", "Companies Contacts"),
    "CreateContact": ("POST", "/api/v1/companies/{company_id}/contacts", "Companies Contacts"),
    "DeleteContact": ("DELETE", "/api/v1/companies/{company_id}/contacts/{contact_id}", "Companies Contacts"),
    "PublicListCompanies": ("GET", "/api/v1/public/companies/", "Public Companies API"),
    "PublicListPosters": ("GET", "/api/v1/public/companies/posters", "Public Companies API"),
    "PublicGetCompany": ("GET", "/api/v1/public/companies/{company_id}", "Public Companies API"),
    "PublicListCompanyWorks": ("GET", "/api/v1/public/companies/{company_id}/works", "Public Companies API"),
    "AdminUpdateCompanyStatus": ("POST", "/api/v1/admin/companies/{company_id}/status", "Admin Companies API"),
    "AdminReviewPoster": ("POST", "/api/v1/admin/companies/posters/{poster_id}/review", "Admin Companies API")
}

path = "internal/handlers/companies"
for filename in os.listdir(path):
    if not filename.endswith(".go"): continue
    filepath = os.path.join(path, filename)
    with open(filepath, "r") as f:
        content = f.read()

    # Remove existing Swagger comments above funcs
    content = re.sub(r"(// @.*\n)+func ", "func ", content)

    for func_name, (method, route, tag) in mapping.items():
        pattern = r"(// " + func_name + r" handles " + method + r" .*\n)(func " + func_name + r"\(c \*gin\.Context\))"
        
        swagger_comment = f"// @Summary {func_name}\n"
        swagger_comment += f"// @Description {func_name}\n"
        swagger_comment += f"// @Tags {tag}\n"
        
        for match in re.findall(r"\{([^\}]+)\}", route):
            swagger_comment += f"// @Param {match} path int true \"{match}\"\n"
            
        swagger_comment += f"// @Success 200 {{object}} response.APIResponse\n"
        swagger_comment += f"// @Router {route} [{method.lower()}]\n"
        
        replacement = r"\1" + swagger_comment + r"\2"
        content = re.sub(pattern, replacement, content)

    with open(filepath, "w") as f:
        f.write(content)

print("Swagger annotations fixed.")
