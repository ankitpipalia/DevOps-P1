FROM node:16-alpine AS build

WORKDIR /app
COPY package.json package.json
RUN npm install
COPY . .
RUN npm run-script build

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx","-g","daemon off;"]
