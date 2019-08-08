# ![tastice](https://fontmeme.com/permalink/190704/0daa2ab57e001e0aa2002608810c7a69.png)

Application for keeping track of things you have recently tasted. It mimics the functionality and the interface of the popular tasting apps such as Untapped and Vivino. Unlike the previously mentioned apps however, it supports arbitrary types of foods and drinks such as sodas, coffees or anything else you can imagine.

## Technology Stack

The application is build using React, Apollo, Material-UI and TypeScript on the frontend as well as Node, Prisma and TypeScript on the backend. Data is stored on a PostgreSQL database which is managed by Prisma. All communication between the frontend and the backend happens using GraphQL. Frontend makes use of Cloudinary as image storage.

## Features

- Creating new entries that all users can see
- Rating existing entries
- Uploading images on both products and check-ins.
- Responsive interface
- Admin dashboard for managing the data
- Friend list
