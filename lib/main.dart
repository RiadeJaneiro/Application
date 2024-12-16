import 'package:flutter/material.dart';
import 'pages/generate_code_page.dart';
import 'pages/scan_code_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Переменная для хранения текущей темы
  bool _isDark = false;

  // Метод для переключения темы
  void _toggleTheme(bool value) {
    setState(() {
      _isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR & Barcode App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Белый фон для светлой темы
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // Синий AppBar
          foregroundColor: Colors.white, // Белый текст на AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue, // Белый цвет текста на кнопке
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // Синий текст на кнопке
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // Черный текст
          titleLarge: TextStyle(color: Colors.blue), // Синий заголовок
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[700], // Темно-серый фон
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Белый текст
          titleLarge: TextStyle(color: Colors.blue),
        ),
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        toggleTheme: _toggleTheme,
        currentTheme: _isDark, // Передаем текущее состояние темы
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool currentTheme; // Текущее состояние темы

  HomePage({required this.toggleTheme, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Codes Generator and Scanner"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Навигация на страницу настроек
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    toggleTheme: toggleTheme,
                    initialTheme: currentTheme, // Передаем состояние темы
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanCodePage()),
                );
              },
              child: Text("Scan Code"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenerateCodePage(isDark: currentTheme)), // Передаем тему на страницу генерации
                );
              },
              child: Text("Generate Code"),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool initialTheme;

  SettingsPage({required this.toggleTheme, required this.initialTheme});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              'Dark Theme',
              style: TextStyle(
                color: _isDark ? Colors.white : Colors.black, // Цвет текста
              ),
            ),
            value: _isDark,
            onChanged: (value) {
              widget.toggleTheme(value);
              setState(() {
                _isDark = value;
              });
            },
          ),

          ListTile(
            title: Text(
              'About App',
              style: TextStyle(
                color: _isDark ? Colors.white : Colors.black, // Цвет текста
              ),
            ),
            leading: Icon(
              Icons.info,
              color: _isDark ? Colors.white : null, // Цвет иконки
            ),
            onTap: () {
              // Переход на экран "О приложении"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),

          ListTile(
            title: Text(
              'Feedback',
              style: TextStyle(
                color: _isDark ? Colors.white : Colors.black,
              ),
            ),
            leading: Icon(
              Icons.feedback,
              color: _isDark ? Colors.white : null,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackPage(isDark: _isDark)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Name: Codes Generator and Scanner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Version: 1.0.0',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Developer: Maria',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Description: This app allows you to generate and scan QR codes and barcodes effortlessly. Enjoy its simplicity and reliability.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Вернуться назад
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  final bool isDark;

  FeedbackPage({required this.isDark});

  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please let us know about any issues or suggestions:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter your feedback here',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white : null, // Цвет текста метки
                ),
                hintText: 'Your feedback...', // Подсказка для поля ввода
                hintStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54, // Цвет подсказки
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Цвет рамки при фокусе
                  ),
                ),
                alignLabelWithHint: true, // Размещение метки в левом верхнем углу
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black, // Цвет вводимого текста
              ),
              cursorColor: isDark ? Colors.white : Colors.blue, // Цвет курсора
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  final feedback = _feedbackController.text.trim();
                  if (feedback.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback submitted! Thank you!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    _feedbackController.clear();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your feedback.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Submit Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
