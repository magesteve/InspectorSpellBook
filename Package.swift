// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InspectorSpellBook",
    products: [
        .library(
            name: "InspectorSpellBook",
            targets: ["InspectorSpellBook"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "InspectorSpellBook",
            dependencies: []),
        .testTarget(
            name: "InspectorSpellBookTests",
            dependencies: ["InspectorSpellBook"]),
    ]
)
