#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/authority-ui"
npm install
npm run dev
