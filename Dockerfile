FROM alpine

RUN apk add --no-cache curl ghc musl-dev zlib-dev linux-headers postgresql-dev gmp-dev

RUN curl -sSL https://get.haskellstack.org/ | sh

ARG POSTGREST_VERSION="0.4.3.0"

RUN curl -SLo postgrest.tar.gz https://github.com/begriffs/postgrest/archive/v${POSTGREST_VERSION}.tar.gz && \
	tar -xzvf postgrest.tar.gz

WORKDIR postgrest-${POSTGREST_VERSION}

RUN stack build --system-ghc --copy-bins --local-bin-path /usr/local/bin


FROM alpine

RUN apk add --no-cache libpq gmp libffi ca-certificates

COPY --from=0 /usr/local/bin/postgrest /usr/local/bin/postgrest

COPY postgrest.conf /etc/postgrest.conf

ENV PGRST_DB_URI= \
    PGRST_DB_SCHEMA=public \
    PGRST_DB_ANON_ROLE= \
    PGRST_DB_POOL=100 \
    PGRST_SERVER_HOST=*4 \
    PGRST_SERVER_PORT=3000 \
    PGRST_SERVER_PROXY_URI= \
    PGRST_JWT_SECRET= \
    PGRST_SECRET_IS_BASE64=false \
    PGRST_JWT_AUD= \
    PGRST_MAX_ROWS= \
    PGRST_PRE_REQUEST=

# PostgREST reads /etc/postgrest.conf so map the configuration
# file in when you run this container
CMD exec postgrest /etc/postgrest.conf

EXPOSE 3000
