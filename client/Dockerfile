FROM node:current-alpine3.10
WORKDIR /client

COPY package.json ./
COPY package-lock.json ./
RUN npm install --loglevel warn

EXPOSE 3000
CMD [ "npm", "start" ]