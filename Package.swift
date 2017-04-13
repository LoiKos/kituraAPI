// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "kituraMbao",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1,minor:6),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1,minor:6),
        .Package(url: "https://github.com/IBM-Swift/Swift-Kuery-PostgreSQL.git",majorVersion:0,minor:10)
    ]
)
