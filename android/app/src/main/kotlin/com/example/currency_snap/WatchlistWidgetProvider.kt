package com.example.currency_snap

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WatchlistWidgetProvider : HomeWidgetProvider() {

    companion object {
        const val ACTION_REFRESH_WATCHLIST = "ACTION_REFRESH_WATCHLIST"
        private const val PREFS_NAME = "FlutterSharedPreferences"
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == ACTION_REFRESH_WATCHLIST) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, WatchlistWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (widgetId in allWidgetIds) {
                updateWatchlistWidget(context, appWidgetManager, widgetId, prefs)
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
            updateWatchlistWidget(context, appWidgetManager, widgetId, prefs)
        }
    }

    private fun updateWatchlistWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        prefs: SharedPreferences
    ) {
        val count = getInt(prefs, "watchlist_count", 0)
        val updatedTime = getString(prefs, "watchlist_updated", "Live")

        val views = RemoteViews(context.packageName, R.layout.watchlist_widget).apply {
            setTextViewText(R.id.widget_watchlist_updated, updatedTime)

            // Setup Refresh pending intent
            val refreshIntent = Intent(context, WatchlistWidgetProvider::class.java).apply {
                action = ACTION_REFRESH_WATCHLIST
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                200,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.btn_watchlist_refresh, refreshPendingIntent)

            // General click to open app
            val appIntent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val appPendingIntent = PendingIntent.getActivity(
                context,
                201,
                appIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.widget_watchlist_title, appPendingIntent)
            setOnClickPendingIntent(R.id.watchlist_empty_text, appPendingIntent)

            if (count == 0) {
                setViewVisibility(R.id.watchlist_empty_text, View.VISIBLE)
                setViewVisibility(R.id.watchlist_rows_container, View.GONE)
            } else {
                setViewVisibility(R.id.watchlist_empty_text, View.GONE)
                setViewVisibility(R.id.watchlist_rows_container, View.VISIBLE)

                val rowIds = intArrayOf(R.id.row_1, R.id.row_2, R.id.row_3, R.id.row_4)
                val pairIds = intArrayOf(R.id.pair_1, R.id.pair_2, R.id.pair_3, R.id.pair_4)
                val rateIds = intArrayOf(R.id.rate_1, R.id.rate_2, R.id.rate_3, R.id.rate_4)
                val changeIds = intArrayOf(R.id.change_1, R.id.change_2, R.id.change_3, R.id.change_4)

                for (i in 0 until 4) {
                    val idx = i + 1
                    if (i < count) {
                        setViewVisibility(rowIds[i], View.VISIBLE)
                        val pairStr = getString(prefs, "watchlist_pair_$idx", "")
                        val rateStr = getString(prefs, "watchlist_rate_$idx", "")
                        val changeStr = getString(prefs, "watchlist_change_$idx", "0.00%")
                        val base = getString(prefs, "watchlist_base_$idx", "")
                        val target = getString(prefs, "watchlist_target_$idx", "")

                        setTextViewText(pairIds[i], pairStr)
                        setTextViewText(rateIds[i], rateStr)
                        setTextViewText(changeIds[i], changeStr)

                        val isPositive = !changeStr.startsWith("-")
                        if (isPositive) {
                            setTextColor(changeIds[i], Color.parseColor("#10B981"))
                            setInt(changeIds[i], "setBackgroundResource", R.drawable.widget_badge_pos)
                        } else {
                            setTextColor(changeIds[i], Color.parseColor("#EF4444"))
                            setInt(changeIds[i], "setBackgroundResource", R.drawable.widget_badge_neg)
                        }

                        // Deep Link click intent for row
                        val rowIntent = Intent(context, MainActivity::class.java).apply {
                            action = Intent.ACTION_MAIN
                            addCategory(Intent.CATEGORY_LAUNCHER)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                            putExtra("base_currency", base)
                            putExtra("target_currency", target)
                            data = android.net.Uri.parse("currencysnap://pair?base=$base&target=$target")
                        }
                        val rowPendingIntent = PendingIntent.getActivity(
                            context,
                            300 + idx,
                            rowIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )
                        setOnClickPendingIntent(rowIds[i], rowPendingIntent)
                    } else {
                        setViewVisibility(rowIds[i], View.GONE)
                    }
                }
            }
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun getString(prefs: SharedPreferences, key: String, default: String): String {
        return prefs.getString(key, null)
            ?: prefs.getString("flutter.$key", null)
            ?: default
    }

    private fun getInt(prefs: SharedPreferences, key: String, default: Int): Int {
        try {
            val strVal = prefs.getString(key, null) ?: prefs.getString("flutter.$key", null)
            if (strVal != null) {
                val parsed = strVal.toIntOrNull()
                if (parsed != null) return parsed
            }
        } catch (_: Exception) {}

        if (prefs.contains(key)) {
            try { return prefs.getInt(key, default) } catch (_: Exception) {}
            try { return prefs.getLong(key, default.toLong()).toInt() } catch (_: Exception) {}
        }
        if (prefs.contains("flutter.$key")) {
            try { return prefs.getInt("flutter.$key", default) } catch (_: Exception) {}
            try { return prefs.getLong("flutter.$key", default.toLong()).toInt() } catch (_: Exception) {}
        }
        return default
    }
}
