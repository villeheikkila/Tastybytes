## Tastekeeper

Tastekeeper is a PWA for keeping track of things you have tasted. The user can add new treats to the database with various metadata and then add review of the product, the other users of the app can also add reviews to all previously added products. The primary goal is to replace the use of Excel for keeping track of various treats I have tried.

### Tech Stack

The project has SPA frontend and Node based backend. Redis and PostgreSQL are used to store the data. Currently Redis is used for "less persistent" data such as email verification tokens. In future it will used for caching, rate limiting etc.

| Technology    | Purpose                    |
| ------------- | -------------------------- |
| React         | Frontend framework         |
| framer-motion | Animations                 |
| Apollo        | GraphQL server and client  |
| Koa           | HTTP server                |
| type-graphql  | Code first GraphQL schemas |
| typeorm       | ORM                        |
| PostgreSQL    | SQL database               |
| Redis         | In-memory data store       |

### Environment variables

| Variable                 | Purpose                                    |
| ------------------------ | ------------------------------------------ |
| POSTGRES_DB              | PostgreSQL database name                   |
| POSTGRES_PASSWORD        | PostgreSQL database password               |
| POSTGRES_USER            | PostgreSQL database username               |
| JWT_PUBLIC_KEY           | GraphQL server and client                  |
| JWT_PRIVATE_KEY          | GraphQL server and client                  |
| DOMAIN                   | The domain of the project, used for emails |
| API_PORT                 | The GraphQL server port for development    |
| EMAIL_SENDER             | Email sender domain                        |
| RECAPTCHA_SITE_KEY       | Google reCAPTCHA site key                  |
| RECAPTCHA_SECRET_KEY     | Google reCAPTCHA secret key                |
| AWS_S3_ACCESS_KEY        | AWS S3 access key                          |
| AWS_S3_SECRET_ACCESS_KEY | AWS S3 secret access key                   |
| AWS_S3_BUCKET_NAME       | AWS S3 bucket name                         |

### How to get started?

For development environment:

1. Clone this repo
2. Set up all the environment variables
3. docker-compose up --build
4. access the running service at localhost:3000
