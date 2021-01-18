FROM alpine:3.13.0
LABEL maintainer="Marcelo Liberato <mliberato@gmail.com>"

RUN apk update \
 && apk add bash \
 && apk add openssl \
 && apk add curl \
 && apk add jq \
 && rm -rf /var/cache/apk/*

COPY validate-x5t.sh /

ENTRYPOINT ["/validate-x5t.sh"]
