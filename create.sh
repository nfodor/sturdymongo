#!/usr/bin/env bash
export MONGO_ROOT_USER=admin
export  MONGO_USER=adminman
export  MONGO_DB=passpass
docker-compose up --build --force-recreate --remove-orphans mongodb