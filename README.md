## TKO-äly

This is the new work in progress job board for TKO-äly. It's build around the Strapi CMS and the Next.js React Framework. The content is formatted with Markdown and rendered by using react-markdown library. All data is fetched from Strapi's GraphQL API with Apollo client. The styling is done with the combination of Framer Motion and Tailwind CSS.

## How to develop

1. clone the repository
2. set the environment variables for the docker-compose file
3. run docker-compose up

## Environment variable

| First Header      | Second Header                            |
| ----------------- | ---------------------------------------- |
| POSTGRES_PASSWORD | The password for the PostgreSQL database |
| POSTGRES_USER     | The username for the PostgreSQL database |
| STRAPI_URI        | The GraphQL endpoint for Strapi CMS      |
| STRAPI_API_TOKEN  | The API token for Strapi CMS API         |
