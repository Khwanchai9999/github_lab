import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';

const _darkModeKey = 'dark_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = SharedPreferencesAsync();
  var isDarkMode = false;
  try {
    isDarkMode = await preferences.getBool(_darkModeKey) ?? false;
  } catch (error) {
    debugPrint('Could not load theme preference: $error');
  }
  runApp(MyApp(preferences: preferences, initialDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.preferences,
    required this.initialDarkMode,
  });

  final SharedPreferencesAsync preferences;
  final bool initialDarkMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  Future<void> _changeTheme(bool isDarkMode) async {
    await widget.preferences.setBool(_darkModeKey, isDarkMode);
    if (!mounted) return;
    setState(() => _isDarkMode = isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyPage(onThemeChanged: _changeTheme),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key, required this.onThemeChanged});

  final Future<void> Function(bool) onThemeChanged;

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String message = 'ยังไม่ได้กดปุ่ม';
  bool _isSavingTheme = false;

  Future<void> _toggleTheme(bool isDarkMode) async {
    setState(() => _isSavingTheme = true);
    try {
      await widget.onThemeChanged(isDarkMode);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกโหมดไม่สำเร็จ กรุณาลองอีกครั้ง')),
      );
    } finally {
      if (mounted) setState(() => _isSavingTheme = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Lab')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: Text(
                Theme.of(context).brightness == Brightness.dark
                    ? 'โหมดมืด'
                    : 'โหมดสว่าง',
              ),
              secondary: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: _isSavingTheme ? null : _toggleTheme,
            ),
            const SizedBox(height: 16),
            Text(message),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  message = 'กดปุ่มแล้ว!';
                });
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: const Text('press'),
            ),
          ],
        ),
      ),
    );
  }
}
