// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fluxful",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .watchOS(.v4),
        .tvOS(.v11)
    ],
    products: [
        .library(name: "Fluxful",
                 targets: ["Fluxful"]),
        .library(name: "ReactiveFluxful",
                 targets: ["ReactiveFluxful"]),
    ],
    targets: [
        .target(name: "Fluxful",
                dependencies: [],
                path: "Fluxful"),
        .target(name: "ReactiveFluxful",
                dependencies: ["Fluxful"],
                path: "ReactiveFluxful"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
