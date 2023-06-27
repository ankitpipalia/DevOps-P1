FROM node:16-alpine

WORKDIR /app
COPY package.json package.json
RUN npm install
RUN npm install -g pm2
COPY . .

CMD pm2 start index.js -i 4