watch:
	node_modules/.bin/coffee -wclo lib source

test:
	NODE_ENV=test mocha --compilers coffee:coffee-script --require coffee-script --colors

.PHONY: test