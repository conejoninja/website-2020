push:
	git push

generate:
	ls -lha /var/website
	du -hs *
	hugo
	du -hs *

preview:
	hugo server --bind 0.0.0.0

TS := $(date)
ifdef GH_TOKEN
PUBLIC_URL = https://$(GH_TOKEN)@github.com/goconca/website-2020.git
else
PUBLIC_URL = git@github.com:goconca/website-2020.git
endif
public:
	git clone -b gh-pages $(PUBLIC_URL) public

deploy: public
	cd public \
	&& git add  . \
	&& (git commit -a -m "Website updated at $(shell date)"  || echo "Nothing to commit") \
	&& git push \
	&& cd ..

USER=$(shell whoami)
UID=$(shell id -u $(USER))
docker-image:
	docker build -t website-builder .

docker-rm:
	docker kill website-builder || echo "Not found"
	docker rm website-builder || echo "Not found"

generate-using-docker: docker-image docker-rm public submodules
	docker run --rm -t -v $(shell pwd):/var/website --name website-builder website-builder make generate

cleanup-public:
	rm -f public/style.*.css

deploy-using-docker: public
	make cleanup-public
	make generate-using-docker
	make deploy
	make push

setup-git:
	git config --global user.email "$(GIT_EMAIL)"
	git config --global user.name "$(GIT_NAME)"

preview-using-docker: docker-image docker-rm public sudmodules
	docker run --rm -t -v $(shell pwd):/var/website -p 1313:1313 --name website-builder website-builder make preview

debug-using-docker: docker-image docker-rm public submodules
	docker run --rm -ti -v $(shell pwd):/var/website -p 1313:1313 --name website-builder website-builder bash

sudmodules:
	git submodule update --init

clean:
	rm resources/_gen/ -rf

submodules:
	git submodule update --init
