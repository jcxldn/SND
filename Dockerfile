# build stage
FROM golang:1.25-alpine AS builder

ARG GOPATH=/tmp/go

RUN apk --no-cache add libcap2 libcap-setcap upx git && \
    go install github.com/goreleaser/goreleaser/v2@v2.12.7

WORKDIR /root/snd
COPY . /root/snd/
RUN  /tmp/go/bin/goreleaser build --config contrib/goreleaser/goreleaser.yaml --single-target --id "snd" --output "dist/snd" --snapshot --clean

# production stage
FROM scratch
LABEL org.opencontainers.image.authors="docker@public.swineson.me"

COPY --from=builder /root/snd/dist/snd /usr/local/bin/
COPY --from=builder /root/snd/contrib/config/config.toml /etc/snd/
# nope
# See: https://github.com/moby/moby/issues/8460
# USER nobody:nogroup

EXPOSE 53/tcp 53/udp
ENTRYPOINT [ "/usr/local/bin/snd" ]
CMD [ "-config",  "/etc/snd/config.toml" ]
