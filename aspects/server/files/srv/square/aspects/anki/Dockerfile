# Upstream example: https://github.com/ankitects/anki/tree/24.06.3/docs/syncserver
FROM rust:1.76-alpine3.19 AS builder

ARG ANKI_VERSION

RUN apk update && apk add --no-cache build-base protobuf && rm -rf /var/cache/apk/*
RUN cargo install --git https://github.com/ankitects/anki.git \
    --tag "${ANKI_VERSION}" \
    --locked \
    --root /anki-server \
    anki-sync-server

FROM alpine:3.19.1

RUN adduser -D -h /home/anki anki

COPY --from=builder /anki-server/bin/anki-sync-server /usr/local/bin/anki-sync-server

RUN apk update && apk add --no-cache bash && rm -rf /var/cache/apk/*

USER anki

ENV SYNC_PORT=8080

EXPOSE 8080

CMD ["anki-sync-server"]
