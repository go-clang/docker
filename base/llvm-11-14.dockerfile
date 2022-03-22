# syntax=docker/dockerfile:1.4

FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS apt
ENV DEBIAN_FRONTEND=noninteractive

ARG LLVM_VERSION
RUN set -eux && \
	apt-get update && \
	if [ $LLVM_VERSION = '14' ]; then \
		apt-get install -y --no-install-recommends \
			ca-certificates \
			gnupg \
			wget && \
		echo 'deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-14 main' | tee /etc/apt/sources.list.d/llvm.list && \
		echo 'deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-14 main' | tee -a /etc/apt/sources.list.d/llvm.list && \
		wget -q -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
		apt-get update; \
	fi && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		git \
		make \
		pkg-config \
		\
		llvm-${LLVM_VERSION} \
		clang-${LLVM_VERSION} \
		libclang-${LLVM_VERSION}-dev \
	&& \
	ln -s /usr/bin/clang-${LLVM_VERSION} /usr/bin/clang && \
	ln -s /usr/bin/clang++-${LLVM_VERSION} /usr/bin/clang++ && \
	ln -s /usr/bin/llvm-config-${LLVM_VERSION} /usr/bin/llvm-config && \
	\
	rm -rf \
		 /var/cache/debconf/* \
		 /var/lib/apt/lists/* \
		 /var/log/* \
		 /tmp/* \
		 /var/tmp/*

FROM --platform=$BUILDPLATFORM apt AS base
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++

FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS golang
ARG GOLANG_VERSION
RUN set -ex && \
	apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
	&& \
	curl -fsS "https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz" | tar -xzf - -C /usr/local

FROM --platform=$BUILDPLATFORM base AS llvm
COPY --from=golang /usr/local/go /usr/local/go
ENV GOPATH=/go
ENV PATH=${GOPATH}/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

LABEL org.opencontainers.image.authors   "The go-clang authors"
LABEL org.opencontainers.image.url       "https://github.com/go-clang/docker"
LABEL org.opencontainers.image.source    "https://github.com/go-clang/docker"
LABEL org.opencontainers.image.licenses  "BSD-3-Clause"
