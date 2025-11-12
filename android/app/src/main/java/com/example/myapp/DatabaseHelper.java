package com.invictus.psoriasis;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import android.content.SharedPreferences;

public class DatabaseHelper extends SQLiteOpenHelper {
    private static final String TAG = "DatabaseHelper";
    private static final String DATABASE_NAME = "protein_tracker.db";
    private static final int DATABASE_VERSION = 1;
    private static final String PREFS_NAME = "MyAppPrefs";
    private Context context;

    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
        this.context = context;
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        // We don't need to create tables as they are created by Flutter
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // Handle database upgrades if needed
    }

    public double getDailyTotal(Calendar date) {
        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
            String dateStr = dateFormat.format(date.getTime());
            
            // First try to get from SQLite database
            SQLiteDatabase db = this.getReadableDatabase();
            String query = "SELECT SUM(proteinAmount) FROM protein_intakes WHERE datetime LIKE ?";
            String[] selectionArgs = {dateStr + "%"};
            
            Cursor cursor = db.rawQuery(query, selectionArgs);
            double sqliteTotal = 0.0;
            if (cursor != null) {
                try {
                    if (cursor.moveToFirst()) {
                        sqliteTotal = cursor.getDouble(0);
                    }
                } finally {
                    cursor.close();
                }
            }
            
            // Then get from SharedPreferences
            SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
            String key = "flutter." + dateStr + "_protein";
            String value = prefs.getString(key, "0.0");
            double prefsTotal = 0.0;
            try {
                prefsTotal = Double.parseDouble(value);
            } catch (NumberFormatException e) {
                Log.e(TAG, "Error parsing SharedPreferences value: " + e.getMessage());
            }
            
            // Return the sum of both sources
            double total = sqliteTotal + prefsTotal;
            Log.d(TAG, "Total for " + dateStr + ": " + total + " (SQLite: " + sqliteTotal + ", Prefs: " + prefsTotal + ")");
            return total;
            
        } catch (Exception e) {
            Log.e(TAG, "Error getting daily total: " + e.getMessage());
            return 0.0;
        }
    }
}
