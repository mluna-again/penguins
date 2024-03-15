FROM node:21-alpine3.18

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install

COPY .babelrc .babelrc
COPY config/ config/
COPY data/ data/
COPY ecosystem.config.js ecosystem.config.js
COPY jsconfig.json jsconfig.json
COPY utils/ utils/
COPY src/ src/

RUN npm run secret-gen

CMD ["npm", "run", "dev"]
