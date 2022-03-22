LLVM_CONFIG ?= llvm-config
CGO_CFLAGS=
CGO_LDFLAGS=$(strip -L$(shell ${LLVM_CONFIG} --libdir) -Wl,-rpath,$(shell ${LLVM_CONFIG} --libdir))

go-clang-gen-$*: build/%
build/%:
	CGO_CFLAGS='${CGO_CFLAGS}' CGO_LDFLAGS='${CGO_LDFLAGS}' go build -v -x -o go-clang-gen-$* ./cmd/go-clang-gen

gen/%:
	cd $(shell go env GOPATH)/src/github.com/go-clang/clang-v$*; \
		$(shell go env GOPATH)/src/github.com/go-clang/gen/go-clang-gen-$* -llvm-root=$(shell ${LLVM_CONFIG} --prefix)

GOLANG_VERSION=1.18
TARGET=llvm

DOCKER_FLAGS:=
ifeq ($V,1)
	DOCKER_FLAGS+=--progress=plain
endif

.PHONY: docker/build/4 docker/build/5 docker/build/6 docker/build/7 docker/build/8 docker/build/9 docker/build/10
docker/build/4 docker/build/5 docker/build/6: UBUNTU_VERSION=18.04
docker/build/7 docker/build/8 docker/build/9 docker/build/10: UBUNTU_VERSION=20.04
docker/build/4 docker/build/5 docker/build/6 docker/build/7 docker/build/8 docker/build/9 docker/build/10:
	docker image build --builder=default --rm ${DOCKER_FLAGS} --target=${TARGET} --build-arg UBUNTU_VERSION=${UBUNTU_VERSION} --build-arg LLVM_VERSION=${@F} --build-arg GOLANG_VERSION=${GOLANG_VERSION} -t ghcr.io/go-clang/base:${@F} -f ./base/llvm-4-10.dockerfile ./base

.PHONY: docker/build/11 docker/build/12 docker/build/13 docker/build/14
docker/build/11 docker/build/12 docker/build/13 docker/build/14:
	docker image build --builder=default --rm ${DOCKER_FLAGS} --target=${TARGET} --build-arg LLVM_VERSION=${@F} --build-arg GOLANG_VERSION=${GOLANG_VERSION} -t ghcr.io/go-clang/base:${@F} -f ./base/llvm-11-14.dockerfile ./base

docker/gen/%: TARGET=gen
docker/gen/%: docker/build/%
	docker container run --rm -it --mount type=bind,src=$(shell go env GOPATH)/src/github.com/go-clang/clang-v$*,dst=/go/src/github.com/go-clang/clang-v$* -w /go/src/github.com/go-clang/gen goclang/base:$* make gen/$*
