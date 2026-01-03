import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../../features/totp/domain/entities/totp_account.dart';

class HomeWidgetService {
  Future<void> updateWidgetData(List<TotpAccount> accounts) async {
    // Only take top 3 for widgets
    final topAccounts = accounts.take(3).toList();
    
    // Serialize to simple JSON format for Native
    // Format: [ { "name": "...", "issuer": "...", "secret": "...", "digits": 6, "period": 30, "algo": "SHA1" } ]
    final data = topAccounts.map((a) {
      return {
        'name': a.accountName,
        'issuer': a.issuer ?? '',
        'secret': a.secretKey, // Fixed: secret -> secretKey
        'digits': a.digits,
        'period': a.period,
        'algo': a.algorithm,
      };
    }).toList();

    final jsonString = jsonEncode(data);

    // Save to SharedPrefs/UserDefaults suite (group.fidelykey)
    await HomeWidget.saveWidgetData<String>('totp_accounts_data', jsonString);
    await HomeWidget.updateWidget(
      name: 'TotpWidgetProvider', // Must match Android/iOS provider name
      iOSName: 'TotpWidget',
    );
  }
}
