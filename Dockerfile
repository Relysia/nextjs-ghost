FROM arm64v8/node:current-alpine AS base
WORKDIR /base
COPY package*.json ./
RUN npm install
COPY . .

FROM base AS build
LABEL com.centurylinklabs.watchtower.enable="true"
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV=production
WORKDIR /build
COPY --from=base /base ./
RUN npm run build

FROM arm64v8/node:current-alpine AS production
LABEL com.centurylinklabs.watchtower.enable="true"
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /build/package*.json ./
COPY --from=build /build/.next ./.next
COPY --from=build /build/public ./public
RUN npm install next

EXPOSE 3090
CMD npm run start
