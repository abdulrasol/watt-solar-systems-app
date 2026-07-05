# Watt Frontend -> Backend Alignment Rule

<RULE>
Whenever you are working on the Flutter frontend (creating API calls, models, or integrating features), you MUST strictly adhere to the following rules:

1. **Check Backend Code**: Always refer to the backend codebase located at `../backend` (relative to the workspace root). 
2. **Exact Matching**: Before writing any Dart model or API call, use `grep_search` or `view_file` on the backend directory (`../backend/src/` and `../backend/prisma/schema.prisma`) to verify the exact endpoint path, HTTP method, and JSON payload structure.
3. **API Prefix**: All API requests must use the global prefix `/api/v1/` (e.g., `/api/v1/offers`).
4. **Standard Response Wrapper**: The backend always wraps its responses in this format:
   ```json
   {
     "status": 200,
     "message": "Success",
     "body": { ... },
     "error": false,
     "message_user": null
   }
   ```
   You MUST design your Dart network layer to unwrap this response and map the `body` field correctly.
5. **No Assumptions**: DO NOT guess the API structure. If you are unsure, search the backend code to confirm.
</RULE>
