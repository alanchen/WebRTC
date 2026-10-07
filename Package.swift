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
            url: "https://github.com/alanchen/WebRTC/releases/download/155.0.0/WebRTC-M155.xcframework.zip",
            checksum: "3d2e5151c63881aa2ac39d5e2e3519c1194c5acf7fc912c4722dd6b8aed0c444"
        ),
    ]
)
