FROM node:22-bullseye-slim AS build

WORKDIR /app

COPY ./ /app

RUN npm install

RUN npm run lint
RUN npm run test:cov
RUN npm run build

FROM node:22-alpine AS runner

WORKDIR /app

COPY --from=build /app/dist /app/dist
COPY --from=build /app/package*.json /app
RUN npm install --only=production

CMD ["node", "dist/main"]