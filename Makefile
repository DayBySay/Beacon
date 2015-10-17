NPM?=$(shell which npm)
NODE?=$(shell which node)

all:

install:
	$(NPM) install bleacon

receiver:
	$(NODE) receive.js
