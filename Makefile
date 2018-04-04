HTTP_PROXY ?= ${http_proxy}
HTTPS_PROXY ?= ${https_proxy}
DOCKER_HTTP_PROXY ?= $(if ${docker_http_proxy},${docker_http_proxy},$(HTTP_PROXY))
DOCKER_HTTPS_PROXY ?= $(if ${docker_https_proxy},${docker_https_proxy},$(HTTPS_PROXY))

ifneq ($(DOCKER_HTTP_PROXY),)
BUILD_ARGS += --build-arg "http_proxy=${DOCKER_HTTP_PROXY}"
endif

ifneq ($(DOCKER_HTTPS_PROXY),)
BUILD_ARGS += --build-arg "https_proxy=$(DOCKER_HTTPS_PROXY)"
endif

IMAGE_ROOT = lboulard

IMAGES += debian-stretch-dev
IMAGES += debian-stretch-debuild
IMAGES += ubuntu-xenial-dev
IMAGES += ubuntu-xenial-debuild
IMAGES += ubuntu-trusty-dev
IMAGES += ubuntu-trusty-debuild
IMAGES += raspbian-stretch-dev
IMAGES += raspbian-stretch-debuild

all: $(IMAGES)

debian-stretch-dev:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

debian-stretch-debuild:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

ubuntu-xenial-dev:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

ubuntu-xenial-debuild:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

ubuntu-trusty-dev:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

ubuntu-trusty-debuild:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

raspbian-stretch-dev:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

raspbian-stretch-debuild:
	D=$(word 1,$(subst -, ,$@)) R=$(word 2,$(subst -, ,$@)) K=$(word 3,$(subst -, ,$@)) \
	 IMG="$(IMAGE_ROOT)/$${D}-$${K}:$${R}"; \
	docker build $(BUILD_ARGS) -t "$$IMG" $@

docker-clean:
	@IMGS=$$(docker images | grep "^<none>" | awk '{print $$3}'); \
		 [ -n "$$IMGS" ] && docker rmi $$IMGS || true

.PHONY: $(IMAGES)
.NOTPARALLEL:
