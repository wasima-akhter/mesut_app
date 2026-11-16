# -- "My Time" entry  start -->

[MobileTimeTracking](https://allround.localbox.online/api-docs/#/MobileTimeTracking)Mobile timer, crew time, and offline sync endpoints
POST[/api/v1/mobile/timer/start](https://allround.localbox.online/api-docs/#/MobileTimeTracking/startMobileTimer)Start mobile timer
Starts an active TimeLog and returns { timeLog, project } (role-aware project via getProjectDto). Rejects with 409 when an open timer already exists.
Parameters
Try it out
No parameters
Request body
application/json
Example Value
Schema
{ "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "activityType": "ERECTION", "gpsStartLat": 0, "gpsStartLng": 0 }
Responses
Code
Description
Links
201
Timer started successfully
Media typeapplication/json
Controls Accept header.
Example Value
Schema
{ "success": true, "message": "Timer started successfully.", "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "data": { "timeLog": { "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "activityType": "ERECTION", "startTime": "2026-11-16T08:28:07.353Z", "endTime": "2026-11-16T08:28:07.353Z", "isManual": true, "status": "PENDING_APPROVAL", "clientSyncId": "string", "breakMinutes": 0, "netHours": 0, "createdAt": "2026-11-16T08:28:07.353Z", "updatedAt": "2026-11-16T08:28:07.353Z", "user": { "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "firstName": "string", "lastName": "string" } }, "project": { "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "name": "string", "address": "string", "customer": { "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "name": "string" }, "phases": [ { "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "type": "ERECTION", "status": "ENQUIRY", "priority": "HIGH", "startDate": "2026-11-16T08:28:07.353Z", "endDate": "2026-11-16T08:28:07.353Z" } ], "budgetedHours": 0, "totalLoggedHours": 0, "isProfitable": true } } }
No links
400
Invalid JSON payload
Media typeapplication/json
Example Value
Schema
{ "success": false, "message": "string", "errorType": "INVALID_JSON", "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6" }
No links
401
Authentication or device session failed
Media typeapplication/json
Example Value
Schema
{ "success": false, "message": "Token not found", "errorType": "TOKEN_INVALID", "traceId": "123e4567-e89b-12d3-a456-426614174000" }
No links
403
Forbidden or inactive account
Media typeapplication/json
Example Value
Schema
{ "success": false, "message": "Only site managers can access crew time logs", "errorType": "FORBIDDEN", "traceId": "123e4567-e89b-12d3-a456-426614174000" }
No links
404
Phase not found
Media typeapplication/json
Example Value
Schema
{ "success": false, "message": "Phase not found", "errorType": "PHASE_NOT_FOUND", "traceId": "123e4567-e89b-12d3-a456-426614174000" }
No links
409
Active timer already exists (checkNoActiveTimerMiddleware)
Media typeapplication/json
Example Value
Schema
{ "success": false, "message": "An active timer already exists", "errorType": "ACTIVE_TIMER_EXISTS", "traceId": "123e4567-e89b-12d3-a456-426614174000" }
No links
422
Request validation failed
Media typeapplication/json
Example Value
Schema
{ "success": false, "message": "string", "errorType": "string", "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6", "errors": [ { "field": "string", "message": "string" } ] }
No links
500
Internal server error
Media typeapplication/json
Example Value
Schema
{ "success": false, "message": "string", "errorType": "INVALID_JSON", "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6" }


# -- My Time entry stop  --

POST
/api/v1/mobile/timer/stop
Stop mobile timer



Stops the authenticated user's open timer by timeLogId and sets endTime/GPS.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "timeLogId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "gpsEndLat": 0,
  "gpsEndLng": 0
}
Responses
Code	Description	Links
200
Timer stopped successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Timer started successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "activityType": "ERECTION",
    "startTime": "2026-11-16T08:43:35.002Z",
    "endTime": "2026-11-16T08:43:35.002Z",
    "isManual": true,
    "status": "PENDING_APPROVAL",
    "clientSyncId": "string",
    "breakMinutes": 0,
    "netHours": 0,
    "createdAt": "2026-11-16T08:43:35.002Z",
    "updatedAt": "2026-11-16T08:43:35.002Z",
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "firstName": "string",
      "lastName": "string"
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
Forbidden or inactive account

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Only site managers can access crew time logs",
  "errorType": "FORBIDDEN",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
404
Active owned time log not found

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Active time log not found",
  "errorType": "TIMELOG_NOT_FOUND",
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


# -- Add Time (My time) manual entry --

** payload doesnot take date field, remove from UI too.
POST
/api/v1/mobile/timer/manual
Create manual time entry



