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
IMAGES += ubuntu-bionic-dev
IMAGES += ubuntu-bionic-debuild
IMAGES += ubuntu-artful-dev
IMAGES += ubuntu-artful-debuild
IMAGES += ubuntu-xenial-dev
IMAGES += ubuntu-xenial-debuild
IMAGES += ubuntu-trusty-dev
IMAGES += ubuntu-trusty-debuild
IMAGES += raspbian-stretch-dev
IMAGES += raspbian-stretch-debuild

all: $(IMAGES)

define IMAGE_NAME =
$(word 1,$(subst -, ,$1))-$(word 3,$(subst -, ,$1)):$(word 2,$(subst -, ,$1))
endef

define DOCKER_BUILD_templ =
docker build $(BUILD_ARGS) -t "$(IMAGE_ROOT)/$(call IMAGE_NAME,$1)" $1
endef

debian-stretch-dev:
	$(call DOCKER_BUILD_templ,$@)

debian-stretch-debuild:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-bionic-dev:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-bionic-debuild:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-artful-dev:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-artful-debuild:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-xenial-dev:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-xenial-debuild:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-trusty-dev:
	$(call DOCKER_BUILD_templ,$@)

ubuntu-trusty-debuild:
	$(call DOCKER_BUILD_templ,$@)

raspbian-stretch-dev:
	$(call DOCKER_BUILD_templ,$@)

raspbian-stretch-debuild:
	$(call DOCKER_BUILD_templ,$@)

docker-clean:
	@IMGS=$$(docker images | grep "^<none>" | awk '{print $$3}'); \
		 [ -n "$$IMGS" ] && docker rmi $$IMGS || true

.PHONY: $(IMAGES)
.NOTPARALLEL:
