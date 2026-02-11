# Walrus Sites Portal — Koyeb free tier deployment (testnet)
# Serves the Awesome Sui Skills site via LANDING_PAGE_OID_B36

FROM oven/bun:1.2.5 AS base
WORKDIR /usr/src/app

# --- Build stage ---
FROM base AS install

RUN apt-get update -y && apt-get install -y ca-certificates

# Testnet configuration
ENV ENABLE_ALLOWLIST=false
ENV ENABLE_BLOCKLIST=false
ENV LANDING_PAGE_OID_B36=299vukmibirvize269z8ypoxk0uh4ls6gyjdt3yinkrlebumbj
ENV PORTAL_DOMAIN_NAME_LENGTH=51
ENV PREMIUM_RPC_URL_LIST=https://fullnode.testnet.sui.io:443
ENV RPC_URL_LIST=https://fullnode.testnet.sui.io:443
ENV SUINS_CLIENT_NETWORK=testnet
ENV AGGREGATOR_URL=https://aggregator.walrus-testnet.walrus.space
ENV SITE_PACKAGE=0xf99aee9f21493e1590e7e5a9aea6f343a1f381031a04a732724871fc294be799
ENV B36_DOMAIN_RESOLUTION_SUPPORT=true

RUN mkdir -p /temp/prod
COPY portal/package.json portal/bun.lock /temp/prod/
COPY portal/common /temp/prod/common
COPY portal/server /temp/prod/server
COPY portal/worker /temp/prod/worker
RUN cd /temp/prod && bun install --frozen-lockfile

# --- Production stage ---
FROM base AS release
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=install /temp/prod/package.json .
COPY --from=install /temp/prod/common ./common
COPY --from=install /temp/prod/server ./server

USER bun
EXPOSE 3000/tcp
ENV NODE_ENV=production
CMD [ "bun", "run", "server" ]
