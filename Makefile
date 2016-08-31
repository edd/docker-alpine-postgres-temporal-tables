build:
	docker build -t alpine-postgres --rm=true .

debug:
	docker run -i -t --entrypoint=sh alpine-postgres

run:
	docker run -i -P alpine-postgres

run-local:
	docker run -d -p 127.0.0.1:5432:5432 alpine-postgres
