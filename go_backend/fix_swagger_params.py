import os
import re

params_mapping = {
    "RegisterCompany": """// @Accept multipart/form-data
// @Produce json
// @Param name formData string true "Name"
// @Param company_type formData int true "Company Type ID"
// @Param description formData string false "Description"
// @Param address formData string false "Address"
// @Param phone formData string false "Phone"
// @Param allows_b2b formData bool false "Allows B2B"
// @Param allows_b2c formData bool false "Allows B2C"
// @Param city formData int false "City ID"
// @Param image formData file false "Logo"
// @Security Bearer""",

    "CreateCompanyWork": """// @Accept multipart/form-data
// @Produce json
// @Param title formData string false "Title"
// @Param body formData string false "Body"
// @Param images formData file false "Images (multiple allowed)"
// @Security Bearer""",

    "UpdateCompanyWork": """// @Accept json
// @Produce json
// @Param request body models.CompanyWorkUpdateSchema true "Work details"
// @Security Bearer""",

    "DeleteCompanyWork": "// @Security Bearer",
    "DeleteCompanyWorkImage": "// @Security Bearer",

    "GetCompanyMembers": "// @Security Bearer",
    "InviteMember": """// @Accept json
// @Produce json
// @Param request body models.InviteMemberSchema true "Invite Member details"
// @Security Bearer""",

    "CreateNewMember": """// @Accept json
// @Produce json
// @Param request body models.CreateMemberSchema true "New Member details"
// @Security Bearer""",

    "RemoveMember": "// @Security Bearer",
    "GetExpenses": "// @Security Bearer",
    "CreateExpense": """// @Accept json
// @Produce json
// @Param request body models.ExpenseSchema true "Expense details"
// @Security Bearer""",
    "DeleteExpense": "// @Security Bearer",

    "GetFinancialTransactions": "// @Security Bearer",
    "CreateFinancialTransaction": """// @Accept json
// @Produce json
// @Param request body models.FinancialTransactionSchema true "Financial Transaction details"
// @Security Bearer""",
    "DeleteFinancialTransaction": "// @Security Bearer",

    "GetDeliveryOptions": "// @Security Bearer",
    "CreateDeliveryOption": """// @Accept json
// @Produce json
// @Param request body models.DeliveryOptionSchema true "Delivery Option details"
// @Security Bearer""",
    "DeleteDeliveryOption": "// @Security Bearer",

    "GetContacts": "// @Security Bearer",
    "CreateContact": """// @Accept json
// @Produce json
// @Param request body models.ContactSchema true "Contact details"
// @Security Bearer""",
    "DeleteContact": "// @Security Bearer",
    
    "AdminUpdateCompanyStatus": """// @Accept json
// @Produce json
// @Param request body models.CompanyStatusActionSchema true "Status Action"
// @Security Bearer""",
    "AdminReviewPoster": """// @Accept json
// @Produce json
// @Param request body models.PosterReviewSchema true "Review Action"
// @Security Bearer""",
    
    "GetServiceCatalog": "// @Security Bearer",
    "GetSubscriptionPlans": "// @Security Bearer",
    "GetCompanySummary": "// @Security Bearer",
    "GetCompanyWorks": "// @Security Bearer",
}

path = "internal/handlers/companies"
for filename in os.listdir(path):
    if not filename.endswith(".go"): continue
    filepath = os.path.join(path, filename)
    with open(filepath, "r") as f:
        content = f.read()

    for func_name, extra_tags in params_mapping.items():
        # find the line with // @Router
        pattern = r"(// @Summary " + func_name + r"\n.*?\n// @Router .*?\n)"
        
        if func_name in content:
            # Check if already added
            if "// @Security Bearer" not in re.search(pattern, content, flags=re.DOTALL).group(1) if re.search(pattern, content, flags=re.DOTALL) else True:
                replacement = extra_tags + "\n\\1"
                content = re.sub(pattern, replacement, content, flags=re.DOTALL)

    with open(filepath, "w") as f:
        f.write(content)

print("Swagger param and security annotations added.")
