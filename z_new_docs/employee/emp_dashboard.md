GET
/api/v1/mobile/employee/dashboard
Get employee mobile dashboard



Returns the employee-specific home dashboard matching the employee mobile UI, including user greeting, formatted date, task counters, and enriched upcoming task cards with site manager and coordinates.

Parameters
Try it out
Name	Description
page
integer
(query)
1-based page number

Default value : 1

1
limit
integer
(query)
Page size

Default value : 10

10
Responses
Code	Description	Links
200
Employee dashboard fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Employee dashboard fetched successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "meta": {
    "total": 150,
    "totalPages": 8,
    "links": {
      "currentPage": "http://localhost:5000/api/v1/items?page=1&limit=20",
      "nextPage": "http://localhost:5000/api/v1/items?page=2&limit=20",
      "previousPage": null,
      "firstPage": "http://localhost:5000/api/v1/items?page=1&limit=20",
      "lastPage": "http://localhost:5000/api/v1/items?page=8&limit=20"
    }
  },
  "data": {
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "firstName": "Mesut",
      "lastName": "Rahaman",
      "role": "EMPLOYEE",
      "avatarUrl": "string"
    },
    "date": "2026-11-17T09:38:00.000Z",
    "formattedDate": "Tuesday, November 17",
    "totalUpcomingTasks": 3,
    "upcomingTasks": [
      {
        "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "type": "ERECTION",
        "status": "ENQUIRY",
        "priority": "HIGH",
        "startDate": "2026-11-17T09:28:56.575Z",
        "endDate": "2026-11-17T09:28:56.575Z",
        "project": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "name": "string",
          "address": "string",
          "coordinates": {
            "lat": 0,
            "lng": 0
          }
        },
        "siteManager": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "name": "Mesut Rahaman",
          "phone": "string",
          "email": "string"
        },
        "workingHours": "07:30 am - 04:15 pm"
      }
    ]
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
