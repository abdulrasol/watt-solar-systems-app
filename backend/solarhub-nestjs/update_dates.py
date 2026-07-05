import sqlite3

db_path = "/Users/rasol/DevsTools/codes/python/solarhub/solar_hub/db.sqlite3"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = cursor.fetchall()

for table in tables:
    table_name = table[0]
    cursor.execute(f"PRAGMA table_info({table_name});")
    columns = cursor.fetchall()
    
    for col in columns:
        col_name = col[1]
        col_type = col[2].lower()
        
        if 'datetime' in col_type or 'date' in col_type:
            query = f"""
                UPDATE {table_name} 
                SET {col_name} = replace({col_name}, ' ', 'T') || 'Z'
                WHERE {col_name} LIKE '% %' AND {col_name} NOT LIKE '%Z';
            """
            try:
                cursor.execute(query)
            except sqlite3.Error as e:
                print(f"Error on {table_name}.{col_name}: {e}")

conn.commit()
conn.close()
print("Dates updated.")
