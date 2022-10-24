## Maku

An app for rating various kinds of delicacies with support for social networking. The app provides a flow for guiding the user in adding new items to the database and then provides a way for rating and classifying the added items based on categories, flavor profile, ratings etc.

## Tech stack

This project was kickstarted with [Graphile Starter](https://github.com/graphile/starter) and follows the database driven development pattern. The API is generated from the database schema with [PostGraphile](https://www.graphile.org/). Database migrations are handled with [Graphile Migrate](https://github.com/graphile/migrate) and events with [Graphile Worker](https://github.com/graphile/worker). The express server mostly just facilitates setting up the PostGraphile plugins and workers.

The client is a [Next.js](https://nextjs.org/) application that uses [Apollo](https://github.com/apollographql/apollo-client) client for handling the GraphQL queries and cache. The styling is done by using [Stitches](https://stitches.dev/) CSS in JS library. [graphql-code-generator](https://www.graphql-code-generator.com/) is used to generate hooks and types from the graphql files.
