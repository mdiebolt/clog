cli:
	mkdir -p bin
	echo "#!/usr/bin/env node" > bin/clog
	node_modules/.bin/coffee -bscl < cli/clog.coffee.md >> bin/clog
	chmod +x bin/clog

watch:
	node_modules/.bin/coffee -wclo lib source

test:
	NODE_ENV=test mocha --compilers coffee:coffee-script --require coffee-script --colors

.PHONY: test cli