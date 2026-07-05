import re

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

# The user made some manual renames, let's map them to original table names so we can standardize them to PascalCase
MANUAL_EDITS = {
    'users': 'users_profile',
    'offers': 'offers_offer',
    'offersinvolvement': 'offers_offerinvolvement',
    'offersrequest': 'offers_offerrequest',
    'offers_involves': 'offers_offer_involves',
}

REVERSE_MAP = {v: k for k, v in TABLE_MAP.items()}

# Add the manual edits to REVERSE_MAP so we can identify their original table
for manual, original in MANUAL_EDITS.items():
    REVERSE_MAP[manual] = original

with open('prisma/schema.prisma', 'r') as f:
    lines = f.readlines()

new_lines = []
current_model_table = None

# We need a list of ALL old names to replace in relations
# This includes original table names, and the manual edit names
ALL_OLD_NAMES = list(TABLE_MAP.keys()) + list(MANUAL_EDITS.keys()) + list(TABLE_MAP.values())
# Sort by length descending to prevent partial replacements (e.g. replacing 'User' inside 'UserGroup')
ALL_OLD_NAMES.sort(key=len, reverse=True)

def get_pascal(name):
    if name in TABLE_MAP:
        return TABLE_MAP[name]
    if name in MANUAL_EDITS:
        return TABLE_MAP[MANUAL_EDITS[name]]
    if name in REVERSE_MAP:
        return TABLE_MAP[REVERSE_MAP[name]]
    return name

for line in lines:
    model_match = re.match(r'^model\s+(\w+)\s+\{', line)
    if model_match:
        model_name = model_match.group(1)
        
        # Determine the original table name
        if model_name in TABLE_MAP:
            current_model_table = model_name
        elif model_name in REVERSE_MAP:
            current_model_table = REVERSE_MAP[model_name]
        else:
            current_model_table = model_name # Unknown model
            
        pascal_name = get_pascal(model_name)
        new_lines.append(f"model {pascal_name} {{\n")
        continue
    
    if line.strip() == '}':
        if current_model_table:
            # Check if @@map already exists
            has_map = any('@@map(' in l for l in new_lines[-5:])
            if not has_map and current_model_table != get_pascal(current_model_table):
                new_lines.append(f'  @@map("{current_model_table}")\n')
        new_lines.append(line)
        current_model_table = None
        continue
        
    if current_model_table is not None:
        # We are inside a model.
        # Let's fix relation types.
        # A field definition looks like:
        # fieldName FieldType @relation(...)
        # OR fieldName FieldType?
        # OR fieldName FieldType[]
        
        # Replace types in the line
        parts = line.split()
        if len(parts) >= 2 and not line.strip().startswith('@@'):
            field_name = parts[0]
            field_type = parts[1]
            
            # Check if field_type has a base name that we should pascal case
            base_type = field_type.replace('?', '').replace('[]', '')
            if base_type in ALL_OLD_NAMES:
                new_base_type = get_pascal(base_type)
                new_field_type = field_type.replace(base_type, new_base_type)
                
                # We should also replace the field name if it's the exact same as the base type or old type
                # For example: `app_config_globalcategory app_config_globalcategory?` -> `globalCategory GlobalCategory?`
                # Let's just make the field name camelCase of the PascalCase
                if field_name == base_type or field_name == new_base_type or field_name == base_type.lower():
                    new_field_name = new_base_type[0].lower() + new_base_type[1:]
                    line = line.replace(f"{field_name} {field_type}", f"{new_field_name} {new_field_type}")
                else:
                    line = line.replace(f" {field_type}", f" {new_field_type}")
                    
    new_lines.append(line)

with open('prisma/schema.prisma', 'w') as f:
    f.writelines(new_lines)
