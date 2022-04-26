.PHONY: build push

TAG_REGISTRY = gitlab.dany.nycnet:5050/it-devs/dany_dashboard:`date +%Y-%m-%d`

build: Dockerfile
	docker build -t $(TAG_REGISTRY) .

push: build
	docker push $(TAG_REGISTRY)
