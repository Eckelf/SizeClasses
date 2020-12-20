// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SizeClasses",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "SizeClasses",
            targets: ["SizeClasses"])
    ],
    targets: [
        .target(name: "SizeClasses", path: "SizeClasses")
    ],
    swiftLanguageVersions: [.v5]
)
