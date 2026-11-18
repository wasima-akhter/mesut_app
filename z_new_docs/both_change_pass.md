POST
/api/v1/settings/password
Change password (EMPLOYEE + SITE_MANAGER)



Authenticated mobile endpoint. Verifies current password, ensures the new password differs, updates passwordHash, and revokes all other active device sessions (RevokeReason.PASSWORD_CHANGED). Keeps the current device.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "currentPassword": "SecurePassword123!",
  "newPassword": "BrandNewPassword2026!"
}
Responses
Code	Description	Links
200
Password changed successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Change password successful.",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
400
Current password incorrect or identical to existing password

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Current password is incorrect or new password matches the existing one.",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
401
Authentication or device session error

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "string",
  "errorType": "TOKEN_EXPIRED",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
No links
422
Validation error

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "string",
  "errorType": "string",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "errors": [
    {
      "field": "string",
      "message": "string"
    }
  ]
}
No links
500
Internal server error

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "string",
  "errorType": "INVALID_JSON",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
