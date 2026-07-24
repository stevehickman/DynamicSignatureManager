// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DynamicSignatureManager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DynamicSignatureManager", targets: ["DynamicSignatureManager"]),
        .library(name: "DynamicSignatureDomain", targets: ["DynamicSignatureDomain"]),
        .library(name: "DynamicSignatureApplication", targets: ["DynamicSignatureApplication"]),
        .library(name: "DynamicSignatureInfrastructure", targets: ["DynamicSignatureInfrastructure"]),
        .library(name: "DynamicSignatureMail", targets: ["DynamicSignatureMail"])
    ],
    targets: [
        .target(name: "DynamicSignatureDomain"),
        .target(
            name: "DynamicSignatureApplication",
            dependencies: ["DynamicSignatureDomain"]
        ),
        .target(
            name: "DynamicSignatureInfrastructure",
            dependencies: ["DynamicSignatureDomain", "DynamicSignatureApplication"]
        ),
        .target(
            name: "DynamicSignatureMail",
            dependencies: ["DynamicSignatureDomain", "DynamicSignatureApplication"]
        ),
        .executableTarget(
            name: "DynamicSignatureManager",
            dependencies: [
                "DynamicSignatureDomain",
                "DynamicSignatureApplication",
                "DynamicSignatureInfrastructure",
                "DynamicSignatureMail"
            ]
        ),
        .testTarget(
            name: "DynamicSignatureDomainTests",
            dependencies: ["DynamicSignatureDomain"]
        ),
        .testTarget(
            name: "DynamicSignatureApplicationTests",
            dependencies: ["DynamicSignatureApplication", "DynamicSignatureDomain"]
        ),
        .testTarget(
            name: "DynamicSignatureInfrastructureTests",
            dependencies: ["DynamicSignatureInfrastructure", "DynamicSignatureDomain"]
        ),
        .testTarget(
            name: "DynamicSignatureMailTests",
            dependencies: ["DynamicSignatureMail", "DynamicSignatureApplication"]
        )
    ]
)
