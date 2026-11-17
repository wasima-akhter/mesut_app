EmployeeMySchedule
EMPLOYEE-only My Schedule / My Plan tab (Flutter bottom nav "My Plan"). GET /mobile/employee/schedule — crew assignments, calendar dots, site manager name. Not the Site Manager calendar (GET /mobile/schedule).



GET
/api/v1/mobile/employee/schedule
My Schedule (Employee My Plan tab)



EMPLOYEE only — Flutter "My Schedule" / My Plan screen (not SM calendar).

Query the week/month window with startDate + endDate. Response is day buckets:

Days with crew assignments → phases[] (calendar dots)
Empty days in the window → phases: [] (so the week strip can render)
Card mapping:

project.name → "Prj · Goltsteins.Complex"
type → badge / legend (ERECTION green, DISMANTLING orange, MAINTENANCE/STANDING → Other blue)
startDate / endDate / assignedHours → time row
siteManagers[] → "Site Manager: First Last"
Site Manager calendar remains GET /mobile/schedule (unchanged, SM-only).

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
My Schedule fetched successfully

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "success": true,
  "message": "Schedule fetched successfully.",
  "meta": {
    "total": 7,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  },
  "data": [
    {
      "date": "2026-09-18",
      "phases": [
        {
          "id": "111e4567-e89b-12d3-a456-426614174000",
          "type": "ERECTION",
          "status": "IN_PROGRESS",
          "priority": "MEDIUM",
          "startDate": "2026-09-18T07:30:00.000Z",
          "endDate": "2026-09-18T16:30:00.000Z",
          "project": {
            "id": "222e4567-e89b-12d3-a456-426614174000",
            "name": "Goltsteins.Complex",
            "address": "Goltsteinstraße 12, Köln"
          },
          "siteManagers": [
            {
              "id": "333e4567-e89b-12d3-a456-426614174000",
              "firstName": "Mesut",
              "lastName": "Rahaman"
            }
          ],
          "assignedHours": 9
        }
      ]
    },
    {
      "date": "2026-09-19",
      "phases": []
    }
  ],
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
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
Not an employee (SITE_MANAGER must use GET /mobile/schedule)

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
