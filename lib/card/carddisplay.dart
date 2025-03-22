import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

import 'cardservice.dart';

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
  });

  factory Carddisplay.fromJson(Map<String, dynamic> json, {
    required VoidCallback onTap,
    required double scale,
    required bool isFocused,
  }) {
    // Create the complete image URL by combining base URL and image path
    String imageUrl = json['artpicurl'];
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${CardService.baseUrl}${imageUrl}';
    }

    return Carddisplay(
      title: json['title'],
      description: json['description'],
      artist: json['artist'],
      collectionName: json['collectionname'],
      artPicUrl: imageUrl,
      // Use the complete URL
      location: json['location'],
      materials: json['materials'],
      onTap: onTap,
      scale: scale,
      isFocused: isFocused,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
          child: Card(
          elevation: isFocused ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                    artist: artist ?? "Unknown Artist",
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Hero(
                  tag: title,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: constraints.maxHeight),                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text section with fixed size
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 22,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        const Divider(height: 1),

                        // Image section with flex
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
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    location,
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
}

class FullScreenCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String tag;
  final String artist;

  const FullScreenCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.tag,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Artist: ${artist}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location: ${location}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    // Image with max height constraint to avoid overflow
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 60),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

                    // Additional padding at bottom
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}