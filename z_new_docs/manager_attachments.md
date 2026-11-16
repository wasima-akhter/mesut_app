GET
/api/v1/mobile/projects/{projectId}/attachments
List project attachments



Lists PHOTO / PDF_PLAN attachments for Photos and PDF Plan tabs.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
category
string
(query)
Optional category filter for Photos vs PDF Plan tabs

Available values : PHOTO, PDF_PLAN


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
Project attachments fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "string",
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
      "createdAt": "2026-11-16T04:10:23.142Z"
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

# -->

POST
/api/v1/mobile/projects/{projectId}/attachments
Register project attachment



Creates an Attachment row for a previously uploaded S3 URL (PHOTO or PDF_PLAN).

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
Request body

application/json
Example Value
Schema
{
  "url": "string",
  "fileType": "string",
  "category": "PHOTO",
  "fileName": "string",
  "fileSize": 0,
  "isCover": true
}
Responses
Code	Description	Links
201
Project attachment created successfully

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
    "url": "string",
    "fileType": "string",
    "fileName": "string",
    "fileSize": 0,
    "isCover": true,
    "category": "PHOTO",
    "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "inspectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "createdAt": "2026-11-16T04:11:11.783Z"
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


# -->

PATCH
/api/v1/mobile/projects/{projectId}/attachments/{id}/cover
Set project cover photo



Marks a PHOTO attachment as cover and clears isCover on other project photos.

Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
id *
string($uuid)
(path)
id
Responses
Code	Description	Links
200
Cover photo updated successfully

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
    "url": "string",
    "fileType": "string",
    "fileName": "string",
    "fileSize": 0,
    "isCover": true,
    "category": "PHOTO",
    "projectId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "inspectionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "createdAt": "2026-11-16T04:11:32.911Z"
  }
}
No links
400
Attachment is not a PHOTO

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
Attachment not found

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


# -->
DELETE
/api/v1/mobile/projects/{projectId}/attachments/{id}
Delete project attachment



Parameters
Try it out
Name	Description
projectId *
string($uuid)
(path)
projectId
id *
string($uuid)
(path)
id
Responses
Code	Description	Links
200
Project attachment deleted successfully

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
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
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
Attachment not found

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
