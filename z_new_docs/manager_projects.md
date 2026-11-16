GET
/api/v1/mobile/projects
List project phase cards



Returns one row per visible phase (phase-centric cards) for projects visible to the authenticated user (GLOBAL_ACCESS or assignment-scoped). Supports UI tabs (tab), filter-modal multi-selects (phaseTypes, phaseStatuses, priorities, categories as CSV or repeated query params), and sorting (sortBy). Cities filter against Project.city. Use phaseStatuses=COMPLETED for the Completed modal filter. UI label Preconstruction maps to status ENQUIRY (not a PhaseType).

Parameters
Try it out
Name	Description
tab
string
(query)
Top navigation tab filter

Available values : ALL, ACTIVE, MY_PROJECTS, THIS_WEEK, INSPECTION

Default value : ALL


ALL
phaseTypes
string
(query)
Comma-separated PhaseType values (or repeated query params)

Example : ERECTION,DISMANTLING

ERECTION,DISMANTLING
phaseStatuses
string
(query)
Comma-separated PhaseStatus values (e.g. COMPLETED for Completed filter)

Example : COMPLETED,IN_PROGRESS

COMPLETED,IN_PROGRESS
search
string
(query)
Case-insensitive search across project name, address, and city

search
lat
number
(query)
Center latitude for geo filter (requires lng)

lat
lng
number
(query)
Center longitude for geo filter (requires lat)

lng
radiusKm
number
(query)
Geo filter radius in kilometers (default 25; used with lat+lng).

Default value : 25

25
priorities
string
(query)
Comma-separated Priority values

Example : HIGH,MEDIUM

HIGH,MEDIUM
categories
string
(query)
Comma-separated CustomerCategory values

Example : COMMERCIAL,MUNICIPALITY

COMMERCIAL,MUNICIPALITY
sortBy
string
(query)
Available values : NEWEST, NEXT_INSPECTION, NAME_AZ

Default value : NEWEST


NEWEST
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
Phase cards fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Projects fetched successfully.",
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
      "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "type": "ERECTION",
      "status": "ENQUIRY",
      "priority": "HIGH",
      "startDate": "2026-11-15T06:18:04.239Z",
      "endDate": "2026-11-15T06:18:04.239Z",
      "durationDays": 0,
      "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "projectName": "string",
      "coordinates": {
        "lat": 0,
        "lng": 0
      },
      "customer": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "name": "string",
        "category": "COMMERCIAL"
      },
      "assigneeName": "string",
      "budgetedHours": 0,
      "totalLoggedHours": 0,
      "isProfitable": true
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
