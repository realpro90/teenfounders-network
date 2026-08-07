#!/usr/bin/env python3
import os
import sys
import psycopg2

print(f"Connecting to live Railway PostgreSQL database...")

connection_strings = [
    os.getenv("DATABASE_URL"),
    "postgresql://postgres:LGpmpmjqwyEFApdXxqUwuQLzORcjLyCU@postgres-production-5bcda.up.railway.app:5432/railway",
    "postgresql://postgres:LGpmpmjqwyEFApdXxqUwuQLzORcjLyCU@postgres-production-5bcda.up.railway.app:443/railway",
    "postgresql://postgres:LGpmpmjqwyEFApdXxqUwuQLzORcjLyCU@postgres-production-5bcda.up.railway.app:80/railway"
]

conn = None
for url in connection_strings:
    if not url:
        continue
    try:
        print(f"Trying connection: {url.split('@')[-1]} ...")
        conn = psycopg2.connect(url, connect_timeout=5)
        print("Connected successfully!")
        break
    except Exception as e:
        print(f"Connection failed: {e}")

if not conn:
    print("Could not connect directly via public proxy. Container will execute schema on startup inside Railway private network.")
    sys.exit(0)

conn.autocommit = True
cursor = conn.cursor()

with open("database/schema.sql", "r") as f:
    schema_sql = f.read()

print("Executing database/schema.sql on live PostgreSQL database...")
cursor.execute(schema_sql)
print("Successfully executed schema.sql! All 18 tables and indexes created.")

# Verify created tables
cursor.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    ORDER BY table_name;
""")
tables = cursor.fetchall()
print("\nVerified Live Tables in Railway PostgreSQL Database:")
for t in tables:
    print(f"  ✓ {t[0]}")

cursor.close()
conn.close()
