import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class GenerateCodePage extends StatefulWidget {
  final bool isDark;  // Принимаем состояние темы через конструктор

  GenerateCodePage({required this.isDark});

  @override
  _GenerateCodePageState createState() => _GenerateCodePageState();

}

class _GenerateCodePageState extends State<GenerateCodePage> {
  String _data = 'Sample Text';
  final TextEditingController _controller = TextEditingController();
  String? _qrErrorMessage;
  String? _barcodeErrorMessage;

  // Уникальные ключи для QR-кода и штрих-кода
  final GlobalKey qrCodeKey = GlobalKey();
  final GlobalKey barcodeKey = GlobalKey();

  late bool _isDark; // Объявляем переменную как поле класса

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark; // Используем переданное значение темы
  }

  bool _isValidQR(String text) {
    // Проверка для QR-кода (обычно любые символы допустимы)
    return text.isNotEmpty;
  }

  bool _isValidBarcode(String text) {
    // Проверка для штрих-кода (например, только цифры и некоторые символы)
    final regex = RegExp(r'^[0-9A-Za-z\-]+$'); // Допустимые символы для Code128
    return regex.hasMatch(text);
  }

  void _generateCodes() {
    final input = _controller.text.trim();
    setState(() {
      // Проверка и генерация QR-кода
      if (_isValidQR(input)) {
        _data = input; // Используем одни данные для обоих кодов
        _qrErrorMessage = null;
      } else {
        _qrErrorMessage = 'Invalid data for QR code.';
      }

      // Проверка и генерация штрих-кода
      if (_isValidBarcode(input)) {
        _barcodeErrorMessage = null;
      } else {
        _barcodeErrorMessage = 'Invalid data for barcode.';
      }
    });
  }

    Future<Uint8List> _getImageBytesWithBackground(GlobalKey key) async {
    RenderRepaintBoundary boundary =
    key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image originalImage = await boundary.toImage(pixelRatio: 3.0);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(
          0,
          0,
          originalImage.width.toDouble(),
          originalImage.height.toDouble()
      ),
    );

    // Создаем белый фон
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        originalImage.width.toDouble(),
        originalImage.height.toDouble(),
      ),
      paint,
    );

    // Рисуем исходное изображение поверх белого фона
    final imagePaint = Paint();
    canvas.drawImage(originalImage, Offset.zero, imagePaint);

    final picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(
      originalImage.width,
      originalImage.height,
    );

    ByteData? byteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Отправка изображения
  Future<void> _shareImage(GlobalKey key, String fileName) async {
    try {
      final imageBytes = await _getImageBytesWithBackground(key);
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Generated Code');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while sharing')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;  // Используем isDark из widget, переданное через конструктор
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Code'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Генерация QR-кода с белой подложкой
              if (_qrErrorMessage != null)
                Center(
                  child: Text(
                    _qrErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center, // Центровка текста внутри строки
                  ),
                )
              else
                Container(
                  color: Colors.white, // Белая подложка
                  padding: const EdgeInsets.all(8.0), // Отступы внутри подложки
                  child: RepaintBoundary(
                    key: qrCodeKey, // Уникальный ключ для QR-кода
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data: _data,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Генерация штрих-кода с белой подложкой или ошибка
              if (_barcodeErrorMessage != null)
                Center(
                  child: Text(
                    _barcodeErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center, // Центровка текста внутри строки
                  ),
                )
              else
                Container(
                  color: Colors.white, // Белая подложка
                  padding: const EdgeInsets.all(8.0),
                  child: RepaintBoundary(
                    key: barcodeKey, // Уникальный ключ для штрих-кода
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: _data,
                      width: 200,
                      height: 80,
                      drawText: false,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Поле ввода данных
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter data to generate',
                    labelStyle: TextStyle(
                      color: _isDark ? Colors.white : null, // Цвет текста метки
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue, // Цвет рамки при фокусе
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: _isDark ? Colors.white : Colors.black, // Цвет вводимого текста
                  ),
                  cursorColor: _isDark ? Colors.white : Colors.blue, // Цвет курсора
                ),
              ),
              const SizedBox(height: 20),

              // Кнопка генерации кодов
              ElevatedButton(
                onPressed: _generateCodes,
                child: const Text('Generate Code'),
              ),

              // Кнопки для отправки QR-кода и штрих-кода
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _shareImage(qrCodeKey, 'qr_code.png'),
                    child: const Text('Share QR Code'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _shareImage(barcodeKey, 'barcode.png'),
                    child: const Text('Share Barcode'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


