// swift-tools-version: 5.9

import PackageDescription

let divkit = {
  let version = Version(stringLiteral: "32.9.0")
  return (
    package: Package.Dependency.package(url: "https://github.com/divkit/divkit-ios.git", from: version),
    packageName: "divkit-ios"
  )
}()

let package = Package(
  name: "DivKitBinaryCompatibilityFacade",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "DivKitBinaryCompatibilityFacade",
      targets: ["DivKitBinaryCompatibilityFacade"]
    ),
  ],
  dependencies: [
    divkit.package
  ],
  targets: [
    .target(
      name: "DivKitBinaryCompatibilityFacade",
      dependencies: [
        .product(name: "DivKit", package: divkit.packageName)
      ],
      path: "DivKitBinaryCompatibilityFacade",
      swiftSettings: [
        .enableExperimentalFeature("AccessLevelOnImport")
      ]
    ),
  ]
)
