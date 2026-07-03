import json

with open('lib/l10n/app_en.arb', 'r') as f:
    en = json.load(f)

with open('lib/l10n/app_ar.arb', 'r') as f:
    ar = json.load(f)

en_keys = set(en.keys())
ar_keys = set(ar.keys())

missing_in_ar = en_keys - ar_keys
print(f"Missing in AR: {missing_in_ar}")
