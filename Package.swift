// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PresentationModal",
    platforms: [
        .iOS(.v13)
       ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PresentationModal",
            targets: ["PresentationModal"]),
    ],
    dependencies: [
           // Dependencies declare other packages that this package depends on.
            .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
       ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PresentationModal",
            dependencies: ["SnapKit"],
            path: "Sources/"
        ),
        .testTarget(
            name: "PresentationModalTests",
            dependencies: ["PresentationModal"]),
    ]
)
