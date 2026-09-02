# To refresh, copy the Digest from
# `docker buildx imagetools inspect cgr.dev/chainguard/wolfi-base:latest`
ARG WOLFI_BASE=cgr.dev/chainguard/wolfi-base@sha256:7e62cecd3c5712dba6e52c5260afb8f9d7a23b9bbcdd26ad7508a811e74b766d

FROM ${WOLFI_BASE} AS builder

# build-base bundles gcc/g++, make, glibc-dev and the standard
# linker. Poly/ML's runtime is C++; build-base includes g++.
RUN apk add --no-cache build-base curl

RUN curl -LO https://github.com/polyml/polyml/archive/v5.9.2.tar.gz && \
    tar xf v5.9.2.tar.gz && \
    cd polyml-5.9.2 && ./configure --prefix=/tmp && make && make install


FROM ${WOLFI_BASE}

# bash for run.sh, jq for JSON output, libgcc/libstdc++ for the
# Poly/ML runtime, coreutils for the cat/mkdir helpers run.sh uses.
RUN apk add --no-cache bash coreutils jq libgcc libstdc++

COPY --from=builder /tmp/ /usr/

COPY . /opt/test-runner
WORKDIR /opt/test-runner
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
