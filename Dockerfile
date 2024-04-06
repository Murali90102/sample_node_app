FROM lts-alpine3.18
WORKDIR /app
COPY *.json .
RUN npm install

CMD [ "node", "app.js" ]