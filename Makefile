dirname = certs-out-$(shell date +%Y-%m-%d-%H-%M-%S)

build:
	docker build -t test-certificate-generator .

generate: build
	mkdir ${dirname}
	docker run --rm  -v=$(CURDIR)/${dirname}:/out -e USERID=$(shell id -u) -e GROUPID=$(shell id -g) -e CERTPREFIX=$$CERTPREFIX test-certificate-generator sh -c 'generate-certs.sh && set-owner.sh'

