package com.example.currency_snap

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.DecimalFormat

class CurrencyWidgetProvider : HomeWidgetProvider() {

    companion object {
        const val ACTION_ADD_10 = "ACTION_ADD_10"
        const val ACTION_ADD_50 = "ACTION_ADD_50"
        const val ACTION_ADD_100 = "ACTION_ADD_100"
        const val ACTION_RESET = "ACTION_RESET"
        const val ACTION_SWAP_PAIR = "ACTION_SWAP_PAIR"
        private const val PREFS_NAME = "FlutterSharedPreferences"
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        val action = intent.action ?: return
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        when (action) {
            ACTION_ADD_10,
            ACTION_ADD_50,
            ACTION_ADD_100,
            ACTION_RESET,
            ACTION_SWAP_PAIR -> {
                var currentAmount = getAmount(prefs)
                var base = getString(prefs, "widget_base", "USD")
                var target = getString(prefs, "widget_target", "PKR")
                var rawRate = getDouble(prefs, "widget_raw_rate", 277.66)

                when (action) {
                    ACTION_ADD_10 -> currentAmount += 10.0
                    ACTION_ADD_50 -> currentAmount += 50.0
                    ACTION_ADD_100 -> currentAmount += 100.0
                    ACTION_RESET -> currentAmount = 100.0
                    ACTION_SWAP_PAIR -> {
                        val newBase = target
                        val newTarget = base
                        val newRate = if (rawRate > 0.0) 1.0 / rawRate else rawRate
                        base = newBase
                        target = newTarget
                        rawRate = newRate
                    }
                }

                val rateFormatted = formatRate(rawRate)

                // Persist state in SharedPreferences (support both direct and flutter. prefixed keys)
                prefs.edit().apply {
                    putFloat("widget_current_amount", currentAmount.toFloat())
                    putFloat("flutter.widget_current_amount", currentAmount.toFloat())
                    putString("widget_current_amount", currentAmount.toString())
                    putString("flutter.widget_current_amount", currentAmount.toString())
                    putString("widget_base", base)
                    putString("flutter.widget_base", base)
                    putString("widget_target", target)
                    putString("flutter.widget_target", target)
                    putString("widget_raw_rate", rawRate.toString())
                    putString("flutter.widget_raw_rate", rawRate.toString())
                    putString("widget_pair", "$base → $target")
                    putString("flutter.widget_pair", "$base → $target")
                    putString("widget_rate", "1 $base = $rateFormatted $target")
                    putString("flutter.widget_rate", "1 $base = $rateFormatted $target")
                    apply()
                }

                // Update all widget instances
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val thisWidget = ComponentName(context, CurrencyWidgetProvider::class.java)
                val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                for (widgetId in allWidgetIds) {
                    updateAppWidget(context, appWidgetManager, widgetId, prefs)
                }
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        appWidgetIds.forEach { widgetId ->
            updateAppWidget(context, appWidgetManager, widgetId, prefs)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        prefs: SharedPreferences
    ) {
        val base = getString(prefs, "widget_base", "USD")
        val target = getString(prefs, "widget_target", "PKR")
        val rawRate = getDouble(prefs, "widget_raw_rate", 277.66)
        val currentAmount = getAmount(prefs)
        val isOnline = getBoolean(prefs, "widget_is_online", true)
        val updatedTime = getString(prefs, "widget_updated", "")

        val converted = currentAmount * rawRate
        val amountStr = formatAmount(currentAmount)
        val convertedStr = formatConverted(converted)
        val rateStr = formatRate(rawRate)

        val resultText = "$amountStr $base = $convertedStr $target"
        val pairText = "$base → $target"
        val rateInfoText = "1 $base = $rateStr $target"

        val views = RemoteViews(context.packageName, R.layout.currency_widget).apply {
            setTextViewText(R.id.widget_pair, pairText)
            setTextViewText(R.id.widget_rate_info, rateInfoText)
            setTextViewText(R.id.widget_conversion_result, resultText)
            setTextViewText(R.id.widget_updated, updatedTime)

            if (isOnline) {
                setTextViewText(R.id.widget_status, "● Live")
                setTextColor(R.id.widget_status, Color.parseColor("#00E676"))
            } else {
                setTextViewText(R.id.widget_status, "● Cached")
                setTextColor(R.id.widget_status, Color.parseColor("#FFB300"))
            }

            setupButtons(context, this)
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun setupButtons(context: Context, views: RemoteViews) {
        fun makePendingIntent(action: String, requestCode: Int): PendingIntent {
            val intent = Intent(context, CurrencyWidgetProvider::class.java).apply {
                this.action = action
            }
            return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        views.setOnClickPendingIntent(R.id.btn_swap_currency, makePendingIntent(ACTION_SWAP_PAIR, 0))
        views.setOnClickPendingIntent(R.id.btn_add_10, makePendingIntent(ACTION_ADD_10, 1))
        views.setOnClickPendingIntent(R.id.btn_add_50, makePendingIntent(ACTION_ADD_50, 2))
        views.setOnClickPendingIntent(R.id.btn_add_100, makePendingIntent(ACTION_ADD_100, 3))
        views.setOnClickPendingIntent(R.id.btn_reset, makePendingIntent(ACTION_RESET, 4))

        // Tap-to-Edit Deep Link: launches MainActivity with auto_focus_amount extra
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("auto_focus_amount", true)
            data = android.net.Uri.parse("currencysnap://autofocus")
        }
        val editPendingIntent = PendingIntent.getActivity(
            context,
            100,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_conversion_result, editPendingIntent)
    }

    private fun getString(prefs: SharedPreferences, key: String, default: String): String {
        return prefs.getString(key, null)
            ?: prefs.getString("flutter.$key", null)
            ?: default
    }

    private fun getDouble(prefs: SharedPreferences, key: String, default: Double): Double {
        val strVal = prefs.getString(key, null) ?: prefs.getString("flutter.$key", null)
        if (strVal != null) {
            val parsed = strVal.toDoubleOrNull()
            if (parsed != null) return parsed
        }
        try {
            if (prefs.contains(key)) return prefs.getFloat(key, default.toFloat()).toDouble()
            if (prefs.contains("flutter.$key")) return prefs.getFloat("flutter.$key", default.toFloat()).toDouble()
        } catch (e: Exception) {
            // ignore
        }
        return default
    }

    private fun getBoolean(prefs: SharedPreferences, key: String, default: Boolean): Boolean {
        if (prefs.contains(key)) return prefs.getBoolean(key, default)
        if (prefs.contains("flutter.$key")) return prefs.getBoolean("flutter.$key", default)
        return default
    }

    private fun getAmount(prefs: SharedPreferences): Double {
        // 1. Check String representation (from Flutter HomeWidget / SharedPreferences)
        try {
            val strVal = prefs.getString("widget_current_amount", null)
                ?: prefs.getString("flutter.widget_current_amount", null)
            if (strVal != null) {
                val parsed = strVal.toDoubleOrNull()
                if (parsed != null) return parsed
            }
        } catch (_: Exception) {}

        // 2. Check Float representation
        try {
            if (prefs.contains("widget_current_amount")) {
                return prefs.getFloat("widget_current_amount", 100f).toDouble()
            }
            if (prefs.contains("flutter.widget_current_amount")) {
                return prefs.getFloat("flutter.widget_current_amount", 100f).toDouble()
            }
        } catch (_: Exception) {}

        // 3. Check Long / Int representation
        try {
            if (prefs.contains("widget_current_amount")) {
                return prefs.getLong("widget_current_amount", 100L).toDouble()
            }
            if (prefs.contains("flutter.widget_current_amount")) {
                return prefs.getLong("flutter.widget_current_amount", 100L).toDouble()
            }
        } catch (_: Exception) {}

        return 100.0
    }

    private fun formatAmount(amount: Double): String {
        return if (amount % 1.0 == 0.0) {
            DecimalFormat("#,##0").format(amount)
        } else {
            DecimalFormat("#,##0.##").format(amount)
        }
    }

    private fun formatConverted(amount: Double): String {
        return if (amount >= 1.0) {
            DecimalFormat("#,##0.00").format(amount)
        } else if (amount >= 0.0001) {
            DecimalFormat("0.0000").format(amount)
        } else {
            DecimalFormat("0.000000").format(amount)
        }
    }

    private fun formatRate(rate: Double): String {
        return if (rate >= 1.0) {
            DecimalFormat("#,##0.00").format(rate)
        } else if (rate >= 0.0001) {
            DecimalFormat("0.0000").format(rate)
        } else {
            DecimalFormat("0.000000").format(rate)
        }
    }
}