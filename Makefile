LLVM_CONFIG ?= llvm-config
CGO_CFLAGS=
CGO_LDFLAGS=$(strip -L$(shell ${LLVM_CONFIG} --libdir) -Wl,-rpath,$(shell ${LLVM_CONFIG} --libdir))

go-clang-gen-$*: build/%
build/%:
	CGO_CFLAGS='${CGO_CFLAGS}' CGO_LDFLAGS='${CGO_LDFLAGS}' go build -v -x -o go-clang-gen-$* ./cmd/go-clang-gen

gen/%:
	cd $(shell go env GOPATH)/src/github.com/go-clang/clang-v$*; \
		$(shell go env GOPATH)/src/github.com/go-clang/gen/go-clang-gen-$* -llvm-root=$(shell ${LLVM_CONFIG} --prefix)

GOLANG_VERSION=1.19
TARGET=llvm

DOCKER_FLAGS=--rm --pull --label=org.opencontainers.image.revision=$(shell git rev-parse --verify HEAD | cut -c -12)
ifeq ($V,1)
	DOCKER_FLAGS+=--progress=plain
endif

define docker_build_4_10
docker builder build $(strip ${DOCKER_FLAGS}) --target=${TARGET} --build-arg UBUNTU_VERSION=${UBUNTU_VERSION} --build-arg LLVM_VERSION=${1} --build-arg GOLANG_VERSION=${GOLANG_VERSION} --output=type=docker -t ghcr.io/go-clang/base:${2} -f ${3} ./base
endef

define docker_build_11_14
docker builder build $(strip ${DOCKER_FLAGS}) --target=${TARGET} --build-arg LLVM_VERSION=${1} --build-arg GOLANG_VERSION=${GOLANG_VERSION} --output=type=docker -t ghcr.io/go-clang/base:${2} -f ${3} ./base
endef

.PHONY: docker/build/4.0.0
docker/build/4.0.0: UBUNTU_VERSION=18.04
docker/build/4.0.0:
	$(call docker_build_4_10,4,4.0.0,./base/llvm-4-10.dockerfile)

.PHONY: docker/build/5.0.0
docker/build/5.0.0: UBUNTU_VERSION=18.04
docker/build/5.0.0:
	$(call docker_build_4_10,5,5.0.0,./base/llvm-4-10.dockerfile)

.PHONY: docker/build/6.0.0
docker/build/6.0.0: UBUNTU_VERSION=18.04
docker/build/6.0.0:
	$(call docker_build_4_10,6,6.0.0,./base/llvm-4-10.dockerfile)

.PHONY: docker/build/7.0.0
docker/build/7.0.0: UBUNTU_VERSION=20.04
docker/build/7.0.0:
	$(call docker_build_4_10,7,7.0.0,./base/llvm-4-10.dockerfile)

.PHONY: docker/build/8.0.0
docker/build/8.0.0: UBUNTU_VERSION=20.04
docker/build/8.0.0:
	$(call docker_build_4_10,8,8.0.0,./base/llvm-4-10.dockerfile)

.PHONY: docker/build/9.0.0
docker/build/9.0.0: UBUNTU_VERSION=20.04
docker/build/9.0.0:
	$(call docker_build_4_10,9,9.0.0,./base/llvm-4-10.dockerfile)

.PHONY: docker/build/10.0.0
docker/build/10.0.0: UBUNTU_VERSION=20.04
docker/build/10.0.0:
	$(call docker_build_4_10,10,10.0.0,./base/llvm-4-10.dockerfile)

.PHONY: docker/build/11.1.0
docker/build/11.1.0:
	$(call docker_build_11_14,11,11.1.0,./base/llvm-11-14.dockerfile)

.PHONY: docker/build/12.0.1
docker/build/12.0.1:
	$(call docker_build_11_14,12,12.0.1,./base/llvm-11-14.dockerfile)

.PHONY: docker/build/13.0.1
docker/build/13.0.1:
	$(call docker_build_11_14,13,13.0.1,./base/llvm-11-14.dockerfile)

.PHONY: docker/build/14.0.6
docker/build/14.0.6:
	$(call docker_build_11_14,14,14.0.6,./base/llvm-11-14.dockerfile)
