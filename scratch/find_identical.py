import json

with open('lib/l10n/app_en.arb', 'r') as f:
    en = json.load(f)

with open('lib/l10n/app_ar.arb', 'r') as f:
    ar = json.load(f)

identical = []
for k, v in en.items():
    if k.startswith('@'): continue
    if k in ar and ar[k] == v:
        identical.append(k)

print(f"Identical values: {identical}")
print(f"Count: {len(identical)}")
