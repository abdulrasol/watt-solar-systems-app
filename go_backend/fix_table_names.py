import re

file_path = "internal/models/company.go"

with open(file_path, "r") as f:
    content = f.read()

# Replace allows_b2_b with allows_b2b
content = content.replace('json:"allows_b2b"', 'gorm:"column:allows_b2b;default:true" json:"allows_b2b"')
content = content.replace('json:"allows_b2c"', 'gorm:"column:allows_b2c;default:true" json:"allows_b2c"')
# Prevent duplicate gorm tags if already exists
content = re.sub(r'gorm:"default:true" gorm:"column:allows_b2b;default:true"', 'gorm:"column:allows_b2b;default:true"', content)
content = re.sub(r'gorm:"default:true" gorm:"column:allows_b2c;default:true"', 'gorm:"column:allows_b2c;default:true"', content)


table_mapping = {
    "ServiceType": "company_servicetype",
    "CompanyType": "company_companytype",
    "CompanyCategory": "company_companycategory",
    "Company": "company_company",
    "CompanyMember": "company_companymember",
    "DeliveryOption": "company_deliveryoption",
    "Expense": "company_expense",
    "FinancialTransaction": "company_financialtransaction",
    "Contact": "company_contact",
    "CompanyService": "company_companyservice",
    "CompanyServiceCatalog": "company_companyservicecatalog",
    "CompanyServiceSubscription": "company_companyservicesubscription",
    "CompanyServiceRequest": "company_companyservicerequest",
    "CompanySubscriptionRequest": "company_companysubscriptionrequest",
    "CompanyWork": "company_companywork",
    "CompanyWorkImage": "company_companyworkimage",
    "Poster": "company_poster",
}

for struct_name, table_name in table_mapping.items():
    if f"func ({struct_name}) TableName() string" not in content:
        content += f"\nfunc ({struct_name}) TableName() string {{\n\treturn \"{table_name}\"\n}}\n"

with open(file_path, "w") as f:
    f.write(content)

print("Added TableName methods to company.go")
