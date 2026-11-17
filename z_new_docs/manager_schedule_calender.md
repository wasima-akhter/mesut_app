GET
/api/v1/mobile/schedule
Get site-manager Calendar / schedule



Site Manager only. Powers the Calendar screen for a month/week window.

Each day bucket includes:

phases[] — overlapping ProjectPhases (calendar dots: ERECTION / DISMANTLING / STANDING|MAINTENANCE → Half-day in UI)
inspections[] — inspections assigned to this SM with appointmentDate on that UTC day (day list; empty → "No inspections assigned")
Event count for the day banner = phases.length + inspections.length. Respects CompanyProfile.siteManagerAccessRule. Excludes phases with null startDate/endDate. Use limit ≥ number of days in the window (e.g. 31 for a month).

Parameters
Try it out
Name	Description
startDate *
string($date-time)
(query)
startDate
endDate *
string($date-time)
(query)
endDate
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
Schedule fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Schedule fetched successfully.",
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
  "data": [
    {
      "date": "2026-11-12",
      "phases": [
        {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "type": "ERECTION",
          "status": "ENQUIRY",
          "priority": "HIGH",
          "startDate": "2026-11-17T06:32:02.283Z",
          "endDate": "2026-11-17T06:32:02.284Z",
          "project": {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "name": "string",
            "address": "string"
          }
        }
      ],
      "inspections": [
        {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "siteTitle": "string",
          "address": "string",
          "postalCode": "string",
          "city": "string",
          "appointmentDate": "2026-11-17T06:32:02.284Z",
          "scaffoldArea": 0,
          "scaffoldHeight": 0,
          "scaffoldType": "string",
          "siteAccessInstructions": "string",
          "specialRequirements": "string",
          "status": "PENDING",
          "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "customer": {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "name": "string",
            "category": "COMMERCIAL"
          },
          "createdAt": "2026-11-17T06:32:02.284Z",
          "updatedAt": "2026-11-17T06:32:02.284Z",
          "convertedProject": {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
            "name": "string"
          }
        }
      ]
    }
  ]
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
Forbidden (not site manager)

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
Request query validation failed

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
