import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart'; // Для открытия ссылок
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;
import 'dart:async';

class ScanCodePage extends StatefulWidget {
  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool hasScanned = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();
  String? scannedResult;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();  // Создание контроллера
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    scannedResult = null;
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    scannedResult = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    cameraController.dispose();  // Очистка контроллера при уничтожении страниц
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (!hasScanned && barcodeCapture.barcodes.isNotEmpty) {
      setState(() {
        hasScanned = true;
      });

      final String? code = barcodeCapture.barcodes.first.rawValue;

      if (code != null) {
        Vibration.vibrate();

        // Turn off the flashlight using toggleTorch if it is on
        if (_isFlashOn) {
          cameraController.toggleTorch();
          _isFlashOn = false; // Update the state to reflect that the flashlight is off
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(result: code),
          ),
        ).then((_) {
          // Return to the main page after the result page is dismissed
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      }
    }
  }

  // Toggle the flashlight state when the button is pressed
  void _toggleFlashlight() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      if (_isFlashOn) {
        cameraController.toggleTorch();  // Turn on the flashlight
      } else {
        cameraController.toggleTorch();  // Turn off the flashlight
      }
    });
  }

  Future<void> scanImageFromGallery() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final mlkit.InputImage inputImage = mlkit.InputImage.fromFilePath(image.path);
    final mlkit.BarcodeScanner barcodeScanner = mlkit.BarcodeScanner();

    try {
      final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        final scannedValue = barcodes.first.rawValue;

        if (scannedValue != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResultPage(result: scannedValue),
            ),
          ).then((_) {
            // Возвращаемся на главный экран
            Navigator.popUntil(context, (route) => route.isFirst);
          });
        }
      } else {
        setState(() {
          scannedResult = "No QR code found.";
        });
      }
    } catch (e) {
      print("Error scanning QR code: $e");
    } finally {
      barcodeScanner.close();
    }
  }

  // Метод для обработки завершения сканирования
  void _onScanComplete(String result) {
    setState(() {
      scannedResult = result;
    });

    // Навигация на страницу с результатом
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultPage(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Code"),
        automaticallyImplyLeading: false, // Disable default back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Pops the current page and returns to the main page
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // BackdropFilter for darkening the background with a blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.6), // Darken the background
              ),
            ),
          ),

          // MobileScanner widget for scanning QR/barcodes
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,  // Scanning logic stays the same
          ),

          // Centered scanning area with border and animation
          Align(
            alignment: Alignment(0.0, -0.2),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.7), // Visible border
                color: Colors.transparent, // Transparent background for scanning area
              ),
              child: Stack(
                children: [
                  // CustomPaint for scanning area border
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BorderPainter(), // Optional: Custom border painting
                    ),
                  ),
                  // Animated red line inside the scanning area
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value * 250,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: Colors.red, // Red line moving inside the scan area
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Колонка для отображения результата сканирования
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (scannedResult != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Result: $scannedResult",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),

          // Flashlight toggle button
          Positioned(
            bottom: 40,  // Positioned near the bottom
            left: 30,     // Positioned near the left
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 40,  // Increased size for visibility
              ),
              onPressed: _toggleFlashlight,  // Action on press
            ),
          ),

          // Gallery scan button
          Positioned(
            bottom: 40,
            right: 30,
            child: IconButton(
              icon: Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 40,
              ),
              onPressed: scanImageFromGallery,
            ),
          ),
        ],
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double cornerSize = 20;

    // Draw the corners
    canvas.drawLine(Offset(0, 0), Offset(cornerSize, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerSize), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerSize, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerSize), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerSize, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ScanResultPage extends StatelessWidget {
  final String scannedData;

  ScanResultPage({required this.scannedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Result"),
      ),
      body: Center(
        child: Text(
          scannedData,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String? result;

  ResultPage({this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Выровнять по центру
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Текст будет слева
              children: [
                Text(
                  result ?? "No result found",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Кнопки будут по центру
              children: [
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Code copied to clipboard")));
                  },
                  child: Text("Copy Text"),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (result != null && Uri.tryParse(result!)?.hasScheme == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Кнопки будут по центру
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (result != null) {
                        launchUrl(Uri.parse(result!));
                      }
                    },
                    child: Text("Go to URL"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
