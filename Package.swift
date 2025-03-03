// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDSVisionExtension",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SDSVisionExtension",
            targets: ["SDSVisionExtension"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/tyagishi/SDSCGExtension", from: "1.3.3"),
        .package(url: "https://github.com/tyagishi/SDSViewExtension", from: "4.2.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.56.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SDSVisionExtension",
            dependencies: ["SDSCGExtension", "SDSViewExtension"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ])
//        .testTarget(
//            name: "SDSVisionExtensionTests",
//            dependencies: ["SDSVisionExtension"]),
    ]
)
