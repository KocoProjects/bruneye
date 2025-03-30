import 'package:flutter/material.dart';
import 'carddisplay.dart';
import 'package:bruneye/theme/themebsi.dart';
class CardSlider extends StatefulWidget {
  final List<Carddisplay> cardList;
  final Color? sectionColor; // New parameter for section color

  const CardSlider({
    Key? key,
    required this.cardList,
    this.sectionColor,
  }) : super(key: key);

  @override
  _CardSliderState createState() => _CardSliderState();
}

class _CardSliderState extends State<CardSlider> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  final double _viewportFraction = 0.85;
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: _viewportFraction,
    );

    // Add animation controller for more dynamic interactions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Listen to page changes for smoother animations
    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    // Only update if not auto-scrolling
    if (!_isAutoScrolling && _pageController.page != null) {
      final page = _pageController.page!.round();
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final themeColor = widget.sectionColor ?? Theme.of(context).primaryColor;
    final indicatorColor = widget.sectionColor ?? Theme.of(context).primaryColor;

    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dimensions
    final availableHeight = screenHeight * 0.7;
    final cardWidth = screenWidth * _viewportFraction;
    final cardHeight = (cardWidth * (4 / 3)).clamp(0.0, availableHeight - 36);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the actual card height within constraints
        final maxHeight = constraints.maxHeight;
        final actualCardHeight = (maxHeight - 36).clamp(0.0, cardHeight);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main card slider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SizedBox(
                height: actualCardHeight,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: widget.cardList.length,
                  itemBuilder: (context, index) {
                    final card = widget.cardList[index];
                    final isCurrent = _currentPage == index;
                    final scale = isCurrent ? 1.0 : 0.9;
                    final opacity = isCurrent ? 1.0 : 0.7;

                    return GestureDetector(
                      onTap: card.onTap, // Allow direct tapping on cards
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == widget.cardList.length - 1 ? 16 : 8,
                          left: 8,
                          top: 4,
                          bottom: 4,
                        ),
                        child: TweenAnimationBuilder(
                          tween: Tween(begin: scale, end: scale),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          builder: (context, double value, child) {
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 350),
                              opacity: opacity,
                              child: Carddisplay(
                                title: card.title,
                                description: card.description,
                                artist: card.artist,
                                artPicUrl: card.artPicUrl,
                                collectionName: card.collectionName,
                                location: card.location,
                                materials: card.materials,
                                onTap: card.onTap,
                                scale: value,
                                isFocused: isCurrent,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}