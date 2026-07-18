import 'strings_en.dart';
import 'strings_bn.dart';

/// Localisation Engine.
/// Minimal, dependency-free translator sitting on top of the two string
/// maps. Swap languageCode to switch the whole UI at runtime.
class AppLocalizations {
  final String languageCode;
  AppLocalizations(this.languageCode);

  static const supportedLocales = ['en', 'bn'];

  Map<String, String> get _table =>
      languageCode == 'bn' ? stringsBn : stringsEn;

  String t(String key) => _table[key] ?? key;
}
