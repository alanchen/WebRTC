// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WebRTC",
    platforms: [.iOS(.v10), .macOS(.v10_11)],
    products: [
        .library(
            name: "WebRTC",
            targets: ["WebRTC"]),
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/alanchen/WebRTC/releases/download/144.0.0/WebRTC-M144.xcframework.zip",
            checksum: "95615822722e31b9715e1959a83475b501f15928a3a8fb284f261ba4eabf1b8f"
        ),
    ]
)
