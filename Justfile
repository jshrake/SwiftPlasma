init:
    just deps/c-plasma/clean
    just deps/c-plasma/xcframework

clean:
    rm -rf .build

build: init
	swift build

test:
	swift test