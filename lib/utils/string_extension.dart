import 'package:clothing_shop/state/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension LocalizedNumber on String {
  String toLocalizedNum(BuildContext context) {
    final isMyanmar =
        Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).currentLocale.languageCode ==
        'my';

    if (!isMyanmar) return this;

    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const myanmarDigits = ['၀', '၁', '၂', '၃', '၄', '၅', '၆', '၇', '၈', '၉'];

    String input = this;

    for (int i = 0; i < englishDigits.length; i++) {
      input = input.replaceAll(englishDigits[i], myanmarDigits[i]);
    }

    return input;
  }
}
