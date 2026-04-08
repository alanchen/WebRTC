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
            url: "https://github.com/alanchen/WebRTC/releases/download/147.0.0/WebRTC-M147.xcframework.zip",
            checksum: "4e4937c281ec2880deb46866cecc6cd3a7954e9a110efe14bd00611564df1a38"
        ),
    ]
)
