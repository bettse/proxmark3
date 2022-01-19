// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTester",
    platforms: [
        .macOS("11.3"),
        .iOS("15.0"),
    ],
    dependencies: [
        .package(name: "CPm3", path: "../CPm3"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftTester",
            dependencies: ["CPm3"]
        /*
        ),
        .target(
            name: "dylib",
            path: "../../client/experimental_lib/build/",
            resources: [
                //.process("Resources")
                .copy("libpm3rrg_rdv4.dylib"),
            ]
*/
        )
    ]
)
