package com.invictus.carmaintenance;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.util.Log;
import android.util.TypedValue;
import android.widget.RemoteViews;
import android.content.ComponentName;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import android.view.View;

public class WeeklyProteinWidget extends AppWidgetProvider {
    private static final String TAG = "WeeklyProteinWidget";
    private static final String PREFS_NAME = "FlutterSharedPreferences";
    private static final String[] DAYS = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
    public static final String ACTION_DATA_UPDATED = "com.invictus.carmaintenance.ACTION_DATA_UPDATED";
    private static final int MIN_HEIGHT_DP = 5;
    private static final int MAX_HEIGHT_DP = 100;

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        
        if (ACTION_DATA_UPDATED.equals(intent.getAction())) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(new ComponentName(context, WeeklyProteinWidget.class));
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        Log.d(TAG, "onUpdate called for " + appWidgetIds.length + " widgets");
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    private int dpToPx(Context context, float dp) {
        return (int) (dp * context.getResources().getDisplayMetrics().density + 0.5f);
    }

    private void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        try {
            Log.d(TAG, "Starting widget update for ID: " + appWidgetId);
            RemoteViews views;
            
            if (isPremiumUser(context)) {
                // Show original weekly widget
                views = new RemoteViews(context.getPackageName(), R.layout.weekly_protein_widget);
                DatabaseHelper dbHelper = null;
                
                try {
                    // Get protein target from SharedPreferences
                    SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
                    String targetStr = prefs.getString("flutter.protein_target", "100.0");
                    float targetProtein = 100.0f;
                    try {
                        targetProtein = Float.parseFloat(targetStr);
                        if (targetProtein <= 0) targetProtein = 100.0f;
                    } catch (Exception e) {
                        Log.e(TAG, "Error parsing target: " + e.getMessage());
                    }
                    
                    // Update target text
                    views.setTextViewText(R.id.target_text, String.format(Locale.getDefault(), "Target: %.0fg", targetProtein));
                    
                    // Initialize database helper and get data
                    dbHelper = new DatabaseHelper(context);
                    Calendar cal = Calendar.getInstance();
                    double maxIntake = 0;
                    double[] intakes = new double[7];
                    String[] labels = new String[7];
                    boolean[] isToday = new boolean[7];
                    
                    // Collect data for last 7 days
                    for (int i = 0; i < 7; i++) {
                        try {
                            intakes[i] = dbHelper.getDailyTotal(cal);
                            labels[i] = DAYS[cal.get(Calendar.DAY_OF_WEEK) - 1];
                            isToday[i] = isToday(cal);
                            maxIntake = Math.max(maxIntake, intakes[i]);
                        } catch (Exception e) {
                            Log.e(TAG, "Error getting data for day " + i + ": " + e.getMessage());
                            intakes[i] = 0;
                            labels[i] = "---";
                            isToday[i] = false;
                        }
                        cal.add(Calendar.DAY_OF_MONTH, -1);
                    }
                    
                    float scaleReference = Math.max((float)maxIntake, targetProtein);
                    if (scaleReference <= 0) scaleReference = 100.0f;
                    
                    // Update each bar with RemoteViews compatible operations
                    for (int i = 0; i < 7; i++) {
                        try {
                            // Use direct IDs instead of dynamic generation
                            int barId = context.getResources().getIdentifier("bar_" + i, "id", context.getPackageName());
                            int labelId = context.getResources().getIdentifier("label_" + i, "id", context.getPackageName());
                            int amountId = context.getResources().getIdentifier("amount_" + i, "id", context.getPackageName());
                            
                            if (barId == 0 || labelId == 0 || amountId == 0) {
                                Log.e(TAG, "Failed to find view IDs for bar " + i);
                                continue;
                            }
                            
                            // Set label
                            views.setTextViewText(labelId, labels[6-i]);
                            
                            // Set amount visibility and text
                            if (intakes[6-i] > 0) {
                                views.setViewVisibility(amountId, View.VISIBLE);
                                views.setTextViewText(amountId, String.format(Locale.getDefault(), "%.0fg", intakes[6-i]));
                            } else {
                                views.setViewVisibility(amountId, View.GONE);
                            }
                            
                            // Set bar background using resource IDs
                            int backgroundResId;
                            if (isToday[6-i]) {
                                backgroundResId = R.drawable.today_background;
                            } else if (intakes[6-i] >= targetProtein) {
                                backgroundResId = R.drawable.indicator_achieved;
                            } else if (intakes[6-i] >= targetProtein * 0.7f) {
                                backgroundResId = R.drawable.indicator_partial;
                            } else if (intakes[6-i] > 0) {
                                backgroundResId = R.drawable.indicator_started;
                            } else {
                                backgroundResId = R.drawable.empty_bar;
                            }
                            views.setInt(barId, "setBackgroundResource", backgroundResId);
                            
                            // Calculate bar height based on protein intake
                            float heightPercentage;
                            if (targetProtein > 0) {
                                heightPercentage = (float) intakes[6-i] / scaleReference;
                            } else {
                                heightPercentage = 0;
                            }
                            
                            // Convert dp to pixels
                            int maxHeightPx = dpToPx(context, 150); // Increased for better visibility
                            int minHeightPx = dpToPx(context, 5);   // Minimum height in pixels
                            
                            // Calculate actual height
                            int barHeight;
                            if (intakes[6-i] <= 0) {
                                barHeight = minHeightPx;
                            } else {
                                // Calculate height while ensuring minimum
                                barHeight = Math.max(minHeightPx, 
                                    (int)(heightPercentage * maxHeightPx));
                            }
                            
                            // Update the layout parameters for the bar
                            views.setInt(barId, "setHeight", barHeight);
                            
                            // Log the values for debugging
                            Log.d(TAG, String.format("Bar %d: intake=%.1f, percentage=%.2f, height=%d", 
                                i, intakes[6-i], heightPercentage, barHeight));
                            
                            // Make sure the bar is visible
                            views.setViewVisibility(barId, View.VISIBLE);
                            
                        } catch (Exception e) {
                            Log.e(TAG, "Error updating bar " + i + ": " + e.getMessage());
                        }
                    }
                    
                    // Add click listener for refresh
                    Intent updateIntent = new Intent(context, WeeklyProteinWidget.class);
                    updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
                    updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, new int[]{appWidgetId});
                    PendingIntent pendingIntent = PendingIntent.getBroadcast(
                        context, 
                        appWidgetId, 
                        updateIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                    );
                    views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);
                    
                } finally {
                    if (dbHelper != null) {
                        dbHelper.close();
                    }
                }
            } else {
                // Show premium promotion layout
                views = new RemoteViews(context.getPackageName(), R.layout.widget_premium_promo);
                views.setTextViewText(R.id.promo_title, "Weekly Progress");
                views.setTextViewText(R.id.promo_description, "Unlock weekly protein tracking widget");
                
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
            Intent intent = new Intent(context, WeeklyProteinWidget.class);
            intent.setAction(ACTION_DATA_UPDATED);
            context.sendBroadcast(intent);
            Log.d(TAG, "Broadcast sent for widget update");
        } catch (Exception e) {
            Log.e(TAG, "Error notifying data changed: " + e.getMessage(), e);
        }
    }

    private void setViewLayoutHeight(RemoteViews views, int viewId, int height) {
        try {
            views.setInt(viewId, "setMinimumHeight", height);
            views.setInt(viewId, "setHeight", height);
        } catch (Exception e) {
            Log.e(TAG, "Error setting view height: " + e.getMessage());
        }
    }

    private boolean isPremiumUser(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
//        boolean isTrialActive = prefs.getBoolean("flutter.is_trial_active", false);
        boolean isPremium = prefs.getBoolean("flutter.is_premium", false);
        return isPremium;
    }
}