Creates a manual TimeLog with status PENDING_APPROVAL and optional break minutes. Employees are blocked with 403 when CompanyProfile.allowEmployeeManualTime is false.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "activityType": "ERECTION",
  "startTime": "2026-11-16T08:44:15.830Z",
  "endTime": "2026-11-16T08:44:15.830Z",
  "breakMinutes": 0
}
Responses
Code	Description	Links
201
Manual time entry submitted

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Timer started successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "activityType": "ERECTION",
    "startTime": "2026-11-16T08:44:15.904Z",
    "endTime": "2026-11-16T08:44:15.904Z",
    "isManual": true,
    "status": "PENDING_APPROVAL",
    "clientSyncId": "string",
    "breakMinutes": 0,
    "netHours": 0,
    "createdAt": "2026-11-16T08:44:15.904Z",
    "updatedAt": "2026-11-16T08:44:15.904Z",
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "firstName": "string",
      "lastName": "string"
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
Forbidden — inactive account, or employee manual time disabled

Media type

application/json
Examples

Inactive account
Example Value
Schema
{
  "success": false,
  "message": "Account is inactive",
  "errorType": "ACCOUNT_INACTIVE",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
No links
404
Phase not found

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



# --> Get Time logs (my time)

GET
/api/v1/mobile/time-logs
List my time logs



Returns the authenticated user's time logs filtered by UTC period TODAY, WEEK, or MONTH.

Parameters
Try it out
Name	Description
period
string
(query)
Available values : TODAY, WEEK, MONTH

Default value : TODAY


TODAY
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
Time logs fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Time logs fetched successfully.",
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
      "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "activityType": "ERECTION",
      "startTime": "2026-11-16T08:45:21.803Z",
      "endTime": "2026-11-16T08:45:21.803Z",
      "isManual": true,
      "status": "PENDING_APPROVAL",
      "clientSyncId": "string",
      "breakMinutes": 0,
      "netHours": 0,
      "createdAt": "2026-11-16T08:45:21.803Z",
      "updatedAt": "2026-11-16T08:45:21.803Z",
      "user": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "firstName": "string",
        "lastName": "string"
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
Forbidden or inactive account

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Only site managers can access crew time logs",
  "errorType": "FORBIDDEN",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
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

# --> Get Site Crew Time -->

GET
/api/v1/mobile/crew-time
Get project crew time



Site Manager only. Aggregates TimeLogs for a project (optional UTC date filter). Returns totalProjectHours, hoursByActivity, crewBreakdown, and log details.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(query)
projectId
date
string($date-time)
(query)
date
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
Crew time fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Crew time fetched successfully.",
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
    "totalProjectHours": 0,
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
    "logs": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "activityType": "ERECTION",
        "startTime": "2026-11-16T08:46:10.947Z",
        "endTime": "2026-11-16T08:46:10.947Z",
        "isManual": true,
        "status": "PENDING_APPROVAL",
        "clientSyncId": "string",
        "breakMinutes": 0,
        "netHours": 0,
        "createdAt": "2026-11-16T08:46:10.947Z",
        "updatedAt": "2026-11-16T08:46:10.947Z",
        "user": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "firstName": "string",
          "lastName": "string"
        }
      }
    ]
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
Project not found

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Project not found",
  "errorType": "PROJECT_NOT_FOUND",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
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


# Get time logs (Site Crew Time)

GET
/api/v1/mobile/crew-time
Get project crew time



Site Manager only. Aggregates TimeLogs for a project (optional UTC date filter). Returns totalProjectHours, hoursByActivity, crewBreakdown, and log details.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(query)
projectId
date
string($date-time)
(query)
date
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
Crew time fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Crew time fetched successfully.",
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
    "totalProjectHours": 0,
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
    "logs": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "activityType": "ERECTION",
        "startTime": "2026-11-16T08:46:10.947Z",
        "endTime": "2026-11-16T08:46:10.947Z",
        "isManual": true,
        "status": "PENDING_APPROVAL",
        "clientSyncId": "string",
        "breakMinutes": 0,
        "netHours": 0,
        "createdAt": "2026-11-16T08:46:10.947Z",
        "updatedAt": "2026-11-16T08:46:10.947Z",
        "user": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "firstName": "string",
          "lastName": "string"
        }
      }
    ]
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
Project not found

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Project not found",
  "errorType": "PROJECT_NOT_FOUND",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
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



# ** Every project should be fetched by GET /api/v1/mobile/projects here , and after selecting the project, show it's available phases , and then let user select one as activity type . also , for selected phase, send it's id in payload for entry.
