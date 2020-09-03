FROM node:latest
WORKDIR /service
ARG SERVICE_DIR=.
COPY ${SERVICE_DIR}/package.json \
    ${SERVICE_DIR}/package-lock.* \
    /service/
RUN npm install --loglevel warn
EXPOSE 3000
CMD [ "npm", "start" ]