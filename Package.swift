// swift-tools-version: 5.9

// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
//
// A user of the Swift Package Manager (SPM) package will consume this file directly from the ORT SPM github repository.
// For example, the end user's config will look something like:
//
//     dependencies: [
//       .package(url: "https://github.com/microsoft/onnxruntime-swift-package-manager", from: "1.16.0"), 
//       ...
//     ],
//
// NOTE: For valid version numbers, please refer to this page:
// https://github.com/microsoft/onnxruntime-swift-package-manager/releases

import PackageDescription
import class Foundation.ProcessInfo

let package = Package(
    name: "onnxruntime",
    platforms: [.iOS(.v15),
                .macOS(.v14)],
    products: [
        .library(name: "onnxruntime",
                 type: .static,
                 targets: ["OnnxRuntimeBindings"]),
        .library(name: "onnxruntime_extensions",
                 type: .static,
                 targets: ["OnnxRuntimeExtensions"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "OnnxRuntimeBindings",
                dependencies: ["onnxruntime"],
                path: "objectivec",
                exclude: ["ReadMe.md", "format_objc.sh", "test", "docs",
                            "ort_checkpoint.mm",
                            "ort_checkpoint_internal.h",
                            "ort_training_session_internal.h",
                            "ort_training_session.mm",
                            "include/ort_checkpoint.h",
                            "include/ort_training_session.h",
                            "include/onnxruntime_training.h"],
                cxxSettings: [
                    .define("SPM_BUILD"),
                ]),
        .testTarget(name: "OnnxRuntimeBindingsTests",
                    dependencies: ["OnnxRuntimeBindings"],
                    path: "swift/OnnxRuntimeBindingsTests",
                    resources: [
                        .copy("Resources/single_add.basic.ort")
                    ]),
        .target(name: "OnnxRuntimeExtensions",
                dependencies: ["onnxruntime_extensions", "onnxruntime"],
                path: "extensions",
                cxxSettings: [
                    .define("ORT_SWIFT_PACKAGE_MANAGER_BUILD"),
                ]),
        .testTarget(name: "OnnxRuntimeExtensionsTests",
                    dependencies: ["OnnxRuntimeExtensions", "OnnxRuntimeBindings"],
                    path: "swift/OnnxRuntimeExtensionsTests",
                    resources: [
                        .copy("Resources/decode_image.onnx")
                    ]),
    ],
    cxxLanguageStandard: .cxx17
)

// Add the ORT CocoaPods C/C++ pod archive as a binary target.
//
// There are 2 scenarios:
// - Target will be set to a released pod archive and its checksum.
//
// - Target will be set to a local pod archive.
//   This can be used to test with the latest (not yet released) ORT Objective-C source code.

// CI or local testing where you have built/obtained the pod archive matching the current source code.
// Requires the ORT_POD_LOCAL_PATH environment variable to be set to specify the location of the pod.
if let pod_archive_path = ProcessInfo.processInfo.environment["ORT_POD_LOCAL_PATH"] {
    // ORT_POD_LOCAL_PATH MUST be a path that is relative to Package.swift.
    //
    // To build locally, tools/ci_build/github/apple/build_and_assemble_apple_pods.py can be used
    // See https://onnxruntime.ai/docs/build/custom.html#ios
    //  Example command:
    //    python3 tools/ci_build/github/apple/build_and_assemble_apple_pods.py \
    //      --build-settings-file tools/ci_build/github/apple/default_full_apple_framework_build_settings.json
    //
    // This should produce the pod archive in build/apple_pod_staging, and ORT_POD_LOCAL_PATH can be set to
    // "build/apple_pod_staging/pod-archive-onnxruntime-c-???.zip" where '???' is replaced by the version info in the
    // actual filename.
    package.targets.append(Target.binaryTarget(name: "onnxruntime", path: pod_archive_path))

} else {
    // ORT release, as a LIBRARY-format xcframework (static libraries + headers). Repackaged by Helix from Microsoft's
    // pod-archive-onnxruntime-c-1.24.2.zip (sha256 f7100a99...) with the libraries and headers byte-identical; only the
    // packaging changes. Microsoft's archive wraps the static libraries in .framework bundles, which Xcode embeds with a
    // generated stub dylib that App Store Connect rejects (ITMS-90208). A library-format target is link-only, so nothing
    // is embedded. Same approach as this repo's commit 8fa26c1 (scripts/repackage_ort_spm_artifact.sh).
    package.targets.append(
       Target.binaryTarget(name: "onnxruntime",
                           url: "https://github.com/Helix-ID/onnxruntime-swift-package-manager/releases/download/ort-binaries-1.24.2/onnxruntime-libs-1.24.2.zip",
                           // SwiftPM (SHA256) checksum of the release asset
                           checksum: "a42489b8353c1ea225f15aeb499d142e50ea9b9c96e0770be39df5871d9a6a63")
    )
}

if let ext_pod_archive_path = ProcessInfo.processInfo.environment["ORT_EXTENSIONS_POD_LOCAL_PATH"] {
    package.targets.append(Target.binaryTarget(name: "onnxruntime_extensions", path: ext_pod_archive_path))
} else {
    // ORT Extensions release
    package.targets.append(
        Target.binaryTarget(name: "onnxruntime_extensions",
                            url: "https://github.com/Helix-ID/onnxruntime-swift-package-manager/releases/download/ort-binaries-1.24.2/pod-archive-onnxruntime-extensions-c-0.13.0.zip",
                            // SHA256 checksum
                            checksum: "346522d1171d4c99cb0908fa8e4e9330a4a6aad39cd83ce36eb654437b33e6b5")
    )
}
