package com.invictus.carmaintenance;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.util.Log;
import android.widget.RemoteViews;
import android.content.ComponentName;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import android.view.View;

public class MonthlyCalendarWidget extends AppWidgetProvider {
    private static final String TAG = "MonthlyCalendarWidget";
    private static final String PREFS_NAME = "FlutterSharedPreferences";
    private static final String[] MONTHS = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    };
    public static final String ACTION_DATA_UPDATED = "com.invictus.carmaintenance.ACTION_DATA_UPDATED";

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        Log.d(TAG, "onReceive called with action: " + intent.getAction());
        
        if (ACTION_DATA_UPDATED.equals(intent.getAction())) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, MonthlyCalendarWidget.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            
            if (appWidgetIds != null && appWidgetIds.length > 0) {
                onUpdate(context, appWidgetManager, appWidgetIds);
            }
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        Log.d(TAG, "onUpdate called for " + appWidgetIds.length + " widgets");
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    private void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        try {
            Log.d(TAG, "Starting widget update for ID: " + appWidgetId);
            RemoteViews views;
            if (isPremiumUser(context)) {
                views = new RemoteViews(context.getPackageName(), R.layout.monthly_calendar_widget);

                // Get protein target from SharedPreferences with "flutter." prefix
                SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
                String targetStr = prefs.getString("flutter.protein_target", "100.0");
                float targetProtein;
                try {
                    targetProtein = Float.parseFloat(targetStr);
                    if (targetProtein <= 0) {
                        targetProtein = 100.0f;
                    }
                } catch (Exception e) {
                    Log.e(TAG, "Error parsing target: " + e.getMessage());
                    targetProtein = 100.0f;
                }

                // Update target text
                views.setTextViewText(R.id.target_text, String.format(Locale.getDefault(), "Target: %.0fg", targetProtein));

                // Initialize database helper
                DatabaseHelper dbHelper = new DatabaseHelper(context);

                // Get current month and year
                Calendar cal = Calendar.getInstance();
                int currentMonth = cal.get(Calendar.MONTH);
                int currentYear = cal.get(Calendar.YEAR);

                // Set month title
                views.setTextViewText(R.id.month_title, MONTHS[currentMonth] + " " + currentYear);

                // Clear existing calendar grid
                views.removeAllViews(R.id.calendar_grid);

                // Reset calendar to first day of month
                cal.set(Calendar.DAY_OF_MONTH, 1);

                // Get the day of week for the first day (0 = Sunday)
                int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK) - 1;

                // Get the number of days in the month
                int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

                // Add empty cells for days before the first day of the month
                for (int i = 0; i < firstDayOfWeek; i++) {
                    RemoteViews dayView = new RemoteViews(context.getPackageName(), R.layout.calendar_day_item);
                    dayView.setTextViewText(R.id.day_number, "");
//                dayView.setViewVisibility(R.id.protein_indicator, View.INVISIBLE);
                    views.addView(R.id.calendar_grid, dayView);
                }

                // Add cells for each day of the month
                for (int day = 1; day <= daysInMonth; day++) {
                    cal.set(Calendar.DAY_OF_MONTH, day);

                    // Get protein intake for this day from SQLite
                    double intake = dbHelper.getDailyTotal(cal);

                    RemoteViews dayView = new RemoteViews(context.getPackageName(), R.layout.calendar_day_item);

                    // Set day number
                    dayView.setTextViewText(R.id.day_number, String.valueOf(day));

                    // Style today's date
                    if (isToday(cal)) {
                        dayView.setInt(R.id.day_number, "setBackgroundResource", R.drawable.today_background);
                        dayView.setTextColor(R.id.day_number, Color.parseColor("#1A1C1E"));
                    } else {
                        dayView.setInt(R.id.day_number, "setBackgroundResource", R.drawable.day_background);
                        dayView.setTextColor(R.id.day_number, Color.parseColor("#E6E1E5"));
                    }

                    // Set protein indicator and amount
                    if (intake > 0) {
//                    dayView.setViewVisibility(R.id.protein_indicator, View.VISIBLE);
                        dayView.setViewVisibility(R.id.protein_amount, View.VISIBLE);
                        dayView.setTextViewText(R.id.protein_amount, String.format("%.0fg", intake));

                        float percentage = (float) intake / targetProtein;

                        if (percentage >= 1.0f) {
//                        dayView.setInt(R.id.protein_indicator, "setBackgroundResource", R.drawable.indicator_achieved);
                            dayView.setTextColor(R.id.protein_amount, Color.parseColor("#4CAF50")); // Green for achieved
                        } else if (percentage >= 0.7f) {
//                        dayView.setInt(R.id.protein_indicator, "setBackgroundResource", R.drawable.indicator_partial);
                            dayView.setTextColor(R.id.protein_amount, Color.parseColor("#FFA726")); // Orange for partial
                        } else {
//                        dayView.setInt(R.id.protein_indicator, "setBackgroundResource", R.drawable.indicator_started);
                            dayView.setTextColor(R.id.protein_amount, Color.parseColor("#EF5350")); // Red for started
                        }
                    } else {
//                    dayView.setViewVisibility(R.id.protein_indicator, View.INVISIBLE);
                        dayView.setViewVisibility(R.id.protein_amount, View.INVISIBLE);
                    }

                    views.addView(R.id.calendar_grid, dayView);
                }

                // Add empty cells for remaining days to complete the grid
                int remainingCells = 42 - (firstDayOfWeek + daysInMonth); // 42 = 6 rows * 7 days
                for (int i = 0; i < remainingCells; i++) {
                    RemoteViews dayView = new RemoteViews(context.getPackageName(), R.layout.calendar_day_item);
                    dayView.setTextViewText(R.id.day_number, "");
//                dayView.setInt(R.id.protein_indicator, "setVisibility", 4); // INVISIBLE = 4
                    views.addView(R.id.calendar_grid, dayView);
                }

                // Add click listener for refresh
                Intent updateIntent = new Intent(context, MonthlyCalendarWidget.class);
                updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
                updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, new int[]{appWidgetId});
                PendingIntent pendingIntent = PendingIntent.getBroadcast(
                        context,
                        appWidgetId,
                        updateIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.calendar_grid, pendingIntent);
            }else{
                views = new RemoteViews(context.getPackageName(), R.layout.widget_premium_promo);
                views.setTextViewText(R.id.promo_title, "Monthly Progress");
                views.setTextViewText(R.id.promo_description, "Unlock Monthly protein tracking widget");

                // Add click listener to open premium page
                Intent premiumIntent = context.getPackageManager()
                        .getLaunchIntentForPackage(context.getPackageName());
                premiumIntent.putExtra("route", "/");
                PendingIntent pendingIntent = PendingIntent.getActivity(
                        context,
                        appWidgetId,
                        premiumIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.premium_container, pendingIntent);
            }

            // Update widget
            appWidgetManager.updateAppWidget(appWidgetId, views);
            Log.d(TAG, "Widget update completed successfully");
            
        } catch (Exception e) {
            Log.e(TAG, "Error updating widget: " + e.getMessage(), e);
        }
    }
    
    private boolean isToday(Calendar cal) {
        Calendar today = Calendar.getInstance();
        return cal.get(Calendar.YEAR) == today.get(Calendar.YEAR)
            && cal.get(Calendar.MONTH) == today.get(Calendar.MONTH)
            && cal.get(Calendar.DAY_OF_MONTH) == today.get(Calendar.DAY_OF_MONTH);
    }

    public static void notifyDataChanged(Context context) {
        Log.d(TAG, "notifyDataChanged called");
        try {
            Intent intent = new Intent(context, MonthlyCalendarWidget.class);
            intent.setAction(ACTION_DATA_UPDATED);
            context.sendBroadcast(intent);
            Log.d(TAG, "Broadcast sent for widget update");
        } catch (Exception e) {
            Log.e(TAG, "Error notifying data changed: " + e.getMessage(), e);
        }
    }

    // Add helper method for dp to px conversion
    private int dpToPx(Context context, int dp) {
        float density = context.getResources().getDisplayMetrics().density;
        return Math.round(dp * density);
    }

    private boolean isPremiumUser(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
//        boolean isTrialActive = prefs.getBoolean("flutter.is_trial_active", false);
        boolean isPremium = prefs.getBoolean("flutter.is_premium", false);
        return  isPremium;
    }
}
