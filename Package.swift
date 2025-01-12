// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RRuleKit",
  platforms: [.iOS(.v18), .macCatalyst(.v15), .macOS(.v15), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "RRuleKit",
      targets: ["RRuleKit"]
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "RRuleKit"
    ),
    .testTarget(
      name: "RRuleKitTests",
      dependencies: ["RRuleKit"]
    ),
  ]
)
