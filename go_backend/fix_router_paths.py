import os
import re

path = "internal/handlers/companies"
for filename in os.listdir(path):
    if not filename.endswith(".go"): continue
    filepath = os.path.join(path, filename)
    with open(filepath, "r") as f:
        content = f.read()

    # Replace // @Router /api/v1/ with // @Router /
    content = re.sub(r"// @Router /api/v1/", r"// @Router /", content)

    with open(filepath, "w") as f:
        f.write(content)

print("Router paths fixed.")
