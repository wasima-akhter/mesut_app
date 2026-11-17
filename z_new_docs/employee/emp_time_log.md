GET
/api/v1/mobile/employee/time-tracking/summary
Employee Time Tracking summary



Today / This Week hours, weekly target, week label, active timer.

Parameters
Try it out
No parameters

Responses
Code	Description	Links
200
Summary fetched

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Time tracking summary fetched successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "todayHours": 7.5,
    "weekHours": 35.5,
    "weeklyHoursTarget": 40,
    "weekNumber": 38,
    "weekStartDate": "2026-09-14",
    "weekEndDate": "2026-09-20",
    "activeTimer": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "activityType": "ERECTION",
      "startTime": "2026-11-17T08:42:27.116Z",
      "endTime": "2026-11-17T08:42:27.116Z",
      "isManual": true,
      "status": "PENDING_APPROVAL",
      "clientSyncId": "string",
      "breakMinutes": 0,
      "netHours": 0,
      "createdAt": "2026-11-17T08:42:27.116Z",
      "updatedAt": "2026-11-17T08:42:27.116Z",
      "project": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "name": "string"
      },
      "synced": true
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
Not an employee

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


# -->

GET
/api/v1/mobile/employee/time-tracking/projects
Employee assigned projects (timer dropdown)



Assigned Project dropdown for Start Timer / Add Time. Returns { id, name, phaseId, phaseType }.

Parameters
Try it out
Name	Description
page
integer
(query)
Default value : 1

1
limit
integer
(query)
Default value : 10

10
Responses
Code	Description	Links
200
Projects fetched

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Time tracking projects fetched successfully.",
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
      "name": "string",
      "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "phaseType": "ERECTION"
    }
  ]
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
Not an employee

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


# --->

POST
/api/v1/mobile/employee/timer/start
Employee Start New Timer



EMPLOYEE only. Prefer projectId from time-tracking projects list (or phaseId). Starts from now.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "projectId": "222e4567-e89b-12d3-a456-426614174000",
  "activityType": "ERECTION"
}
Responses
Code	Description	Links
201
Timer started

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
    "timeLog": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "phaseId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "activityType": "ERECTION",
      "startTime": "2026-11-17T08:43:50.188Z",
      "endTime": "2026-11-17T08:43:50.188Z",
      "isManual": true,
      "status": "PENDING_APPROVAL",
      "clientSyncId": "string",
      "breakMinutes": 0,
      "netHours": 0,
      "createdAt": "2026-11-17T08:43:50.188Z",
      "updatedAt": "2026-11-17T08:43:50.188Z",
      "user": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "firstName": "string",
        "lastName": "string"
      }
    },
    "project": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": "string",
      "address": "string",
      "customer": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "name": "string"
      },
      "phases": [
        {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "type": "ERECTION",
          "status": "ENQUIRY",
          "priority": "HIGH",
          "startDate": "2026-11-17T08:43:50.188Z",
          "endDate": "2026-11-17T08:43:50.188Z"
        }
      ],
      "budgetedHours": 0,
      "totalLoggedHours": 0,
      "isProfitable": true
    }
  }
}
No links
409
Active timer exists

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

# -->

POST
/api/v1/mobile/employee/timer/stop
Employee stop timer



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
Timer stopped

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
    "startTime": "2026-11-17T08:44:12.538Z",
    "endTime": "2026-11-17T08:44:12.538Z",
    "isManual": true,
    "status": "PENDING_APPROVAL",
    "clientSyncId": "string",
    "breakMinutes": 0,
    "netHours": 0,
    "createdAt": "2026-11-17T08:44:12.538Z",
    "updatedAt": "2026-11-17T08:44:12.538Z",
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "firstName": "string",
      "lastName": "string"
    }
  }
}


# -->

POST
/api/v1/mobile/employee/timer/manual
Employee Add Time Entry



EMPLOYEE only. projectId or phaseId + times + breakMinutes → PENDING_APPROVAL.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "projectId": "222e4567-e89b-12d3-a456-426614174000",
  "activityType": "ERECTION",
  "startTime": "2026-10-12T07:30:00.000Z",
  "endTime": "2026-10-12T18:30:00.000Z",
  "breakMinutes": 45
}
Responses
Code	Description	Links
201
Manual entry submitted

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
    "startTime": "2026-11-17T08:44:35.376Z",
    "endTime": "2026-11-17T08:44:35.376Z",
    "isManual": true,
    "status": "PENDING_APPROVAL",
    "clientSyncId": "string",
    "breakMinutes": 0,
    "netHours": 0,
    "createdAt": "2026-11-17T08:44:35.376Z",
    "updatedAt": "2026-11-17T08:44:35.376Z",
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "firstName": "string",
      "lastName": "string"
    }
  }
}
No links
403
Manual time disabled

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



# -->


GET
/api/v1/mobile/employee/time-logs
Employee Recent Logs



This Week → period=WEEK; This Month → period=MONTH. Includes project + synced.

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
Default value : 1

1
limit
integer
(query)
Default value : 10

10
Responses
Code	Description	Links
200
Logs fetched

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
      "startTime": "2026-11-17T08:44:59.857Z",
      "endTime": "2026-11-17T08:44:59.857Z",
      "isManual": true,
      "status": "PENDING_APPROVAL",
      "clientSyncId": "string",
      "breakMinutes": 0,
      "netHours": 0,
      "createdAt": "2026-11-17T08:44:59.857Z",
      "updatedAt": "2026-11-17T08:44:59.857Z",
      "project": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "name": "string"
      },
      "synced": true
    }
  ]
}
No links
403
Not an employee

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
