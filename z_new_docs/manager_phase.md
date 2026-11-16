# -- List managed phases
GET
/api/v1/mobile/phases
List managed phases



Site Manager only. Returns ProjectPhases for projects where the user has a ProjectManagerAssignment. Optional column maps Phase Board columns: ENQUIRY filters status=ENQUIRY (UI Preconstruction); ERECTION, DISMANTLING, STANDING filter by phase type.

Parameters
Try it out
Name	Description
column
string
(query)
Phase Board column filter

Available values : ENQUIRY, ERECTION, DISMANTLING, STANDING


--
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
Phases fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Phases fetched successfully.",
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
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "type": "ERECTION",
      "status": "ENQUIRY",
      "priority": "HIGH",
      "startDate": "2026-11-16T10:21:42.156Z",
      "endDate": "2026-11-16T10:21:42.156Z",
      "project": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "name": "string",
        "address": "string"
      }
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
  "message": "Token not found",
  "errorType": "TOKEN_INVALID",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
403
Forbidden (not site manager / not assigned)

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Only site managers can access this resource",
  "errorType": "FORBIDDEN",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
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


# -- Update managed phase status
PATCH
/api/v1/mobile/phases/{id}/status
Update managed phase status



Site Manager only. Updates phase status on a managed project, sets endDate when COMPLETED, and writes AuditLog MOBILE_PHASE_STATUS_UPDATED.

Parameters
Try it out
Name	Description
id *
string($uuid)
(path)
id
Request body

application/json
Example Value
Schema
{
  "status": "COMPLETED"
}
Responses
Code	Description	Links
200
Phase status updated successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Phase status updated successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "type": "ERECTION",
    "status": "ENQUIRY",
    "priority": "HIGH",
    "startDate": "2026-11-16T10:20:58.045Z",
    "endDate": "2026-11-16T10:20:58.045Z",
    "project": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": "string",
      "address": "string"
    }
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
  "message": "Token not found",
  "errorType": "TOKEN_INVALID",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
403
Forbidden (not site manager / not assigned)

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Only site managers can access this resource",
  "errorType": "FORBIDDEN",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
404
Phase not found (checkPhaseExistenceMiddleware)

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Phase not found",
  "errorType": "PHASE_NOT_FOUND",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
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
