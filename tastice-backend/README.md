# ![tastice](https://fontmeme.com/permalink/190704/0daa2ab57e001e0aa2002608810c7a69.png)

## How to get started

1. Pass the required environment variables and run "docker-compose up"
2. After the Prisma server is running and .env file is correctly set up, start the backend with "npm run dev".
3. Profit

## Available Scripts

| Script    | Function                                                                               |
| --------- | -------------------------------------------------------------------------------------- |
| npm start | Starts the backend server                                                              |
| npm dev   | Starts the backend and reloads on changes, loads environment variables from .env file. |

### List of environment variables for the docker-compose file

| Environment variable | Function                             |
| -------------------- | ------------------------------------ |
| POSTGRES_USER        | The username for PostgreSQL database |
| POSTGRES_PASSWORD    | The password for PostgreSQL database |

### List of environment variables for the backend

| Environment variable | Function                                                                                 |
| -------------------- | ---------------------------------------------------------------------------------------- |
| PRISMA_ENDPOINT      | URL for the Prisma server                                                                |
| SECRET               | The secret for signing JWT tokens for communication between the frontend and the backend |
| PRISMA_STAGE         | Defines on which stage to start Prisma on                                                |
| PRISMA_SECRET        | Management API secret                                                                    |
| PRISMA_ENDPOINT      | The endpoint for Prisma server                                                           |
| PRISMA_SECRET        | The service secret for the Prisma server                                                 |
