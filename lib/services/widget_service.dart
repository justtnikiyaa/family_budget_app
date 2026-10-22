import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('com.example.family_budget_app/widget');

  static Future<void> updateWidgetData({
    required String available,
    required String income,
    required String spent,
  }) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('updateWidgetData', {
        'available': available,
        'income': income,
        'spent': spent,
      });
    } catch (e) {
      debugPrint('WidgetService update error: $e');
    }
  }
}
