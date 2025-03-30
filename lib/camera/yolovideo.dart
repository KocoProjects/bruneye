import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:bruneye/ui/detectcard/infoindicator.dart';
import 'package:bruneye/service/bookmarkservice.dart';

late List<CameraDescription> cameras;

class YoloVideo extends StatefulWidget {
  const YoloVideo({Key? key}) : super(key: key);

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<YoloVideo> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late CameraController controller;
  late FlutterVision vision;
  List<Map<String, dynamic>> yoloResults = [];
  final BookmarkService bookmarkService = BookmarkService();

  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;
  bool isProcessingFrame = false;

  // Animation for scanning effect
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Map to track stable positions for indicators
  final Map<String, Map<String, dynamic>> _stablePositions = {};

  // Positions update delay timer
  Timer? _positionUpdateTimer;

  // Performance management
  DateTime? lastProcessedTime;
  static const int processingIntervalMs = 500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Setup scanning animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      stopDetection();
    } else if (state == AppLifecycleState.resumed && !isDetecting) {
      startDetection();
    }
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    vision = FlutterVision();

    controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420
    );

    try {
      // Initialize the camera
      await controller.initialize();
      await loadYoloModel();
      if (mounted) {
        setState(() {
          isLoaded = true;
        });
        // Auto-start detection when camera is ready
        startDetection();
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> loadYoloModel() async {
    try {
      await vision.loadYoloModel(
          labels: 'assets/labels.txt',
          modelPath: 'assets/best_float32.tflite',
          modelVersion: "yolo11s",
          numThreads: 2,
          useGpu: true
      );
    } catch (e) {
      print("Error loading YOLO model: $e");
    }
  }

  Future<void> processFrame(CameraImage image) async {
    if (!isDetecting || isProcessingFrame) return;

    final now = DateTime.now();
    if (lastProcessedTime != null &&
        now.difference(lastProcessedTime!).inMilliseconds < processingIntervalMs) {
      return;
    }

    isProcessingFrame = true;
    lastProcessedTime = now;

    try {
      final result = await vision.yoloOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.45,
          confThreshold: 0.5,
          classThreshold: 0.5
      );

      if (mounted) {
        setState(() {
          cameraImage = image;
        });

        // Update positions with delay to prevent flickering
        _positionUpdateTimer?.cancel();
        _positionUpdateTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            updateStablePositions(result);
            setState(() {
              yoloResults = result;
            });
          }
        });
      }
    } catch (e) {
      print("Error processing frame: $e");
    } finally {
      isProcessingFrame = false;
    }
  }
  // Update stable positions for detected objects
  void updateStablePositions(List<Map<String, dynamic>> newResults) {
    // Create a map of current results for quick lookup
    final currentResultsMap = <String, Map<String, dynamic>>{};
    for (var result in newResults) {
      currentResultsMap[result['tag']] = result;
    }

    // Update stable positions
    for (var tag in currentResultsMap.keys) {
      final result = currentResultsMap[tag]!;

      if (_stablePositions.containsKey(tag)) {
        // Smooth transition for existing positions
        final stablePos = _stablePositions[tag]!;
        stablePos['box'] = [
          _lerp(stablePos['box'][0], result['box'][0], 0.3),
          _lerp(stablePos['box'][1], result['box'][1], 0.3),
          _lerp(stablePos['box'][2], result['box'][2], 0.3),
          _lerp(stablePos['box'][3], result['box'][3], 0.3),
          result['box'][4],
        ];
      } else {
        // New detection, add to stable positions
        _stablePositions[tag] = Map<String, dynamic>.from(result);
      }
    }

    // Remove stale entries
    _stablePositions.removeWhere((tag, _) => !currentResultsMap.containsKey(tag));
  }

  // this function linearly interpolates between two values which means
  // it calculates a value between two points based on a given ratio
  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  Future<void> startDetection() async {
    // Check if already detecting
    if (isDetecting) return;
  //the setstate
    setState(() {
      isDetecting = true;
      yoloResults = [];
    });

    await controller.startImageStream((image) {
      if (isDetecting) {
        processFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    if (!isDetecting) return;

    try {
      await controller.stopImageStream();
    } catch (e) {
      print("Error stopping image stream: $e");
    }

    if (mounted) {
      setState(() {
        isDetecting = false;
        yoloResults.clear();
        _stablePositions.clear();
      });
    }
  }

  @override
  void dispose() {
    _positionUpdateTimer?.cancel();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          controller.value.isInitialized
              ? CameraPreview(controller)
              : Container(color: Colors.black),

          // Scanning animation overlay
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: ScanningOverlayPainter(
                  animation: _animation.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Viewfinder UI
          ViewFinderOverlay(),

          // Status text
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Scanning for artwork...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bounding boxes and indicators
          ...displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
        ],
      ),
    );
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (_stablePositions.isEmpty || cameraImage == null) return [];

    final previewSize = screen;
    final double cameraRatio = cameraImage!.width / cameraImage!.height;
    final double screenRatio = previewSize.width / previewSize.height;

    double factorX;
    double factorY;
    double offsetX = 0;
    double offsetY = 0;

    if (screenRatio > cameraRatio) {
      factorY = previewSize.height / cameraImage!.height;
      factorX = factorY;
      offsetX = (previewSize.width - cameraImage!.width * factorX) / 2;
    } else {
      factorX = previewSize.width / cameraImage!.width;
      factorY = factorX;
      offsetY = (previewSize.height - cameraImage!.height * factorY) / 2;
    }

    List<Widget> widgets = [];

    // Convert stable positions to a list and sort by confidence
    List<Map<String, dynamic>> sortedResults = _stablePositions.values.toList();
    sortedResults.sort((a, b) => (b["box"][4]).compareTo(a["box"][4]));

    int indicatorCount = 0;
    final int maxIndicators = 3;

    for (var result in sortedResults) {
      // Extract coordinates from YOLO results
      double x1 = result["box"][0] * factorX + offsetX;
      double y1 = result["box"][1] * factorY + offsetY;
      double x2 = result["box"][2] * factorX + offsetX;
      double y2 = result["box"][3] * factorY + offsetY;
      double confidence = result["box"][4] * 100;

      // Make sure coordinates stay within screen bounds
      x1 = x1.clamp(0, previewSize.width);
      y1 = y1.clamp(0, previewSize.height);
      x2 = x2.clamp(0, previewSize.width);
      y2 = y2.clamp(0, previewSize.height);

      // Ensure width and height are positive
      final width = (x2 - x1).abs();
      final height = (y2 - y1).abs();

      // Create bounding box for all detected objects
      widgets.add(
          Positioned(
            left: x1,
            top: y1,
            width: width,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
      );

      // Add info indicator only for top 3 results with sufficient size
      if (indicatorCount < maxIndicators && width > 60 && height > 60) {
        widgets.add(
            Positioned(
              left: x1 + (width / 2) - 30,
              top: y1 + (height / 2) - 30,
              child: DetectionInfoIndicator(
                tag: result['tag'],
                confidence: confidence,
              ),
            )
        );
        indicatorCount++;
      }
    }

    return widgets;
  }
}

// Camera viewfinder overlay
class ViewFinderOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Corner brackets
        Positioned(
          left: 40,
          top: 40,
          child: _buildCornerBracket(),
        ),
        Positioned(
          right: 40,
          top: 40,
          child: Transform.rotate(
            angle: 90 * 3.14159 / 180,
            child: _buildCornerBracket(),
          ),
        ),
        Positioned(
          left: 40,
          bottom: 40,
          child: Transform.rotate(
            angle: -90 * 3.14159 / 180,
            child: _buildCornerBracket(),
          ),
        ),
        Positioned(
          right: 40,
          bottom: 40,
          child: Transform.rotate(
            angle: 180 * 3.14159 / 180,
            child: _buildCornerBracket(),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerBracket() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(color: Colors.white, width: 4),
          left: BorderSide(color: Colors.white, width: 4),
        ),
      ),
    );
  }
}

// Scanning animation painter
class ScanningOverlayPainter extends CustomPainter {
  final double animation;

  ScanningOverlayPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw scanning line
    final scanLineY = size.height * animation;
    canvas.drawLine(
      Offset(0, scanLineY),
      Offset(size.width, scanLineY),
      Paint()
        ..color = Colors.green.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Draw glow effect around line
    final glowPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawLine(
      Offset(0, scanLineY - 2),
      Offset(size.width, scanLineY - 2),
      glowPaint,
    );

    canvas.drawLine(
      Offset(0, scanLineY + 2),
      Offset(size.width, scanLineY + 2),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(ScanningOverlayPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}