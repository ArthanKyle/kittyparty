import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/locale_provider.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final Map<String, String> langCodes = {
    'English': 'en',
    '繁體中文': 'zh',
    'بالعربية': 'ar',
    'Türkçe': 'tr',
    'Português (Brasil)': 'pt',
    'Русский': 'ru',
    'Español': 'es',
    "O'zbek": 'uz',
  };

  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final current = context.read<LocaleProvider>().locale.languageCode;
    _selectedLanguage = langCodes.entries
        .firstWhere((e) => e.value == current, orElse: () => const MapEntry('English', 'en'))
        .key;
  }

  void _selectLanguage(String lang) {
    setState(() => _selectedLanguage = lang);
  }

  void _saveLanguage() {
    final code = langCodes[_selectedLanguage]!;
    context.read<LocaleProvider>().changeLocale(code);
    Navigator.pop(context, _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Language Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveLanguage,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF4A4AFF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: langCodes.length,
        separatorBuilder: (_, __) => const Divider(
          color: Color(0xFFEDEDED),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final lang = langCodes.keys.elementAt(index);
          final isSelected = lang == _selectedLanguage;

          return ListTile(
            title: Text(
              lang,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.black87, size: 20)
                : null,
            onTap: () => _selectLanguage(lang),
          );
        },
      ),
    );
  }
}
