// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swiflow",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Swiflow",
            targets: ["Swiflow"]),
    ],
    targets: [
        .target(
            name: "Swiflow"),
    ]
)
