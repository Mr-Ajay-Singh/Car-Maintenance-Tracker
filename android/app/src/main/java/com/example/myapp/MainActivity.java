package com.invictus.carmaintenance;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private void setupWidgetMethodChannel(FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.invictus.carmaintenance/widget")
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "isWidgetSupported":
                            WidgetHelper widgetHelper1 = new WidgetHelper(this);
                            result.success(widgetHelper1.isWidgetSupported());
                            break;
                        case "addWidget":
                            String widgetType = call.argument("type");
                            if (widgetType == null) {
                                result.error("INVALID_ARGUMENT", "Widget type is required", null);
                                return;
                            }
                            WidgetHelper widgetHelper2 = new WidgetHelper(this);
                            result.success(widgetHelper2.requestPinWidget(widgetType));
                            break;
                        case "updateWidget":
                            // Update both weekly and monthly widgets
                            Intent weeklyIntent = new Intent(this, WeeklyProteinWidget.class);
                            weeklyIntent.setAction(WeeklyProteinWidget.ACTION_DATA_UPDATED);
                            sendBroadcast(weeklyIntent);

                            Intent monthlyIntent = new Intent(this, MonthlyCalendarWidget.class);
                            monthlyIntent.setAction(MonthlyCalendarWidget.ACTION_DATA_UPDATED);
                            sendBroadcast(monthlyIntent);
                            
                            result.success(true);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        setupWidgetMethodChannel(flutterEngine);
    }
}
