import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

/// This class is responsible for holding all user preferences, like the theme color.
/// It also manages saving these to persistent storage via Shared Preferences.

class Preferences with ChangeNotifier{
  // Available fonts
  final Map<String, TextTheme> fonts = {
    'Lato' : GoogleFonts.latoTextTheme(),
    'Delius Swash Caps' : GoogleFonts.deliusSwashCapsTextTheme()
  };

  // User defined preferences
  Color _accentColor = Color(0xFFE91E63);
  bool _usingSystemColor = false;
  String _font = 'Lato';
  int _startOfWeek = 0;

  // Accent color provided by the system (Material You)
  Color _systemColor = Color(0xFFE91E63);
  
  // Subscribable preferences information
  Color get accentColor => (isSystemColorAvailable) ? (usingSystemColor) ? _systemColor : _accentColor : _accentColor;
  bool get isSystemColorAvailable => defaultTargetPlatform.supportsAccentColor;
  bool get usingSystemColor => _usingSystemColor;
  TextTheme get textTheme => fonts[_font]!;
  int get startOfWeek => _startOfWeek;

  Future<void> setAccentColor (Color color) async {
    _accentColor = color;
    notifyListeners();
    _storePreferences();
  }

  Future<void> setUsingSystemColor(bool value) async {
    _usingSystemColor = value;
    notifyListeners();
    _storePreferences();
  }

  Future<void> setFont(String name) async {
    _font = name;
    notifyListeners();
    _storePreferences();
  }

  Future<void> setStartOfWeek(int index) async {
    _startOfWeek = index;
    notifyListeners();
    _storePreferences();
  }

  Preferences() {
    _readSystemColors();
    _readPreferences();
  }

  // Helper function to read and set the system accent color.
  Future<void> _readSystemColors() async {
    await SystemTheme.accentColor.load();
    _systemColor = SystemTheme.accentColor.accent;
  }

  // Helper function to read all preferences from SharedPreferences
  Future<void> _readPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var storedColorHex = prefs.getInt('color');
    if (storedColorHex != null) _accentColor = Color(storedColorHex);
    
    var storedSysColorBool = prefs.getBool('usingSystemColor');
    if (storedSysColorBool != null) setUsingSystemColor(storedSysColorBool);

    var storedFont = prefs.getString('font');
    if (storedFont != null) setFont(storedFont);

    var storedStartOfWeek = prefs.getInt('startOfWeek');
    if (storedStartOfWeek != null) setStartOfWeek(storedStartOfWeek);
    notifyListeners();
  }

  // Helper function to write all preferences to SharedPreferences
  Future<void> _storePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('color', _accentColor.toARGB32());
    await prefs.setBool('usingSystemColor', usingSystemColor);
  }
}
