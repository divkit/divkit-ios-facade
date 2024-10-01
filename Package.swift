// swift-tools-version: 5.9

import PackageDescription

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
    .package(
      url: "https://github.com/divkit/divkit-ios.git",
      from: Version(stringLiteral: "30.9.0")
    )
  ],
  targets: [
    .target(
      name: "DivKitBinaryCompatibilityFacade",
      dependencies: [
        .product(name: "DivKit", package: "divkit-ios")
      ],
      path: "DivKitBinaryCompatibilityFacade",
      swiftSettings: [
        .enableExperimentalFeature("AccessLevelOnImport")
      ]
    ),
  ]
)
