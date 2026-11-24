# TRANSITVOICE — Final integrated academic prototype

Three application folders: Passenger UI, Authority UI (Admin, Safety Officer, Depot Officer and Driver role tabs), and Java/JDBC Backend. PostgreSQL stores users, surveys, route demand, incidents, bus journeys and reports.

## Built-in demo logins

| Role | Email | Password |
|---|---|---|
| Admin | `admin@transitvoice.demo` | `AdminTV!2026` |
| Safety Officer (Arun Kumar) | `arun@transitvoice.demo` | `ArunTV!2026` |
| Depot Officer (Priya Raman) | `priya.officer@transitvoice.demo` | `PriyaTV!2026` |
| Guindy Depot | `depot.guindy@transitvoice.demo` | `GuindyTV!2026` |
| Tambaram Depot | `depot.tambaram@transitvoice.demo` | `TambaramTV!2026` |
| Driver 66P | `driver66p@transitvoice.demo` | `Drive66P!` |
| Passenger | `passenger@demo.com` | `demo123` |

Admin is a separate demo role and no longer shares the Depot Officer email. Demo accounts are for local academic demonstration only. Change them before any real deployment. Password hashing for officer, depot and driver accounts is a salted SHA-256 academic-prototype mechanism, not production-grade authentication. Admin demo login is a front-end prototype gate, not secure server-side RBAC.

## Features in this build

- Passenger UI: registration/login, incident complaint upload, Rapid SOS camera/video/GPS flow, incident tracking, rewards, language selector, and a weekly route-demand survey popup when the Admin opens the survey. Survey fields include start, destination, travel reason, preferred time and passenger count.
- Authority UI: role tabs for Admin, Safety Officer, Driver, Depot Officer and Passenger. Admin provisions accounts, opens/closes the weekly survey, and views aggregated route-demand responses. Officer queue includes priority cases, acceptance, driver contact details and evidence review. Driver journey start captures bus photo and browser GPS. Depot view shows buses, drivers and complaints.
- Rapid SOS: authority queue refreshes; the app flags unaccepted SOS reports after one minute and plays an in-page alert sound when the officer dashboard detects escalated SOS. This is an in-app escalation only, not an emergency-services dispatch. Browser audio may require a user interaction first.
- JDBC: Spring `JdbcTemplate` executes SQL against PostgreSQL; no ORM is used. Schema and demo data are initialized by Spring SQL initialization.
- Analytics: survey route demand is grouped by origin/destination and response count for depot planning. These are prototype operational analytics, not an actual Microsoft Power BI integration.

## Windows setup (Command Prompt)

Prerequisites: Java 17+, Maven 3.8+, Node.js 18+, npm, PostgreSQL 14+. Create a PostgreSQL database named `transitvoice` and ensure the local PostgreSQL account/password match the environment variables below.

### 1. Start backend — CMD window 1

```bat
cd /d C:\path\to\TRANSITVOICE_FINAL_DOWNLOAD\transitvoice\backend
set "DB_URL=jdbc:postgresql://localhost:5432/transitvoice"
set "DB_USER=postgres"
set "DB_PASSWORD=postgres"
mvn spring-boot:run
```

If `mvn` is not recognized, add your Maven `bin` folder to Windows PATH or invoke Maven with its full path, for example:

```bat
C:\Maven\apache-maven-3.10.0\bin\mvn.cmd spring-boot:run
```

Wait for Spring Boot to report that it has started. Check `http://localhost:8080/api/health`.

### 2. Passenger UI — CMD window 2

```bat
cd /d C:\path\to\TRANSITVOICE_FINAL_DOWNLOAD\transitvoice\passenger-ui
npm install
npm run dev
```

Open `http://localhost:5173`.

### 3. Authority UI — CMD window 3

```bat
cd /d C:\path\to\TRANSITVOICE_FINAL_DOWNLOAD\transitvoice\authority-ui
npm install
npm run dev
```

Open `http://localhost:5174`. Choose a role tab and sign in using the table above.

Keep all three command windows open. Camera, microphone and GPS require browser permission and a secure context (localhost is allowed).

## Show JDBC during your project demonstration

1. Keep the Spring Boot backend running.
2. Open pgAdmin and connect to PostgreSQL.
3. Expand `Servers → PostgreSQL → Databases → transitvoice → Schemas → public → Tables`.
4. Show tables such as `passengers`, `officers`, `drivers`, `depots`, `incidents`, `surveys`, `survey_responses`, `survey_settings`, `journey_logs` and `incident_assignments`.
5. Open Query Tool and run:

```sql
SELECT current_database();
SELECT * FROM passengers;
SELECT * FROM officers;
SELECT * FROM drivers;
SELECT * FROM depots;
SELECT origin, destination, COUNT(*) AS responses, SUM(passengers_count) AS passenger_demand
FROM survey_responses GROUP BY origin, destination ORDER BY responses DESC;
```

Explain: “The frontend sends HTTP requests to Spring Boot. The backend uses Spring JDBC `JdbcTemplate` with parameterized SQL queries to read and write PostgreSQL records. The database stores the passenger, incident, survey, driver and depot data.”

## Important prototype limitations

This is an academic demonstration, not a live public-safety dispatch system. One-minute escalation is a software flag/notification inside the app. It does not contact police, guarantee an officer response, or remotely control a bus. Camera/GPS depends on user permission. Voice complaint capture and speech-to-text are not included as a full speech-recognition workflow in this package. The UI language selector translates a limited set of interface labels; it does not translate every screen or transcribe speech in multiple languages.
