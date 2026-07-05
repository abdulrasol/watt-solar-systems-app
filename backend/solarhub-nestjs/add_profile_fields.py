import sqlite3
import os

db_path = '../solar_hub/db.sqlite3'

if not os.path.exists(db_path):
    print(f"Error: Database not found at {db_path}")
    exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Check if columns already exist to avoid errors
cursor.execute("PRAGMA table_info(auth_user);")
columns = [info[1] for info in cursor.fetchall()]

new_columns = [
    ("language", "TEXT DEFAULT 'ar'"),
    ("phone", "TEXT"),
    ("image", "TEXT"),
    ("security_question", "TEXT"),
    ("security_answer", "TEXT"),
    ("is_deleted", "BOOLEAN DEFAULT 0"),
    ("deleted_at", "DATETIME"),
    ("deleted_reason", "TEXT"),
    ("cityId", "INTEGER")
]

added = 0
for col_name, col_type in new_columns:
    if col_name not in columns:
        try:
            cursor.execute(f"ALTER TABLE auth_user ADD COLUMN {col_name} {col_type};")
            print(f"Added column {col_name}")
            added += 1
        except Exception as e:
            print(f"Failed to add {col_name}: {e}")

conn.commit()
conn.close()

if added > 0:
    print(f"Successfully added {added} columns to auth_user.")
else:
    print("All columns already exist in auth_user.")
