import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/icon_service.dart';

class ServiceIcon extends StatelessWidget {
  final String issuer;
  final String accountName;
  final double size;

  const ServiceIcon({
    super.key,
    required this.issuer,
    required this.accountName,
    this.size = 40,
  });

  // Fallback color generator based on name
  Color _generateColor(String name) {
    final hash = name.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b).withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    if (issuer.isEmpty) {
      return _buildFallback();
    }

    // Use our global IconService logic
    final iconUrl = IconService.getIconUrl(issuer);

    if (iconUrl == null) {
      return _buildFallback();
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25), // Rounded square
      child: Container(
        color: Colors.white, // Background for transparent logos
        child: CachedNetworkImage(
          imageUrl: iconUrl,
          width: size,
          height: size,
          memCacheWidth: (size * 2).toInt(),
          memCacheHeight: (size * 2).toInt(),
          fit: BoxFit.contain, // Contain ensures logos aren't cropped weirdly
          placeholder: (context, url) => _buildFallback(),
          errorWidget: (context, url, error) => _buildFallback(),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    final display = issuer.isNotEmpty ? issuer : accountName;
    final initial = display.isNotEmpty ? display[0].toUpperCase() : '?';
    final bgColor = _generateColor(display);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.5,
        ),
      ),
    );
  }
}
