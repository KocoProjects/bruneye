import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';



class SplashStart extends StatefulWidget {
  final Widget nextScreen;
  final int duration; // Duration in seconds

  const SplashStart({
    Key? key,
    required this.nextScreen,
    this.duration = 3,
  }) : super(key: key);

  @override
  _SplashStartState createState() => _SplashStartState();
}

class _SplashStartState extends State<SplashStart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: widget.duration),
      vsync: this,
    );

    // Create fade-in animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start animation
    _controller.forward();

    // Navigate to next screen after duration
    Future.delayed(Duration(seconds: widget.duration), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Text(
            'brunEYE',
              style: GoogleFonts.brunoAceSc(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              ),
             ),
              SvgPicture.asset(
                'assets/eye-studying-logo.svg',
                width: 150,
                height: 150,
              ),

              const SizedBox(height: 24),
              // App name or loading indicator
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}