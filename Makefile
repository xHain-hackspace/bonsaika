MIX_ENV ?= dev

all: build

setup:
	mix setup

build: setup
	mix compile

release: build
	mix release --overwrite

run:
	iex -S mix

release_run: release
	_build/$(MIX_ENV)/rel/bonsaika/bin/bonsaika start
