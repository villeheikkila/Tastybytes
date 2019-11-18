## Available Scripts

| Script    | Function                                  |
| --------- | ----------------------------------------- |
| npm start | Starts the backend and reloads on changes |

### List of environment variables for the docker-compose file

| Env               | Function                             |
| ----------------- | ------------------------------------ |
| POSTGRES_USER     | The username for PostgreSQL database |
| POSTGRES_PASSWORD | The password for PostgreSQL database |

### List of environment variables for the backend

| Env             | Function                                                                                 |
| --------------- | ---------------------------------------------------------------------------------------- |
| SECRET          | The secret for signing JWT tokens for communication between the frontend and the backend |
| PRISMA_ENDPOINT | The endpoint for Prisma server                                                           |
| PRISMA_SECRET   | The service secret for the Prisma server                                                 |
