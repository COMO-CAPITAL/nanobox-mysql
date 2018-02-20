all: build publish

build: build56

publish: publish56

build56:
	docker build -t comocapital/nanobox-mysql:5.6 5.6

publish56:
	docker publish comocapital/nanobox-mysql:5.6
