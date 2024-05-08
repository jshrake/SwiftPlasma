// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftPlasma",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "SwiftPlasma",
      targets: [
        "Plasma", "SwiftPlasma",
      ])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "SwiftPlasma",
      dependencies: [
        .byName(name: "Plasma"), .byName(name: "Yaml", condition: .when(platforms: [.macOS])),
        .product(name: "Logging", package: "swift-log"),
      ]
    ),
    .binaryTarget(
      name: "Plasma",
      path: "./deps/c-plasma/build/install/xcframework/plasma.xcframework"
    ),
    .systemLibrary(
      name: "Yaml",
      pkgConfig: "yaml-0.1",
      providers: [.apt(["libyaml"]), .brew(["libyaml"])]),
    .testTarget(
      name: "SwiftPlasmaTests",
      dependencies: ["SwiftPlasma", .product(name: "Logging", package: "swift-log")]
    ),
  ]
)
