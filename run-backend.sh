#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/backend"
export DB_URL="${DB_URL:-jdbc:postgresql://localhost:5432/transitvoice}"
export DB_USER="${DB_USER:-postgres}"
export DB_PASSWORD="${DB_PASSWORD:-postgres}"
mvn spring-boot:run
