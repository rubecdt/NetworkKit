// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkKit",
	platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .visionOS(.v1), .watchOS(.v8)],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]),
		.library(
			name: "NetworkJSON",
			targets: ["NetworkJSON"]),
		.library(
			name: "NetworkImages",
			targets: ["NetworkImages"]),
		.library(
			name: "NetworkCore",
			targets: ["NetworkCore"]),
    ],
    targets: [
		.target(
			name: "NetworkKit",
			dependencies: ["NetworkCore",
						   "NetworkImages",
						   "NetworkJSON",
						  ]),
		.target(
			name: "NetworkCore"),
        .target(
            name: "NetworkJSON",
			dependencies: ["NetworkCore"]),
		.target(
			name: "NetworkImages",
			dependencies: ["NetworkCore"]),
		.target(
			name: "NetworkMocks",
			path: "Tests/NetworkMocks",
			swiftSettings: [.define("TESTING")]
		),
        .testTarget(
            name: "NetworkKitTests",
			dependencies: ["NetworkKit",
						  "NetworkMocks"],
			resources: [.copy("Resources/swifty.png")]),
		.testTarget(
			name: "NetworkMocksTests",
			dependencies: ["NetworkMocks"]
		)
    ]
)
