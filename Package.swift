// swift-tools-version: 5.11

import PackageDescription

let package = Package(
    name: "Pilot",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Pilot",
            targets: ["Pilot"])
    ],
    targets: [
        .target(
            name: "Pilot"
        ),
    ]
)
