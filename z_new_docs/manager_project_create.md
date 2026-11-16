POST
/api/v1/mobile/projects
Create project (Site Manager)



Creates a project from the Create New Project form. Location is required as map coordinates (lat/lng). Optional placeLabel is stored as DB address; otherwise "lat, lng" is used. Supports EXISTING or NEW customer, primary contact, erection/dismantling schedules, note, and photos.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "name": "string",
  "coordinates": {
    "lat": 0,
    "lng": 0
  },
  "placeLabel": "string",
  "scaffoldSpecification": {
    "area": 0,
    "height": 0,
    "type": "string"
  },
  "priority": "MEDIUM",
  "phaseType": "ERECTION",
  "status": "ENQUIRY",
  "siteManagerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "customer": {
    "mode": "EXISTING",
    "customerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  },
  "contact": {
    "name": "string",
    "phone": "string",
    "email": "user@example.com",
    "role": "Project lead"
  },
  "scheduleData": [
    {
      "type": "erection",
      "startDate": "2026-11-15T06:17:45.897Z",
      "endDate": "2026-11-15T06:17:45.897Z",
      "durationDays": 0
    }
  ],
  "note": {
    "category": "SITE_ACCESS",
    "content": "string"
  },
  "photos": [
    {
      "url": "string",
      "fileType": "string",
      "fileName": "string",
      "fileSize": 0,
      "isCover": true
    }
  ]
}
Responses
Code	Description	Links
201
Project created successfully

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
        "startDate": "2026-11-15T06:45:56.937Z",
        "endDate": "2026-11-15T06:45:56.937Z",
        "durationDays": 0
      }
    ],
    "nextSafetyInspection": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "appointmentDate": "2026-11-15T06:45:56.937Z",
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
        "startDate": "2026-11-15T06:45:56.937Z",
        "endDate": "2026-11-15T06:45:56.937Z",
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
404
Customer or site manager not found

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



# ------------------------------------------->>>>>>>>>>>>>>>>>>>>

MobileCustomer
Mobile customer directory and selection endpoints



GET
/api/v1/mobile/customers
List customers for mobile



Returns paginated directory of non-deleted customers with primary contact for mobile selection and project creation.

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
search
string
(query)
Case-insensitive search on customer name

search
category
string
(query)
Filter by customer category

Available values : COMMERCIAL, MUNICIPALITY, ARCHITECT, PRIVATE


--
Responses
Code	Description	Links
200
Customers fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Customers fetched successfully.",
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
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Acme Corporation",
      "category": "COMMERCIAL",
      "address": "Musterstraße 12, 10115 Berlin",
      "primaryContact": {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "name": "Jane Doe",
        "role": "Site Manager",
        "phone": "+491701234567",
        "email": "jane.doe@example.com"
      }
    }
  ]
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
422
Request query validation failed

Media type

application/json
Example Value
Schema
{
  "success": false,
  "message": "Request query validation failed",
  "errors": [
    {
      "field": "page",
      "message": "Expected number, received string"
    }
  ],
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
  "message": "Internal Server Error",
  "errorType": "SERVER_ERROR",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
