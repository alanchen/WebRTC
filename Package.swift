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
            url: "https://github.com/alanchen/WebRTC/releases/download/157.0.0/WebRTC-M157.xcframework.zip",
            checksum: "42263fcf3032ff2adecb7b34675e4502512064953cc05cce3bd61cfa67be5e14"
        ),
    ]
)
