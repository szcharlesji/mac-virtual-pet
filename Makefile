all: build run

build:
	swift build

copy-resources:
	mkdir -p .build/debug/Resources/pet
	cp Sources/mac-virtual-pet/Resources/pet/*.gif .build/debug/Resources/pet/

run: copy-resources
	./.build/debug/mac-virtual-pet

.PHONY: all build copy-resources run 
