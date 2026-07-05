# Watt Backend -> Frontend Alignment Rule

<RULE>
Whenever you are working on the NestJS backend (generating or modifying APIs, Controllers, Services, or DTOs), you MUST strictly adhere to the following rules:

1. **Check Frontend Compatibility**: If modifying an existing feature, refer to the frontend codebase located at `../frontend` (relative to the workspace root) to ensure you do not break the existing Flutter models or API clients.
2. **No Breaking Changes**: Ensure that any changes to API response structures do not break existing Flutter code (usually found in `../frontend/lib/`). Use `grep_search` on the frontend directory to assess the impact of your changes.
3. **Standard Response Wrapper**: You MUST always maintain the standard API response wrapper in all your controllers (using Interceptors or manually):
   ```json
   {
     "status": 200,
     "message": "Success",
     "body": { ... },
     "error": false,
     "message_user": null
   }
   ```
4. **API Prefix**: Always keep the global prefix `/api/v1/` for external APIs.
5. **Swagger Consistency**: Keep Swagger decorators (`@ApiProperty`, `@ApiOperation`, etc.) up-to-date so that the generated API documentation is always accurate for the frontend developers to consume.
</RULE>
