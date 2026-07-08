import bcrypt

# The password hash from the admin user
hash_from_db = "$2a$10$AyPLaOhciwVr.NDoDir7BuUnTBbCmzrQirp0zquowdWaWS.c8pcTq"
password = "admin123"

# Try to verify
print("Verifying password with bcrypt...")
print("Hash:", hash_from_db)
print("Password:", password)

try:
    bcrypt.CompareHashAndPassword([]byte(hash_from_db), []byte(password))
    print("✓ Password verification successful!")
except Exception as e:
    print(f"✗ Error during authentication: {type(e).__name__}: {e}")