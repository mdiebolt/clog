build:
	coffee -clo lib src

watch:
	coffee -wclo lib src

test:
	NODE_ENV=test mocha --compilers coffee:coffee-script --require coffee-script --colors

.PHONY: test