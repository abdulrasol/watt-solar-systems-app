import re

file_path = "internal/models/company.go"
with open(file_path, "r") as f:
    content = f.read()

# Remove TableName methods
content = re.sub(r'\nfunc \([a-zA-Z]+\) TableName\(\) string \{\n\treturn "[a-z_]+"\n\}\n', '', content)

with open(file_path, "w") as f:
    f.write(content)
