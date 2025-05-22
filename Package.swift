// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Swiflow",
    platforms: [.iOS(.v17), .visionOS(.v1)],
    products: [.library(name: "Swiflow", targets: ["Swiflow"])],
    targets: [.target(name: "Swiflow")],
    swiftLanguageModes: [.v6]
)
