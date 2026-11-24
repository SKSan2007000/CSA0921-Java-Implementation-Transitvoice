# TRANSITVOICE – Live Demo Flow

1. Introduce the problem: passengers experience long waits, overcrowding and safety concerns, but feedback and follow-up are often fragmented.
2. Open the passenger portal. Show the animated landing page and responsive navigation.
3. Register or log in using `passenger@demo.com` / `demo123`.
4. Submit the weekly survey with origin, destination, route, waiting time, crowding and rating.
5. Submit a bus demand request for a route/time.
6. Submit a sample incident. Explain that urgent real-world threats must go to 112; the prototype records the report for authority review.
7. Open the authority dashboard at port 5174. Log in with `priya@transitvoice.demo` / `demo123`.
8. Open Incident Management, review the report, assign an officer and save a status/action note.
9. Return to the passenger portal and open Track Report to demonstrate the updated status.
10. Finish with analytics: passenger engagement, route demand indicators, incident counts and status distribution.

## Technical explanation

The React applications call a Spring Boot REST API. Spring Boot uses JDBC `JdbcTemplate` to execute SQL against PostgreSQL. The passenger portal writes passenger, survey, request and incident records. The authority dashboard reads those records, updates incident status and assignment, and the API returns aggregate metrics for charts.


## Rapid SOS and evidence review demonstration

1. Open the passenger site and use the top navigation **Rapid SOS** control. The browser requests camera, microphone and location permissions; recording and live GPS capture begin when permissions are granted.
2. Stop the recording, enter the bus code visible on the bus (for example `KK0197`) and submit. A private complaint token is returned.
3. Open the authority dashboard. The incident queue refreshes every 10 seconds and puts Rapid SOS reports first. Open the report to review the bus code, submitted coordinates, evidence file, hash and the three rule-based integrity checks.
4. Assign an officer, record the action and mark the case resolved only after entering the resolution details. Resolution points are awarded once to the passenger and assigned officer.

**Safety and demo boundary:** this flow uploads evidence and captures browser GPS, but does not contact police, locate a real nearest station, guarantee a 10-minute response, identify the driver from a live fleet system or prove video originality. For a real emergency in India, call 112. The evidence checklist is not a forensic AI model.
