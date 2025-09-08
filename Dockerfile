FROM node:20
WORKDIR /opt
ADD . /opt
RUN npm install
ENTRYPOINT npm run start
