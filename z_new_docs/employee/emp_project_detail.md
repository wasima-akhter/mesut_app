EmployeeProjectDetail
EMPLOYEE-only Assignment / Project Detail reads under /mobile/employee/projects/:projectId. Crew/PM assignment required. No financial fields. SM management routes stay separate.



GET
/api/v1/mobile/employee/projects/{projectId}
Employee Assignment / Project Detail



Read-only detail for Assignment Detail + Project Details screens. Requires crew or PM assignment. Includes phase badge, map coords, site manager contact, site access, photo/task previews. No budget/profit fields.

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
Employee project detail fetched

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Employee project detail fetched successfully.",
  "traceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "string",
    "address": "string",
    "city": "string",
    "coordinates": {
      "lat": 0,
      "lng": 0
    },
    "siteAccessCode": "string",
    "siteAccessNotes": "string",
    "scaffoldArea": 0,
    "scaffoldLabel": "string",
    "phase": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "type": "ERECTION",
      "status": "ENQUIRY",
      "startDate": "2026-11-21T08:17:52.764Z",
      "endDate": "2026-11-21T08:17:52.764Z",
      "assignedHoursToday": 0
    },
    "siteManager": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "firstName": "string",
      "lastName": "string",
      "phone": "string",
      "avatarUrl": "string"
    },
    "photoCount": 0,
    "photos": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "url": "string",
        "fileType": "string",
        "fileName": "string",
        "fileSize": 0,
        "isCover": true,
        "category": "PHOTO",
        "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "inspectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "createdAt": "2026-11-21T08:17:52.764Z"
      }
    ],
    "taskCount": 0,
    "tasks": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "title": "string",
        "description": "string",
        "priority": "HIGH",
        "isCompleted": true,
        "dueDate": "2026-11-21T08:17:52.764Z",
        "employee": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "firstName": "string",
          "lastName": "string",
          "avatarUrl": "string"
        },
        "createdAt": "2026-11-21T08:17:52.764Z",
        "updatedAt": "2026-11-21T08:17:52.764Z",
        "localization": {
          "sourceLocale": "de",
          "displayedLocale": "en",
          "isTranslated": true,
          "translationStatus": "PENDING"
        }
      }
    ],
    "localization": {
      "sourceLocale": "de",
      "displayedLocale": "en",
      "isTranslated": true,
      "translationStatus": "PENDING"
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
Not an employee or not assigned to project

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

GET
/api/v1/mobile/employee/projects/{projectId}/photos
Employee project photos (View All)



Paginated PHOTO attachments for an assigned project.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
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
Photos fetched

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Project photos fetched successfully.",
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
      "url": "string",
      "fileType": "string",
      "fileName": "string",
      "fileSize": 0,
      "isCover": true,
      "category": "PHOTO",
      "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "inspectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "createdAt": "2026-11-21T08:17:52.766Z"
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
Not assigned

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

GET
/api/v1/mobile/employee/projects/{projectId}/tasks
Employee own tasks on a project



Tasks assigned to the authenticated employee on this project.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
status
string
(query)
Available values : OPEN, COMPLETED


--
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
Tasks fetched

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Employee project tasks fetched successfully.",
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
      "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "title": "string",
      "description": "string",
      "priority": "HIGH",
      "isCompleted": true,
      "dueDate": "2026-11-21T08:17:52.767Z",
      "employee": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "firstName": "string",
        "lastName": "string",
        "avatarUrl": "string"
      },
      "createdAt": "2026-11-21T08:17:52.767Z",
      "updatedAt": "2026-11-21T08:17:52.767Z",
      "localization": {
        "sourceLocale": "de",
        "displayedLocale": "en",
        "isTranslated": true,
        "translationStatus": "PENDING"
      }
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
Not assigned

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
