// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "EnvironmentModels",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "EnvironmentModels",
            targets: ["EnvironmentModels"]
        ),
    ],
    dependencies: [
        .package(name: "Repositories", path: "../Repositories"),
        .package(name: "Models", path: "../Models"),
        .package(name: "Extensions", path: "../Extensions"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.13.0")
        ),
        .package(
            url: "https://github.com/elai950/AlertToast.git", .upToNextMajor(from: "1.0.0")
        ),
    ],
    targets: [
        .target(
            name: "EnvironmentModels",
            dependencies: [
                .product(name: "Repositories", package: "Repositories"),
                .product(name: "Models", package: "Models"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "AlertToast", package: "AlertToast", condition: .when(platforms: [.iOS])),
            ]
        ),
        .testTarget(
            name: "EnvironmentModelsTests",
            dependencies: ["EnvironmentModels"]
        ),
    ]
)
