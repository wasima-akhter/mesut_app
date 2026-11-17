GET
/api/v1/mobile/profile
Get mobile profile stats



Returns profile fields (including language from UserPreference), plus hoursThisWeek (UTC ISO week, APPROVED net hours), assignedProjectsCount, and completedProjectsCount (all phases COMPLETED). Available to EMPLOYEE and SITE_MANAGER.

Parameters
Try it out
No parameters

Responses
Code	Description	Links
200
Profile fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Profile fetched successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "firstName": "string",
    "lastName": "string",
    "role": "ADMIN",
    "email": "user@example.com",
    "phone": "string",
    "avatarUrl": "string",
    "language": "DE",
    "weeklyHoursTarget": 0,
    "hoursThisWeek": 32.5,
    "assignedProjectsCount": 0,
    "completedProjectsCount": 0
  }
}
No links
401
Authentication or device session failed

Media type

application/json
Examples

tokenInvalid
Example Value
Schema
{
  "success": false,
  "message": "Token not found",
  "errorType": "TOKEN_INVALID",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
403
Account inactive or suspended

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Your account is not active. Please verify your email or contact support.",
  "errorType": "ACCOUNT_INACTIVE",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
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

# -->

PATCH
/api/v1/mobile/profile
Update mobile self-profile



Updates the authenticated EMPLOYEE/SITE_MANAGER profile. Patchable: firstName, lastName, phone (no format), avatarUrl (URL or null), language (upserts UserPreference). At least one field required. Not patchable: email, role, status, password, weeklyHoursTarget. Upload avatar via POST /media first, then pass the URL. Response shape matches GET.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "firstName": "Tim",
  "lastName": "Muller",
  "phone": "+49654515151",
  "avatarUrl": "https://cdn.example.com/avatar.jpg",
  "language": "DE"
}
Responses
Code	Description	Links
200
Profile updated successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Profile fetched successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "firstName": "string",
    "lastName": "string",
    "role": "ADMIN",
    "email": "user@example.com",
    "phone": "string",
    "avatarUrl": "string",
    "language": "DE",
    "weeklyHoursTarget": 0,
    "hoursThisWeek": 32.5,
    "assignedProjectsCount": 0,
    "completedProjectsCount": 0
  }
}
No links
401
Authentication or device session failed

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
403
Account inactive or suspended

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
Request validation failed

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
