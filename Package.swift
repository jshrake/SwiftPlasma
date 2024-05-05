// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPlasma",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftPlasma",
            targets: ["Plasma", "SwiftPlasma"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Plasma",
            path: "./deps/c-plasma/build/install/xcframework/plasma.xcframework"
        ),
        .target(
            name: "SwiftPlasma",
            dependencies: ["Plasma"],
            swiftSettings: [
                .unsafeFlags(["-I./deps/c-plasma/build/install/macos/include"])
            ]
            ),
        .testTarget(
            name: "SwiftPlasmaTests",
            dependencies: ["SwiftPlasma"],
            swiftSettings: [
                .unsafeFlags(["-I./deps/c-plasma/build/install/macos/include"])
            ])
    ]
)
