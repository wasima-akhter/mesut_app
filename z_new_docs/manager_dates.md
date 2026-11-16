PATCH
/api/v1/mobile/projects/{projectId}/phases/{phaseId}/dates
Update phase dates



Updates startDate, endDate, durationDays, and optional safetyInspectionComplete flag.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
phaseId *
string($uuid)
(path)
phaseId
Request body

application/json
Example Value
Schema
{
  "startDate": "2026-11-16T05:54:03.075Z",
  "endDate": "2026-11-16T05:54:03.075Z",
  "durationDays": 0,
  "safetyInspectionComplete": true
}
Responses
Code	Description	Links
200
Phase dates updated successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "string",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "type": "ERECTION",
    "status": "ENQUIRY",
    "priority": "HIGH",
    "startDate": "2026-11-16T05:54:03.100Z",
    "endDate": "2026-11-16T05:54:03.100Z",
    "durationDays": 0,
    "safetyInspectionComplete": true
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
Project or phase not found

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
Validation failed

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
