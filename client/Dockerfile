FROM node:current-alpine3.10
WORKDIR /client

COPY package.json ./
COPY package-lock.json ./
RUN npm install --legacy-peer-deps --loglevel warn
RUN npm i -g prettier

EXPOSE 3000
CMD [ "npm", "start" ]