package com.invictus.psoriasis;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

public class WidgetHelper {
    private final Context context;

    public WidgetHelper(Context context) {
        this.context = context;
    }

    public boolean isWidgetSupported() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            AppWidgetManager appWidgetManager = context.getSystemService(AppWidgetManager.class);
            return appWidgetManager.isRequestPinAppWidgetSupported();
        }
        return false;
    }

    public boolean requestPinWidget(String widgetType) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                AppWidgetManager appWidgetManager = context.getSystemService(AppWidgetManager.class);
                ComponentName myProvider;
                
                // Select widget provider based on type
                switch (widgetType) {
                    case "weekly":
                        myProvider = new ComponentName(context, WeeklyProteinWidget.class);
                        break;
                    case "monthly":
                        myProvider = new ComponentName(context, MonthlyCalendarWidget.class);
                        break;
                    default:
                        return false;
                }

                if (appWidgetManager.isRequestPinAppWidgetSupported()) {
                    // Request to pin the widget without callback
                    appWidgetManager.requestPinAppWidget(myProvider, null, null);
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
} 