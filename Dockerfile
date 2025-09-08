FROM node:20
WORKDIR /opt
COPY . /opt
RUN npm install
ENTRYPOINT npm run start
