import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
 
class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final String? placeholderAsset;
  final String? errorAsset;

  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.color,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.placeholderAsset,
    this.errorAsset,
  });

  bool get _isNetwork => image.startsWith('http');
  bool get _isSvg => image.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return _assetImage(errorAsset ?? placeholderAsset);
    }

    Widget imageWidget;

    if (_isNetwork) {
      imageWidget = Image.network(
        image,
        height: height,
        width: width,
        fit: fit,
        color: color,
        errorBuilder: (_, __, ___) {
          return _assetImage(errorAsset ?? placeholderAsset);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _assetImage(placeholderAsset);
        },
      );
    } else if (_isSvg) {
      imageWidget = SvgPicture.asset(
        image,
        height: height,
        width: width,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else {
      imageWidget = Image.asset(
        image,
        height: height,
        width: width,
        fit: fit,
        color: color,
      );
    }

    return _wrapShape(imageWidget);
  }

  Widget _assetImage(String? asset) {
    if (asset == null) return const SizedBox();
    final bool isSvgAsset = asset.endsWith('.svg');
    if (isSvgAsset) {
      return SvgPicture.asset(
        asset,
        height: height,
        width: width,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }
    return Image.asset(
      asset,
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }

  Widget _wrapShape(Widget child) {
    if (shape == BoxShape.circle) {
      return ClipOval(child: child);
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
