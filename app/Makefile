ifneq (,$(wildcard ./.env))
    include .env
    export
endif

DC1=docker-compose -p dashboard_dev
DC2=docker-compose -p dashboard_zengj
DC3=docker-compose -p dashboard_stetsons
DC4=docker-compose -p dashboard_smollerm

REMOTE_REGISTRY=data.manhattanda.org:5000/dany_dashboard

.PHONY: build run deploy run2 run3 run4 test_version

run:
	$(DC1) -f docker-compose.yml up -d --build
	$(DC1) logs -f

# Check app version against current date. Fail if they do not match.
test_version:
	@if [ $(APP_VERSION) != "`date +%Y-%m-%d`" ]; then \
		echo "APP_VERSION does not match date!"; \
		exit 1; \
	fi
	@exit 0

deploy: test_version build
	docker-compose build --pull
	docker tag gitlab.dany.nycnet:5050/it-devs/dany_dashboard:${APP_VERSION} data.manhattanda.org:5000/dany_dashboard:${APP_VERSION}
	docker-compose push
	docker push data.manhattanda.org:5000/dany_dashboard:${APP_VERSION}
	scp ".env" "danydash:./dashboard/.env"
	ssh danydash "cd dashboard && docker-compose pull && docker-compose up -d shiny"

run2:
	$(DC2) -f docker-compose.yml -f docker-compose2.yml up -d --build
	$(DC2) logs -f

run3:
	$(DC3) -f docker-compose.yml -f docker-compose3.yml up -d --build
	$(DC3) logs -f

run4:
	$(DC4) -f docker-compose.yml -f docker-compose4.yml up -d --build
	$(DC4) logs -f

stage:
	docker build -t ${REMOTE_REGISTRY}:${APP_VERSION_STAGE} app
	docker push ${REMOTE_REGISTRY}:${APP_VERSION_STAGE}
	scp ".env" "danydash:./dashboard/.env"
	ssh danydash "cd dashboard && docker-compose pull && docker-compose up -d staging"
