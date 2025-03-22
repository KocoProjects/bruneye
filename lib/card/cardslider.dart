import 'package:flutter/material.dart';
import 'carddisplay.dart';

class CardSlider extends StatefulWidget {
  final List<Carddisplay> cardList;

  const CardSlider({
    Key? key,
    required this.cardList,
  }) : super(key: key);

  @override
  _CardSliderState createState() => _CardSliderState();
}

class _CardSliderState extends State<CardSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  final double _viewportFraction = 0.85;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Limit the card height to 70% of the container height
    // This ensures it won't overflow the parent container
    final availableHeight = MediaQuery.of(context).size.height * 0.7;

    // Calculate card width based on viewport fraction
    final cardWidth = screenWidth * _viewportFraction;

    // Calculate card height with a ratio, but constrain it to available height
    // Subtract 24 for the indicators height and padding
    final cardHeight = (cardWidth * (4 / 3)).clamp(0.0, availableHeight - 24);

    return LayoutBuilder(
        builder: (context, constraints) {
          // Ensure the total height stays within the constraint height
          final maxHeight = constraints.maxHeight;
          final actualCardHeight = (maxHeight - 24).clamp(0.0, cardHeight);

          return Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            children: [
              SizedBox(
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
                    final scale = _currentPage == index ? 1.0 : 0.9;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == widget.cardList.length - 1 ? 16 : 8,
                        left: 8,
                        top: 4,
                        bottom: 4, // Reduced padding
                      ),
                      child: TweenAnimationBuilder(
                        tween: Tween(begin: scale, end: scale),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Carddisplay(
                            title: card.title,
                            description: card.description,
                            artist: card.artist,
                            artPicUrl: card.artPicUrl,
                            collectionName: card.collectionName,
                            location: card.location,
                            materials: card.materials,
                            onTap: card.onTap,
                            scale: value,
                            isFocused: _currentPage == index,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 4), // Reduced spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.cardList.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2), // Reduced margin
                    height: 6, // Smaller indicators
                    width: _currentPage == index ? 10 : 6, // Smaller indicators
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
}