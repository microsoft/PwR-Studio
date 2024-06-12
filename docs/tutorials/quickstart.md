---
layout: default
title: Quickstart
---

This tutorial will help you setup PwR Studio on your local computer to create [Jugalbandi Apps](https://github.com/OpenNyAI/Jugalbandi-Studio-Engine).

---

# QuickStart Guide for Setting up PwR-Studio 🎉

## Prerequisites

1. **OpenAI or Azure OpenAI Keys:** Obtain from [OpenAI](https://beta.openai.com/signup/) or [Azure](https://portal.azure.com/).
2. **Docker:** Install [Docker Desktop](https://www.docker.com/products/docker-desktop) for Windows and Mac or [Docker Engine](https://docs.docker.com/engine/install/) for Linux.
3. **Docker Compose:** Install [Docker Compose](https://docs.docker.com/compose/install/) for running multiple containers.
4. **Microsoft Authentication Library (MSAL) Keys:** Obtain from [Azure](https://portal.azure.com/).

## Instructions

1. **Start Docker:**
   - Ensure Docker Desktop is running.

2. **Open Bash Terminal:**
   - For Windows, use WSL2.

3. **Clone PwR-Studio Repository:**
   ```bash
   git clone git@github.com:microsoft/PwR-Studio.git
   ```
   - **Note:** If you encounter the following error, your SSH setup is incorrect. Follow the instructions [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

     ```
     Permission denied (publickey).
     fatal: Could not read from remote repository.

     Please make sure you have the correct access rights
     and the repository exists.
     ```

4. **Clone [JB-Studio-Engine](https://github.com/OpenNyAI/Jugalbandi-Studio-Engine) Repository:**
   ```bash
   git clone git@github.com:OpenNyAI/Jugalbandi-Studio-Engine.git
   ```

   Great job! You have successfully cloned the repositories. 🎉

5. **Setup Local Environment Variables:**
   1. Copy `env-dev.template` to `.env-dev`:
      ```bash
      cp env-dev.template .env-dev
      ```
   2. Enter your OpenAI or Azure OpenAI credentials in the `.env-dev` file.
   3. Enter your MSAL Auth keys.
   - **Note:** Remove Azure keys if you are not using them.

## Steps to Start PwR Studio

We have script files to start the PwR Studio. You can use the following commands to start the PwR Studio.

1. **Start Postgres DB and Add Basic Data:**
   ```bash
   ./scripts/run.sh postgres
   ```
2. **Restore the Backup Data from PwR Studio and JB-Studio-Engine:**
   ```bash
   psql -U postgres -h localhost < scripts/backup.sql
   ```
   ```bash
   psql -U postgres -h localhost < path/to/backup.sql/file/in/JB-Studio-Engine
   ```
   - **Note:** This will prompt you to enter the password for the Postgres DB. The default password is `postgres`. Enter the password and press Enter.

   This will restore the data from the backup file to the Postgres DB.

3. **Setup Kafka and Create a Topic:**
   1. First start a Kafka container using the following command:
      ```bash
      ./scripts/run.sh kafka
      ```
   2. Next, create a kafka topic `jb` using the following command:
      ```bash
      ./scripts/create-topic.sh jb
      ```

4. **Start the PwR Studio:**
   ```bash
   ./scripts/run.sh server studio engine
   ```
   - **Note:** You need to run the above command twice to start both the PwR Studio and the engine. First time, let the server start completely and then stop (`Ctrl + C`) it. Then run the command again to start the engine.

5. **Open PwR Studio in Browser:**
   - Go to `http://localhost:4173`

6. **Next Instructions to Test:**
   - Follow the specific testing instructions provided.

---
