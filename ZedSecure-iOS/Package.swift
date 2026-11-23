// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZedSecureCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "ZedSecureCore", targets: ["ZedSecureCore"])
    ],
    targets: [
        .target(
            name: "ZedSecureCore",
            path: "Sources/ZedSecureCore"
        ),
        .testTarget(
            name: "ZedSecureCoreTests",
            dependencies: ["ZedSecureCore"],
            path: "Tests/ZedSecureCoreTests"
        )
    ]
)
