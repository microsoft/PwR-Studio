FROM mcr.microsoft.com/devcontainers/typescript-node:dev-18-buster

WORKDIR /code/studio

COPY studio/package*.json .

RUN npm install

COPY studio .

EXPOSE 4173

CMD ["npm", "run", "dev"]
