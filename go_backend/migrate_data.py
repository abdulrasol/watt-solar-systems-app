import sqlite3
import os

db_path = "solarhub_go.sqlite3"

# Connect to the DB
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

try:
    print("Migrating company_company to companies...")
    cursor.execute("""
        INSERT OR REPLACE INTO companies (id, name, description, logo, address, status, allows_b2_b, allows_b2_c, created_at, updated_at, expire_date, currency_id, city_id, subscription_plan_id, subscription_start_date, company_type_id, phone, last_activation_reminder_at)
        SELECT id, name, description, logo, address, status, allows_b2b, allows_b2c, created_at, updated_at, expire_date, currency_id, city_id, subscription_plan_id, subscription_start_date, company_type_id, phone, last_activation_reminder_at
        FROM company_company
    """)
    
    print("Migrating company_companymember to company_members...")
    cursor.execute("""
        INSERT OR REPLACE INTO company_members (id, company_id, user_id, role, permissions, joined_at)
        SELECT id, company_id, user_id, role, '{}', joined_at
        FROM company_companymember
    """)

    conn.commit()
    print("Data migration completed successfully!")
except Exception as e:
    print("Error during migration:", e)
finally:
    conn.close()
