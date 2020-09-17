FROM alpine:3

RUN apk update \
    && apk upgrade \
    && apk add \
    git \
    curl \
    nodejs \
    yarn
    
COPY install.sh /

RUN chmod +x /install.sh

ENV API_KEY= \
    UI_ORIGIN= \
    REACT_APP_API_URL=

EXPOSE 3000 4000

CMD ["/install.sh"]
