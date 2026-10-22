package com.example.family_budget_app

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.family_budget_app/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetData" -> {
                    val available = call.argument<String>("available") ?: "Rs. 0.00"
                    val income = call.argument<String>("income") ?: "Rs. 0.00"
                    val spent = call.argument<String>("spent") ?: "Rs. 0.00"

                    val prefs = getSharedPreferences(FamilyBudgetWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putString(FamilyBudgetWidgetProvider.KEY_AVAILABLE, available)
                        .putString(FamilyBudgetWidgetProvider.KEY_INCOME, income)
                        .putString(FamilyBudgetWidgetProvider.KEY_SPENT, spent)
                        .apply()

                    FamilyBudgetWidgetProvider.updateAllWidgets(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
