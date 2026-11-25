# ONNX Runtime 1.24.2 for Swift Package Manager (Helix)

The ONNX Runtime package that Helix's iOS SDK, HelixVoice, depends on. You don't add it yourself: Xcode fetches it when you add HelixVoice.

- **Objective-C bindings** (`objectivec/`): Microsoft's, from `microsoft/onnxruntime-swift-package-manager` tag 1.24.2, unchanged.
- **Binary**: Microsoft's ONNX Runtime 1.24.2, repackaged as a library-format xcframework so apps pass App Store validation (ITMS-90208). The static libraries and headers are byte-identical to Microsoft's release; only the packaging differs. It's the one file on this repository's [1.24.2 release](https://github.com/Helix-ID/onnxruntime-swift-package-manager/releases/tag/1.24.2).

Licensed under the MIT License, see [LICENSE](LICENSE). ONNX Runtime is a Microsoft project.
