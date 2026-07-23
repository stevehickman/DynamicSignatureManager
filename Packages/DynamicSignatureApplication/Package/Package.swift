// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    name: "DynamicSignatureApplication",

    platforms: [
        .macOS(.v15)
    ],

    products: [
        .library(
            name: "DynamicSignatureApplication",
            targets:
                ["DynamicSignatureApplication"]
        )
    ],

    dependencies: [

        .package(
            path:
            "../DynamicSignatureDomain"
        ),

        .package(
            path:
            "../DynamicSignatureInfrastructure"
        )
    ],

    targets: [

        .target(
            name:
            "DynamicSignatureApplication",

            dependencies: [

                "DynamicSignatureDomain",

                "DynamicSignatureInfrastructure"
            ]
        ),

        .testTarget(
            name:
            "DynamicSignatureApplicationTests",

            dependencies:
            [
                "DynamicSignatureApplication"
            ]
        )
    ]
)
