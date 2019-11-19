# ![tastice](https://fontmeme.com/permalink/190704/0daa2ab57e001e0aa2002608810c7a69.png)

Application for keeping track of things you have recently tasted. It mimics the functionality and the interface of the popular tasting apps such as Untapped and Vivino. Unlike the previously mentioned apps however, it supports arbitrary types of foods and drinks such as sodas, coffees or anything else you can imagine.

## Technology Stack

The application is build using React, Apollo, Material-UI and TypeScript on the frontend as well as Node, Prisma and TypeScript on the backend. Data is stored on a PostgreSQL database which is managed by Prisma. All communication between the frontend and the backend happens using GraphQL. Frontend makes use of Cloudinary for image storage.

## Features

-   Creating new entries that all users can see
-   Rating existing entries
-   Activity feed
-   Discovery page
-   Support for images
-   Admin dashboard
-   Friend list
-   Dark and Light themes
-   Mobile interface
-   Statistics on ratings
-   Infinity scroll
-   Account management

## Scripts

| Script    | Function                                   |
| --------- | ------------------------------------------ |
| npm start | Starts the frontend and reloads on changes |
| npm build | Builds the frontend for deployment         |

## List of environment variables for the frontend

| Environment variable               | Effect                                                                 |
| ---------------------------------- | ---------------------------------------------------------------------- |
| REACT_APP_SERVER_URL               | The address for the backend server. Defaults to http://localhost:4000/ |
| REACT_APP_CLOUDINARY_UPLOAD_PRESET | Cloudinary Upload Preset for storing images. Defaults to "Demo".       |
| REACT_APP_CLOUDINARY_CLOUD_NAME    | Cloudinary Cloud Name for storing images.                              |

## Deployment

Tastice frontend is currently deployed on Netlify, backend and Prisma server are both deployed on Heroku. This causes noticeable lag and long start up times due to the need for having two separate dynos. Each new commit to master triggers a deploy.

## Backend

[Backend repository on GitHub](https://github.com/villeheikkila/tastice-backend)
