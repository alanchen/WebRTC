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
            url: "https://github.com/alanchen/WebRTC/releases/download/152.0.0/WebRTC-M152.xcframework.zip",
            checksum: "cfeb9026e82ee02dfbdd4ea332dad88902e3bea88be28396534545f2a14f2433"
        ),
    ]
)
