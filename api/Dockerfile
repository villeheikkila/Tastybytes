FROM node:current
WORKDIR /service
ARG SERVICE_DIR=.
COPY /package.json \
    ./package-lock.* \
    /service/
RUN npm install --loglevel warn
EXPOSE 4000
CMD [ "npm", "start" ]