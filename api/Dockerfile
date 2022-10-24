FROM node:current-alpine3.10
WORKDIR /api

COPY package.json ./
COPY package-lock.json ./
RUN apk add --no-cache python make g++
RUN npm install --loglevel warn

EXPOSE 4000
CMD [ "npm", "start" ]