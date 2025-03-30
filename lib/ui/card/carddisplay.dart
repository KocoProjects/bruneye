import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:bruneye/service/cardservice.dart';
import 'package:bruneye/ui/card/fullscreencard.dart';
import 'package:bruneye/ui/card/bookmarkbutton.dart';
import 'package:bruneye/theme/themebsi.dart';

final translator = GoogleTranslator();

class Carddisplay extends StatelessWidget {
  final String title;
  final String description;
  final String? artist;
  final String collectionName;
  final String artPicUrl;
  final String location;
  final String? materials;
  final VoidCallback onTap;
  final double scale;
  final bool isFocused;
  final Color? categoryColor;

  Carddisplay({
    required this.title,
    required this.description,
    this.artist,
    required this.collectionName,
    required this.artPicUrl,
    required this.location,
    this.materials,
    required this.onTap,
    required this.scale,
    required this.isFocused,
    this.categoryColor,
  });

  factory Carddisplay.fromJson(Map<String, dynamic> json, {
    required VoidCallback onTap,
    required double scale,
    required bool isFocused,
    Color? categoryColor,
  }) {
    String imageUrl = json['artpicurl'];
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${CardService.baseUrl}${imageUrl}';
    }

    String? artType = _determineArtType(json);

    return Carddisplay(
      title: json['title'],
      description: json['description'],
      artist: json['artist'],
      collectionName: json['collectionname'],
      artPicUrl: imageUrl,
      location: json['location'],
      materials: json['materials'],
      onTap: onTap,
      scale: scale,
      isFocused: isFocused,
      categoryColor: categoryColor,
    );
  }

  static String? _determineArtType(Map<String, dynamic> json) {
    final materials = json['materials'] as String?;
    final description = json['description'] as String;

    if (materials != null) {
      final materialLower = materials.toLowerCase();
      if (materialLower.contains('oil') || materialLower.contains('acrylic') ||
          materialLower.contains('canvas')) {
        return 'painting';
      } else if (materialLower.contains('pencil') || materialLower.contains('charcoal') ||
          materialLower.contains('ink')) {
        return 'drawing';
      } else if (materialLower.contains('marble') || materialLower.contains('bronze') ||
          materialLower.contains('clay') || materialLower.contains('wood')) {
        return 'sculpture';
      } else if (materialLower.contains('digital') || materialLower.contains('print')) {
        return 'digital';
      }
    }

    final descLower = description.toLowerCase();
    if (descLower.contains('photograph') || descLower.contains('photo')) {
      return 'photography';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color cardColor = categoryColor ?? theme.colorScheme.primary;

    return Expanded(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Card(
          elevation: isFocused ? 8 : 4,
          shadowColor: cardColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isFocused ? BorderSide(color: cardColor, width: 2) : BorderSide.none,
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenCard(
                    title: title,
                    description: description,
                    imageUrl: artPicUrl,
                    location: location,
                    tag: title,
                    artist: artist ?? '',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            splashColor: cardColor.withOpacity(0.3),
            highlightColor: cardColor.withOpacity(0.1),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Hero(
                  tag: title,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cardColor.withOpacity(0.05),
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textTheme.titleMedium?.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (artist != null && artist!.isNotEmpty)
                                    Tooltip(
                                      message: 'Artist: $artist',
                                      child: Icon(
                                        Icons.brush,
                                        size: 16,
                                        color: cardColor,
                                      ),
                                    ),
                                ],
                              ),
                              if (artist != null && artist!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'by $artist',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                description.length > 100
                                    ? '${description.substring(0, 97)}...'
                                    : description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: cardColor.withOpacity(0.15),
                        ),
                        Flexible(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                                child: Image.network(
                                  artPicUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[100],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                            size: 48,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Image not available',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (materials != null && materials!.isNotEmpty)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardColor.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatMaterials(materials!),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 10,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            location,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ClipOval(
                                      child: Container(
                                        color: Colors.white,
                                        child: BookmarkButton(
                                          tag: title,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardColor.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    collectionName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatMaterials(String materials) {
    if (materials.length > 20) {
      return '${materials.substring(0, 17)}...';
    }
    return materials;
  }
}