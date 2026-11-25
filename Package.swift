// swift-tools-version: 5.9

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
//
// ONNX Runtime 1.24.2 for Swift Package Manager, as used by Helix's iOS SDK (HelixVoice).
//
// The Objective-C bindings in objectivec/ are Microsoft's, from microsoft/onnxruntime-swift-package-manager tag 1.24.2
// (commit b7fb7f7), unchanged. The binary is Microsoft's ONNX Runtime 1.24.2 for iOS and macOS, repackaged by Helix as a
// LIBRARY-format xcframework: the static libraries and headers are byte-identical to Microsoft's
// pod-archive-onnxruntime-c-1.24.2.zip (sha256 f7100a99...), only the packaging differs. Microsoft's archive wraps the
// libraries in .framework bundles, which Xcode embeds in the app with a generated stub dylib that App Store Connect
// rejects (ITMS-90208). A library-format xcframework is link-only, so nothing is embedded.

import PackageDescription

let package = Package(
    name: "onnxruntime",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        .library(name: "onnxruntime", type: .static, targets: ["OnnxRuntimeBindings"]),
    ],
    targets: [
        .target(name: "OnnxRuntimeBindings",
                dependencies: ["onnxruntime"],
                path: "objectivec",
                cxxSettings: [.define("SPM_BUILD")]),
        .testTarget(name: "OnnxRuntimeBindingsTests",
                    dependencies: ["OnnxRuntimeBindings"],
                    path: "swift/OnnxRuntimeBindingsTests",
                    resources: [.copy("Resources/single_add.basic.ort")]),
        .binaryTarget(name: "onnxruntime",
                      url: "https://github.com/Helix-ID/onnxruntime-swift-package-manager/releases/download/1.24.2/onnxruntime-libs-1.24.2.zip",
                      checksum: "a42489b8353c1ea225f15aeb499d142e50ea9b9c96e0770be39df5871d9a6a63"),
    ],
    cxxLanguageStandard: .cxx17
)
