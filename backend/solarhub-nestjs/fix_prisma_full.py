import re
import os

TABLE_MAP = {
    'accounting_account': 'Account',
    'accounting_journalentry': 'JournalEntry',
    'accounting_journalentryline': 'JournalEntryLine',
    'accounting_payroll': 'Payroll',
    'accounting_taxrecord': 'TaxRecord',
    'accounting_invoice': 'Invoice',
    'accounting_bill': 'Bill',
    'accounting_payment': 'Payment',

    'offers_offerrequest': 'OfferRequest',
    'offers_involvementtemplate': 'InvolvementTemplate',
    'offers_offerinvolvement': 'OfferInvolvement',
    'offers_offer': 'Offer',
    'offers_offer_involves': 'OfferInvolves',

    'shop_customer': 'Customer',
    'shop_supplier': 'Supplier',
    'shop_product': 'Product',
    'shop_productoption': 'ProductOption',
    'shop_productpricingtier': 'ProductPricingTier',
    'shop_order': 'Order',
    'shop_orderitem': 'OrderItem',
    'shop_productimage': 'ProductImage',
    'shop_product_categories': 'ProductCategories',
    'shop_product_images': 'ProductImages',

    'app_config_appconfig': 'AppConfig',
    'app_config_currency': 'Currency',
    'app_config_globalcategory': 'GlobalCategory',
    'app_config_notification': 'Notification',
    'app_config_subscriptionplan': 'SubscriptionPlan',
    'app_config_city': 'City',
    'app_config_country': 'Country',
    'app_config_feedback': 'Feedback',

    'users_profile': 'Profile',
    'users_smtpconfiguration': 'SMTPConfiguration',

    'systems_system': 'System',

    'community_post': 'Post',
    'community_comment': 'Comment',

    'notifications_notification': 'NotificationMsg',

    'company_servicetype': 'ServiceType',
    'company_companytype': 'CompanyType',
    'company_companycategory': 'CompanyCategory',
    'company_company': 'Company',
    'company_companymember': 'CompanyMember',
    'company_deliveryoption': 'DeliveryOption',
    'company_expense': 'Expense',
    'company_financialtransaction': 'FinancialTransaction',
    'company_contact': 'Contact',
    'company_companyservice': 'CompanyService',
    'company_companyservicecatalog': 'CompanyServiceCatalog',
    'company_companyservicesubscription': 'CompanyServiceSubscription',
    'company_companyservicerequest': 'CompanyServiceRequest',
    'company_companysubscriptionrequest': 'CompanySubscriptionRequest',
    'company_companywork': 'CompanyWork',
    'company_companyworkimage': 'CompanyWorkImage',
    'company_poster': 'Poster',
    'company_company_service_types': 'CompanyServiceTypes',
    'company_companytype_allowed_services': 'CompanyTypeAllowedServices',

    'auth_user': 'User',
    'auth_group': 'Group',
    'auth_permission': 'Permission',
    'auth_user_groups': 'UserGroups',
    'auth_group_permissions': 'GroupPermissions',
    'auth_user_user_permissions': 'UserPermissions',

    'django_session': 'Session',
    'django_admin_log': 'AdminLog',
    'django_content_type': 'ContentType',
    'django_migrations': 'Migrations',
    
    'authtoken_token': 'AuthToken',
    'fcm_django_fcmdevice': 'FCMDevice',
    'django_rest_passwordreset_resetpasswordtoken': 'ResetPasswordToken',
}

def fix_schema():
    # Run prisma db pull
    os.system("pnpx prisma db pull --force")
    
    with open('prisma/schema.prisma', 'r') as f:
        lines = f.readlines()
        
    new_lines = []
    current_model = None
    
    for line in lines:
        # Fix unsupported types and BigInt
        line = line.replace('Unsupported("bool")', 'Boolean')
        line = line.replace('Unsupported("integer unsigned")', 'Int')
        line = line.replace('Unsupported("smallint unsigned")', 'Int')
        
        # Replace BigInt with Int, ensuring it's a type (e.g. `BigInt?`, `BigInt`, `BigInt[]`)
        # We can just replace BigInt with Int since Prisma types are capitalized
        line = re.sub(r'\bBigInt\b', 'Int', line)
        
        model_match = re.match(r'^model\s+(\w+)\s+\{', line)
        if model_match:
            original_model = model_match.group(1)
            if original_model in TABLE_MAP:
                pascal = TABLE_MAP[original_model]
                current_model = original_model
                new_lines.append(f"model {pascal} {{\n")
            else:
                current_model = None
                new_lines.append(line)
            continue
            
        if line.strip() == '}':
            if current_model and current_model in TABLE_MAP:
                # Add @@map before closing bracket
                new_lines.append(f'  @@map("{current_model}")\n')
            new_lines.append(line)
            current_model = None
            continue
            
        # If we are inside a model, check for field definitions
        # Pattern: spaces, word (fieldName), spaces, word (fieldType), optional modifiers, rest
        field_match = re.match(r'^(\s+)(\w+)(\s+)(\w+)([\?\[\]]*)(\s*.*)$', line)
        if field_match and not line.strip().startswith('@@'):
            spaces1, field_name, spaces2, field_type, modifiers, rest = field_match.groups()
            
            # 1. Update field_type if it references a mapped model
            if field_type in TABLE_MAP:
                new_type = TABLE_MAP[field_type]
            else:
                new_type = field_type
                
            # 2. Update field_name if it is based on the old model name
            new_name = field_name
            
            # Often, prisma names relation fields exactly as the model, or appending '_1', '_2'
            # Let's sort TABLE_MAP keys by length descending to match the longest prefix
            sorted_keys = sorted(TABLE_MAP.keys(), key=len, reverse=True)
            for old_key in sorted_keys:
                if field_name.startswith(old_key):
                    pascal_base = TABLE_MAP[old_key]
                    camel_base = pascal_base[0].lower() + pascal_base[1:]
                    new_name = field_name.replace(old_key, camel_base, 1)
                    break
                    
            line = f"{spaces1}{new_name}{spaces2}{new_type}{modifiers}{rest}\n"
            
        new_lines.append(line)
        
    with open('prisma/schema.prisma', 'w') as f:
        f.writelines(new_lines)

    # Finally, run prisma format to align everything nicely
    os.system("pnpx prisma format")

if __name__ == "__main__":
    fix_schema()
