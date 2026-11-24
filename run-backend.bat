@echo off
cd /d "%~dp0backend"
set "DB_URL=jdbc:postgresql://localhost:5432/transitvoice"
set "DB_USER=postgres"
set "DB_PASSWORD=postgres"
mvn spring-boot:run
pause
