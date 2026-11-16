GET
/api/v1/mobile/projects/{projectId}
Get project detail hub



Site Manager project Overview/header payload — phases, labor summary, customer + primary contact, city, attachment counts.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
Responses
Code	Description	Links
200
Project fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Project fetched successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "string",
    "coordinates": {
      "lat": 0,
      "lng": 0
    },
    "siteAccessCode": "string",
    "siteAccessNotes": "string",
    "scaffoldSpecification": {
      "area": 0,
      "height": 0,
      "type": "string"
    },
    "scheduleData": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "type": "erection",
        "startDate": "2026-11-15T09:01:56.552Z",
        "endDate": "2026-11-15T09:01:56.552Z",
        "durationDays": 0
      }
    ],
    "nextSafetyInspection": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "appointmentDate": "2026-11-15T09:01:56.552Z",
      "siteTitle": "string",
      "address": "string",
      "city": "string"
    },
    "budgetedHours": 0,
    "totalLoggedHours": 0,
    "isProfitable": true,
    "phases": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "type": "ERECTION",
        "status": "ENQUIRY",
        "priority": "HIGH",
        "startDate": "2026-11-15T09:01:56.552Z",
        "endDate": "2026-11-15T09:01:56.552Z",
        "durationDays": 0,
        "safetyInspectionComplete": true
      }
    ],
    "customer": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": "string",
      "category": "COMMERCIAL",
      "primaryContact": {
        "name": "string",
        "phone": "string",
        "email": "string"
      }
    },
    "hoursByActivity": [
      {
        "activityType": "ERECTION",
        "hours": 0
      }
    ],
    "crewBreakdown": [
      {
        "user": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "firstName": "string",
          "lastName": "string"
        },
        "totalHours": 0,
        "synced": true
      }
    ],
    "attachmentCounts": {
      "photos": 0,
      "pdfPlans": 0
    }
  }
}
No links
401
Authentication failed

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
Forbidden

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
404
Project not found

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
