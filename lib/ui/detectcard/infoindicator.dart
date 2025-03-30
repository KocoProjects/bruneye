import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:bruneye/ui/detectcard/detectcard.dart';
import 'package:bruneye/theme/themebsi.dart';

class DetectionInfoIndicator extends StatelessWidget {
  final String tag;
  final double confidence;
  final bool _animate = true;

  const DetectionInfoIndicator({
    super.key,
    required this.tag,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      startDelay: const Duration(milliseconds: 1000),
      glowColor: ArtEducationColors.secondary.withOpacity(0.7),
      glowShape: BoxShape.circle,
      animate: _animate,
      curve: Curves.fastOutSlowIn,
      child: Material(
        elevation: 8.0,
        shape: const CircleBorder(),
        shadowColor: ArtEducationColors.primary.withOpacity(0.5),
        child: CircleAvatar(
          backgroundColor: ArtEducationColors.surfaceLight,
          child: IconButton(
            icon: Icon(
              Icons.touch_app_rounded,
              size: 50,
              color: ArtEducationColors.primary,
            ),
            onPressed: () {
              _showInfoCard(context);
            },
          ),
          radius: 30.0,
        ),
      ),
    );
  }

  void _showInfoCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: ArtEducationColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: ArtEducationColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: DetectionInfoCard(
                  tag: tag,
                  confidence: confidence,
                ),
              ),
            );
          },
        );
      },
    );
  }
}