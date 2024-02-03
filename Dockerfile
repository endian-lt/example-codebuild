# Use latest LTS Node runtime
FROM node:20-slim

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

ENV NAME World

CMD [ "node", "app.js" ]
