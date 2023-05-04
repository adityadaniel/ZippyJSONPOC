// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZippyJSONBenchmark",
    dependencies: [
        .package(url: "https://github.com/google/swift-benchmark", from: "0.1.0"),
        .package(url: "https://github.com/michaeleisel/ZippyJSON", from: "1.2.10"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.4.1"),
    ],
    targets: [
        .target(
            name: "ZippyJSONBenchmark-Library",
            dependencies: [
                .product(name: "ZippyJSON", package: "ZippyJSON"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "ZippyJSONTesting",
            dependencies: [
                "ZippyJSONBenchmark-Library"
            ]
        ),
        .executableTarget(
            name: "ZippyJSONBenchmark",
            dependencies: [
                "ZippyJSONBenchmark-Library",
                .product(name: "Benchmark", package: "swift-benchmark")
            ]
        ),
        .testTarget(
            name: "ZippyJSONBenchmarkTests",
            dependencies: ["ZippyJSONBenchmark"]),
    ]
)
