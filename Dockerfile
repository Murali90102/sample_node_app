FROM node:lts-alpine3.18
WORKDIR /app
COPY *.json .
RUN npm install

COPY app.js .
CMD [ "node", "app.js" ]