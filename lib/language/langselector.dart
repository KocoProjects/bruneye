import 'package:flutter/material.dart';
import 'package:bruneye/service/languageservice.dart';

// This widget allows users to select a language from a list of available languages.
class LanguageSelectorScreen extends StatefulWidget {
  final Function? onLanguageChanged;

  const LanguageSelectorScreen({Key? key, this.onLanguageChanged}) : super(key: key);

  @override
  _LanguageSelectorScreenState createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  // Initialize the language service to manage language preferences
  final _languageService = LanguageService();
  late String _selectedLanguage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    await _languageService.initialize();
    setState(() {
      _selectedLanguage = _languageService.currentLanguage;
      _isLoading = false;
    });
  }
  // Change the language and update the state
  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _isLoading = true;
    });

    await _languageService.setLanguage(languageCode);

    setState(() {
      _selectedLanguage = languageCode;
      _isLoading = false;
    });

    // Notify parent about language change if callback exists
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!();
    }

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Display a message to confirm the language change
          content: Text('Language changed to ${_languageService.languages[languageCode]}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
      ),
      body: ListView(
        children: _languageService.languages.entries.map((entry) {
          final languageCode = entry.key;
          final languageName = entry.value;

          return ListTile(
            title: Text(languageName),
            leading: Radio<String>(
              value: languageCode,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _changeLanguage(value);
                }
              },
            ),
            onTap: () => _changeLanguage(languageCode),
          );
        }).toList(),
      ),
    );
  }
}