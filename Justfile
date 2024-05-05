init:
    just deps/c-plasma/clean
    just deps/c-plasma/xcframework

clean:
    rm -rf .build

build:
	swift build

test:
	swift test