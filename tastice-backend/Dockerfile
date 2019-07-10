FROM node:11.15.0-stretch
RUN npm install -g --unsafe-perm prisma

RUN mkdir /app
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

COPY package.json /app/package.json
COPY prisma ./prisma/

RUN npm install
COPY . /app

CMD [ "npm", "start" ]