# base node image
FROM node:16-bullseye-slim as base

RUN mkdir /app
WORKDIR /app

ADD package.json package-lock.json ./
RUN npm install

ADD . .
RUN npm run build

CMD ["npm", "run", "start"]
