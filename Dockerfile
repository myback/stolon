FROM --platform=linux/amd64 golang:1.16-buster AS builder

WORKDIR /stolon
ARG BUILD_COMMIT=4bb4107523c2db09fa711c1d96ddfe33bacf405c

## Fetch Stolon repository
RUN git init \
    && git remote add origin https://github.com/sorintlab/stolon.git \
    && git fetch --depth 1 origin ${BUILD_COMMIT} \
    && git reset --hard FETCH_HEAD

RUN go mod download \
    && make


FROM --platform=linux/amd64 postgres:14.8

COPY checks.sh /
COPY --from=builder /stolon/bin/ /usr/local/bin/

RUN groupadd -g 1000 stolon \
    && useradd -u 1000 -g 1000 stolon \
    && chmod +x /checks.sh \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y jq \
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
