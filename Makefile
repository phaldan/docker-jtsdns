.PHONY : all build update run clear logs upgrade
UPGRADE_SCRIPT=upgrade.sh
IMAGE=phaldan/jtsdns
CONTAINER=jtsdns
DOCKER=$(shell which docker.io || which docker)
MAKE=make -s

all: build

build:
	$(DOCKER) build $(ARGS)  \
		--build-arg JTSDNS_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-t $(IMAGE):$(VERSION) .

update:
	sed -n 's/^FROM //p' Dockerfile | awk '{print $$1}' | xargs -t -n 1 $(DOCKER) pull
	$(MAKE) build

run:
	$(DOCKER) network create --driver bridge $(CONTAINER)
	$(DOCKER) run -d \
		--name=$(CONTAINER)_db \
		--network=$(CONTAINER) \
		-e MYSQL_ROOT_PASSWORD=changeme \
		-e MYSQL_DATABASE=$(CONTAINER)\
		mariadb:10
	$(DOCKER) run -d \
		--name=$(CONTAINER) \
		--network=$(CONTAINER) \
		-e JTSDNS_MYSQL_TIMEOUT=30 \
    -e JTSDNS_MYSQL_HOST=jtsdns_db \
    -e JTSDNS_MYSQL_USER=root \
    -e JTSDNS_MYSQL_PASSWORD=changeme \
    -e JTSDNS_MYSQL_DATABASE=jtsdns \
		-p 41144:41144 \
		$(IMAGE):$(VERSION)

clear:
	$(DOCKER) rm -f $(CONTAINER) $(CONTAINER)_db; $(DOCKER) network rm $(CONTAINER)

logs:
	$(DOCKER) logs $(CONTAINER)

release: update
	curl -o $(UPGRADE_SCRIPT) https://raw.githubusercontent.com/phaldan/docker-tags-upgrade/master/$(UPGRADE_SCRIPT)
	chmod +x $(UPGRADE_SCRIPT)
	./$(UPGRADE_SCRIPT) "$(IMAGE)" "$(VERSION)"

