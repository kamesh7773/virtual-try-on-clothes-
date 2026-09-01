// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsDataGen {
  const $AssetsDataGen();

  /// File path: assets/data/catalog.json
  String get catalog => 'packages/virtual_try_on/assets/data/catalog.json';

  /// List of all assets
  List<String> get values => [catalog];
}

class $AssetsGarmentsGen {
  const $AssetsGarmentsGen();

  /// File path: assets/garments/polo-brown-contrast.jpg
  AssetGenImage get poloBrownContrast =>
      const AssetGenImage('assets/garments/polo-brown-contrast.jpg');

  /// File path: assets/garments/polo-cream-knit.jpg
  AssetGenImage get poloCreamKnit =>
      const AssetGenImage('assets/garments/polo-cream-knit.jpg');

  /// File path: assets/garments/polo-green-textured.jpg
  AssetGenImage get poloGreenTextured =>
      const AssetGenImage('assets/garments/polo-green-textured.jpg');

  /// File path: assets/garments/polo-sage-printed.jpg
  AssetGenImage get poloSagePrinted =>
      const AssetGenImage('assets/garments/polo-sage-printed.jpg');

  /// File path: assets/garments/shirt-plaid-corduroy.jpg
  AssetGenImage get shirtPlaidCorduroy =>
      const AssetGenImage('assets/garments/shirt-plaid-corduroy.jpg');

  /// File path: assets/garments/shirt-sky-blue.jpg
  AssetGenImage get shirtSkyBlue =>
      const AssetGenImage('assets/garments/shirt-sky-blue.jpg');

  /// File path: assets/garments/tshirt-black-heavyweight.jpg
  AssetGenImage get tshirtBlackHeavyweight =>
      const AssetGenImage('assets/garments/tshirt-black-heavyweight.jpg');

  /// File path: assets/garments/tshirt-white-basic.jpg
  AssetGenImage get tshirtWhiteBasic =>
      const AssetGenImage('assets/garments/tshirt-white-basic.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [
    poloBrownContrast,
    poloCreamKnit,
    poloGreenTextured,
    poloSagePrinted,
    shirtPlaidCorduroy,
    shirtSkyBlue,
    tshirtBlackHeavyweight,
    tshirtWhiteBasic,
  ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/app_logo.png
  AssetGenImage get appLogo => const AssetGenImage('assets/icons/app_logo.png');

  /// File path: assets/icons/app_splash.png
  AssetGenImage get appSplash =>
      const AssetGenImage('assets/icons/app_splash.png');

  /// List of all assets
  List<AssetGenImage> get values => [appLogo, appSplash];
}

class AppAssets {
  const AppAssets._();

  static const String package = 'virtual_try_on';

  static const $AssetsDataGen data = $AssetsDataGen();
  static const $AssetsGarmentsGen garments = $AssetsGarmentsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  static const String package = 'virtual_try_on';

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    @Deprecated('Do not specify package for a generated library asset')
    String? package = package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    @Deprecated('Do not specify package for a generated library asset')
    String? package = package,
  }) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => 'packages/virtual_try_on/$_assetName';
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
