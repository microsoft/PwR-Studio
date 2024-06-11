---
layout: default
title: Quickstart
---

This tutorial will help you setup PwR Studio on your local computer to create [Jugalbandi Apps](https://github.com/OpenNyAI/Jugalbandi-Studio-Engine).

Prerequisites:
1. OpenAI or Azure OpenAI Keys
2. Docker Desktop
3. MSAL Auth Keys

Instructions:
1. Start Docker Desktop
2. Open bash terminal. If you are on Windows use WSL2
3. Git clone [this](https://github.com/microsoft/PwR-Studio) repo
4. Git clone the [JB-Studio-Engine](https://github.com/OpenNyAI/Jugalbandi-Studio-Engine) repo
4. Setup local environment variables
    1. Copy `env-dev.template` to `.env-dev`
    2. Enter OpenAI or Azure OpenAI credentials. Remember to remove Azure keys if you are not using them
    3. Enter the MSAL Auth keys
5. Start Postgres DB and add basic data:
```bash
./scripts/run.sh postgres
psql -U postgres -h localhost < scripts/backup.sql
psql -U postgres -h localhost < ../JB-Engine-Release/backup.sql
```
6. Start Kafka
```
./scripts/run.sh kafka
./scripts/create-topic.sh jb
```
5. Start the PwR Studio
```bash
./scripts/run.sh server studio engine
```
Note: if it hangs, please cancel (Control + C) and retry the above step

6. Go to the broswer `http://localhost:4173`
7. Next instructions to test:
