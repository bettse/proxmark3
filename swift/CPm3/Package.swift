// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CPm3",
    platforms: [
        .macOS("11.3"),
        .iOS("15.0"),
    ],
    products: [
        .library(name: "CPm3", targets: ["CPm3"]),
    ],
    targets: [
        .systemLibrary(name: "CPm3")
    ]
)
