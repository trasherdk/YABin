FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock src/lib/server/prisma/schema.prisma ./

RUN yarn install --frozen-lockfile

COPY . .

RUN npm run build
RUN npm prune --production

FROM node:18-alpine

WORKDIR /app

RUN npm install -g prisma pm2

COPY scripts/ scripts/
COPY package.json yarn.lock process.yml src/lib/server/prisma/schema.prisma ./

RUN yarn install --frozen-lockfile --production

COPY --from=builder /app/build build/

EXPOSE 3000

ENV NODE_ENV=production

CMD [ "./scripts/run.sh" ]
