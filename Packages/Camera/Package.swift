// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Camera",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Camera",
            targets: ["Camera"]
        ),
    ],
    dependencies: [
        .package(name: "Extensions", path: "../Extensions"),
    ],
    targets: [
        .target(
            name: "Camera", dependencies: [
                .product(name: "Extensions", package: "Extensions"),
            ]
        ),
        .testTarget(
            name: "CameraTests",
            dependencies: ["Camera"]
        ),
    ]
)
