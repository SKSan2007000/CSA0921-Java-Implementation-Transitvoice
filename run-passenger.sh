#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/passenger-ui"
npm install
npm run dev
