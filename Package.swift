// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Vistas",
     platforms: [
              .macOS(.v12),
              .iOS(.v16),
              .watchOS(.v10),
         ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Vistas",
            targets: ["Vistas"]),
    ],
	 dependencies: [
		.package(url: "https://github.com/ios-tooling/Suite", from: "1.0.137"),
		.package(url: "https://github.com/ios-tooling/CrossPlatformKit", from: "1.0.11"),
	 ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "Vistas", dependencies: ["Suite", "CrossPlatformKit"]),
    ]
)
