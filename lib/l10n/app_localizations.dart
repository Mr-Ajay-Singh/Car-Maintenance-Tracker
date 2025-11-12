import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gu'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('nl'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @meetPetTracker.
  ///
  /// In en, this message translates to:
  /// **'Meet Pet Tracker'**
  String get meetPetTracker;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favourite;

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Type Here'**
  String get typeHere;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @proteinAmount.
  ///
  /// In en, this message translates to:
  /// **'Fiber Amount (g)'**
  String get proteinAmount;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterValidProteinAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid protein amount'**
  String get pleaseEnterValidProteinAmount;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get protein;

  /// No description provided for @searchFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Search Food Items'**
  String get searchFoodItems;

  /// No description provided for @addIntake.
  ///
  /// In en, this message translates to:
  /// **'Add Intake'**
  String get addIntake;

  /// No description provided for @recentIntake.
  ///
  /// In en, this message translates to:
  /// **'Recent Intake'**
  String get recentIntake;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @doYouWantToDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this item'**
  String get doYouWantToDeleteItem;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add Favourite'**
  String get addFavorite;

  /// No description provided for @enterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Enter Food Name'**
  String get enterFoodName;

  /// No description provided for @enterProteinAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Fiber Amount'**
  String get enterProteinAmount;

  /// No description provided for @thisItemNeedQuantity.
  ///
  /// In en, this message translates to:
  /// **'This item needs quantity when added'**
  String get thisItemNeedQuantity;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get enterQuantity;

  /// No description provided for @baseProtein.
  ///
  /// In en, this message translates to:
  /// **'Base Fiber'**
  String get baseProtein;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @totalProtein.
  ///
  /// In en, this message translates to:
  /// **'Total Fiber'**
  String get totalProtein;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please Enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @deleteFavorite.
  ///
  /// In en, this message translates to:
  /// **'Delete Favorite'**
  String get deleteFavorite;

  /// No description provided for @doYouWantToDeleteFavorite.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this favourite item'**
  String get doYouWantToDeleteFavorite;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editFavourite.
  ///
  /// In en, this message translates to:
  /// **'Edit Favourite'**
  String get editFavourite;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @pleaseSelectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day'**
  String get pleaseSelectAtLeastOneDay;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorSavingReminder.
  ///
  /// In en, this message translates to:
  /// **'Error saving reminder'**
  String get errorSavingReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @refreshReminders.
  ///
  /// In en, this message translates to:
  /// **'Refresh reminders'**
  String get refreshReminders;

  /// No description provided for @refreshingReminders.
  ///
  /// In en, this message translates to:
  /// **'Refreshing reminders...'**
  String get refreshingReminders;

  /// No description provided for @noRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersYet;

  /// No description provided for @addReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder to get notified about your fiber intake'**
  String get addReminderDescription;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permissions are required for reminders to work properly.'**
  String get notificationPermissionRequired;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @loadingRemindersTimeout.
  ///
  /// In en, this message translates to:
  /// **'Loading reminders is taking longer than expected. Please try again.'**
  String get loadingRemindersTimeout;

  /// No description provided for @errorLoadingReminders.
  ///
  /// In en, this message translates to:
  /// **'Error loading reminders'**
  String get errorLoadingReminders;

  /// No description provided for @deleteReminderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get deleteReminderConfirmation;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get deleteReminder;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reminderTitle;

  /// No description provided for @enterReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter reminder title'**
  String get enterReminderTitle;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @reminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get reminderDescription;

  /// No description provided for @enterAdditionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter additional details'**
  String get enterAdditionalDetails;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @repeatOnDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat on Days'**
  String get repeatOnDays;

  /// No description provided for @updateReminder.
  ///
  /// In en, this message translates to:
  /// **'Update Reminder'**
  String get updateReminder;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminder;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @selectDataType.
  ///
  /// In en, this message translates to:
  /// **'Select Data Type'**
  String get selectDataType;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @pdfFormat.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfFormat;

  /// No description provided for @pdfDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed report with summary'**
  String get pdfDescription;

  /// No description provided for @csvFormat.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csvFormat;

  /// No description provided for @csvDescription.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet compatible data'**
  String get csvDescription;

  /// No description provided for @exportPreview.
  ///
  /// In en, this message translates to:
  /// **'Export Preview'**
  String get exportPreview;

  /// No description provided for @dataTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Data Type:'**
  String get dataTypeLabel;

  /// No description provided for @dateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Range:'**
  String get dateRangeLabel;

  /// No description provided for @formatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format:'**
  String get formatLabel;

  /// No description provided for @previewData.
  ///
  /// In en, this message translates to:
  /// **'Preview Data'**
  String get previewData;

  /// No description provided for @shareData.
  ///
  /// In en, this message translates to:
  /// **'Share Data'**
  String get shareData;

  /// No description provided for @getPremiumToExport.
  ///
  /// In en, this message translates to:
  /// **'Get Premium to Export'**
  String get getPremiumToExport;

  /// No description provided for @noDataForDateRange.
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected date range'**
  String get noDataForDateRange;

  /// No description provided for @noDataForPreview.
  ///
  /// In en, this message translates to:
  /// **'No data available for preview'**
  String get noDataForPreview;

  /// No description provided for @dataExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully as'**
  String get dataExportedSuccess;

  /// No description provided for @errorExportingData.
  ///
  /// In en, this message translates to:
  /// **'Error exporting data'**
  String get errorExportingData;

  /// No description provided for @errorGeneratingPreview.
  ///
  /// In en, this message translates to:
  /// **'Error generating preview'**
  String get errorGeneratingPreview;

  /// No description provided for @proteinData.
  ///
  /// In en, this message translates to:
  /// **'Fiber Data'**
  String get proteinData;

  /// No description provided for @waterData.
  ///
  /// In en, this message translates to:
  /// **'Water Data'**
  String get waterData;

  /// No description provided for @weightData.
  ///
  /// In en, this message translates to:
  /// **'Weight Data'**
  String get weightData;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @exploreFeatures.
  ///
  /// In en, this message translates to:
  /// **'Explore all the powerful features'**
  String get exploreFeatures;

  /// No description provided for @weightTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Tracker'**
  String get weightTrackerTitle;

  /// No description provided for @weightTrackerDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your weight progress with beautiful graphs and insights'**
  String get weightTrackerDescription;

  /// No description provided for @widgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'On-Screen Widgets'**
  String get widgetsTitle;

  /// No description provided for @widgetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Quick access widgets and home screen widgets for seamless fiber tracking'**
  String get widgetsDescription;

  /// No description provided for @waterTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Tracker'**
  String get waterTrackerTitle;

  /// No description provided for @waterTrackerDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated with our intelligent water tracking system'**
  String get waterTrackerDescription;

  /// No description provided for @suggestFeature.
  ///
  /// In en, this message translates to:
  /// **'Suggest a Feature'**
  String get suggestFeature;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featuresFooter.
  ///
  /// In en, this message translates to:
  /// **'These features are user-demanded, so we are dedicated to delivering the best experience for you.'**
  String get featuresFooter;

  /// No description provided for @foodDetails.
  ///
  /// In en, this message translates to:
  /// **'Food Details'**
  String get foodDetails;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search foods...'**
  String get searchFoods;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @proteinInfo.
  ///
  /// In en, this message translates to:
  /// **'Fiber:'**
  String get proteinInfo;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium feature.'**
  String get premiumFeature;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @intake.
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get intake;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @tapToUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Tap to upgrade'**
  String get tapToUpgrade;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noIntake.
  ///
  /// In en, this message translates to:
  /// **'No intake'**
  String get noIntake;

  /// No description provided for @targetHit.
  ///
  /// In en, this message translates to:
  /// **'Target hit'**
  String get targetHit;

  /// No description provided for @monthlyCalendar.
  ///
  /// In en, this message translates to:
  /// **'Monthly Calendar'**
  String get monthlyCalendar;

  /// No description provided for @trackProgressVisually.
  ///
  /// In en, this message translates to:
  /// **'Track your progress visually'**
  String get trackProgressVisually;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @visualCalendarOverview.
  ///
  /// In en, this message translates to:
  /// **'Visual Calendar Overview'**
  String get visualCalendarOverview;

  /// No description provided for @dailyProgressGlance.
  ///
  /// In en, this message translates to:
  /// **'See your daily progress at a glance'**
  String get dailyProgressGlance;

  /// No description provided for @progressInsights.
  ///
  /// In en, this message translates to:
  /// **'Progress Insights'**
  String get progressInsights;

  /// No description provided for @trackPatternsImprovements.
  ///
  /// In en, this message translates to:
  /// **'Track patterns and improvements'**
  String get trackPatternsImprovements;

  /// No description provided for @historicalData.
  ///
  /// In en, this message translates to:
  /// **'Historical Data'**
  String get historicalData;

  /// No description provided for @accessPastMonthsTrends.
  ///
  /// In en, this message translates to:
  /// **'Access past months and analyze trends'**
  String get accessPastMonthsTrends;

  /// No description provided for @unlockPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Features'**
  String get unlockPremiumFeatures;

  /// No description provided for @yearlyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Yearly Analysis'**
  String get yearlyAnalysis;

  /// No description provided for @monthlyInsights.
  ///
  /// In en, this message translates to:
  /// **'Monthly Insights'**
  String get monthlyInsights;

  /// No description provided for @trackYearlyProteinGoals.
  ///
  /// In en, this message translates to:
  /// **'Track your yearly fiber goals'**
  String get trackYearlyProteinGoals;

  /// No description provided for @monitorMonthlyProteinIntake.
  ///
  /// In en, this message translates to:
  /// **'Monitor monthly fiber intake'**
  String get monitorMonthlyProteinIntake;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @fullYearProgressAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Full Year Progress Analysis'**
  String get fullYearProgressAnalysis;

  /// No description provided for @detailedMonthlyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Detailed Monthly Breakdown'**
  String get detailedMonthlyBreakdown;

  /// No description provided for @yearOverYearComparison.
  ///
  /// In en, this message translates to:
  /// **'Year-over-Year Comparison'**
  String get yearOverYearComparison;

  /// No description provided for @monthOverMonthTrends.
  ///
  /// In en, this message translates to:
  /// **'Month-over-Month Trends'**
  String get monthOverMonthTrends;

  /// No description provided for @addWidget.
  ///
  /// In en, this message translates to:
  /// **'Add Widget'**
  String get addWidget;

  /// No description provided for @proteinHistory.
  ///
  /// In en, this message translates to:
  /// **'Fiber History'**
  String get proteinHistory;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noProteinIntakeRecords.
  ///
  /// In en, this message translates to:
  /// **'No fiber intake records found'**
  String get noProteinIntakeRecords;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalAmount;

  /// No description provided for @featuresHub.
  ///
  /// In en, this message translates to:
  /// **'Features Hub'**
  String get featuresHub;

  /// No description provided for @enhanceProteinTracking.
  ///
  /// In en, this message translates to:
  /// **'Enhance your fiber tracking'**
  String get enhanceProteinTracking;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @upgradeToPremiun.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiun;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'UTILITIES'**
  String get utilities;

  /// No description provided for @onScreenWidgets.
  ///
  /// In en, this message translates to:
  /// **'On-Screen Widgets'**
  String get onScreenWidgets;

  /// No description provided for @quickAccessProteinTracking.
  ///
  /// In en, this message translates to:
  /// **'Quick access fiber tracking'**
  String get quickAccessProteinTracking;

  /// No description provided for @exportYourProteinData.
  ///
  /// In en, this message translates to:
  /// **'Export your fiber data'**
  String get exportYourProteinData;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get dailyReminders;

  /// No description provided for @scheduleProteinIntakeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Schedule fiber intake alerts'**
  String get scheduleProteinIntakeAlerts;

  /// No description provided for @trackingTools.
  ///
  /// In en, this message translates to:
  /// **'TRACKING TOOLS'**
  String get trackingTools;

  /// No description provided for @trackYourWeightProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your weight progress'**
  String get trackYourWeightProgress;

  /// No description provided for @bodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurements;

  /// No description provided for @trackYourBodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Track your body measurements'**
  String get trackYourBodyMeasurements;

  /// No description provided for @stayHydratedWithTracking.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated with tracking'**
  String get stayHydratedWithTracking;

  /// No description provided for @supplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get supplements;

  /// No description provided for @trackYourSupplementsIntake.
  ///
  /// In en, this message translates to:
  /// **'Track your supplements intake'**
  String get trackYourSupplementsIntake;

  /// No description provided for @progressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotos;

  /// No description provided for @trackYourVisualProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your visual progress'**
  String get trackYourVisualProgress;

  /// No description provided for @proteinTracker.
  ///
  /// In en, this message translates to:
  /// **'Fiber Tracker'**
  String get proteinTracker;

  /// No description provided for @keepUpProteinPower.
  ///
  /// In en, this message translates to:
  /// **'Keep up the fiber power! 💪'**
  String get keepUpProteinPower;

  /// No description provided for @todaysIntake.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Intake'**
  String get todaysIntake;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteEntry;

  /// No description provided for @deleteEntryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry?'**
  String get deleteEntryConfirmation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @upgradeToPremiumTooltip.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumTooltip;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @bodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body Part'**
  String get bodyPart;

  /// No description provided for @measurementValue.
  ///
  /// In en, this message translates to:
  /// **'Measurement Value'**
  String get measurementValue;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @saveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save Measurement'**
  String get saveMeasurement;

  /// No description provided for @pleaseSelectBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Please select a body part'**
  String get pleaseSelectBodyPart;

  /// No description provided for @pleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pleaseEnterValue;

  /// No description provided for @valueMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Value must be greater than 0'**
  String get valueMustBeGreaterThanZero;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @errorSavingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Error saving measurement'**
  String get errorSavingMeasurement;

  /// No description provided for @noBodyPartsEnabled.
  ///
  /// In en, this message translates to:
  /// **'No body parts enabled'**
  String get noBodyPartsEnabled;

  /// No description provided for @enableBodyPartsToTrack.
  ///
  /// In en, this message translates to:
  /// **'Enable body parts to start tracking measurements'**
  String get enableBodyPartsToTrack;

  /// No description provided for @enableBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Enable Body Parts'**
  String get enableBodyParts;

  /// No description provided for @selectedDate.
  ///
  /// In en, this message translates to:
  /// **'Selected Date'**
  String get selectedDate;

  /// No description provided for @allMeasurements.
  ///
  /// In en, this message translates to:
  /// **'All Measurements'**
  String get allMeasurements;

  /// No description provided for @noMeasurementsForDate.
  ///
  /// In en, this message translates to:
  /// **'No measurements for this date'**
  String get noMeasurementsForDate;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @deleteMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Delete Measurement'**
  String get deleteMeasurement;

  /// No description provided for @deleteMeasurementConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this measurement?'**
  String get deleteMeasurementConfirmation;

  /// No description provided for @currentUnit.
  ///
  /// In en, this message translates to:
  /// **'Current Unit'**
  String get currentUnit;

  /// No description provided for @switchToCm.
  ///
  /// In en, this message translates to:
  /// **'Switch to cm'**
  String get switchToCm;

  /// No description provided for @switchToIn.
  ///
  /// In en, this message translates to:
  /// **'Switch to in'**
  String get switchToIn;

  /// No description provided for @centimeters.
  ///
  /// In en, this message translates to:
  /// **'Centimeters (cm)'**
  String get centimeters;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'Inches (in)'**
  String get inches;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE TO PRO'**
  String get upgradeToPro;

  /// No description provided for @unlockYourFullPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Full Potential'**
  String get unlockYourFullPotential;

  /// No description provided for @limitedTime.
  ///
  /// In en, this message translates to:
  /// **'Limited Time'**
  String get limitedTime;

  /// No description provided for @claimNow.
  ///
  /// In en, this message translates to:
  /// **'Claim Now'**
  String get claimNow;

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-time payment. 30-day money-back guarantee.'**
  String get oneTimePayment;

  /// No description provided for @detailedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analytics'**
  String get detailedAnalytics;

  /// No description provided for @trackWeeklyMonthlyYearly.
  ///
  /// In en, this message translates to:
  /// **'Track weekly, monthly, and yearly fiber intake trends'**
  String get trackWeeklyMonthlyYearly;

  /// No description provided for @viewDetailedMonthlyCalendar.
  ///
  /// In en, this message translates to:
  /// **'View detailed monthly calendar and yearly progress charts'**
  String get viewDetailedMonthlyCalendar;

  /// No description provided for @advancedFoodFeatures.
  ///
  /// In en, this message translates to:
  /// **'Advanced Food Features'**
  String get advancedFoodFeatures;

  /// No description provided for @advancedFoodSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced Food Search'**
  String get advancedFoodSearch;

  /// No description provided for @accessCompleteFoodDatabase.
  ///
  /// In en, this message translates to:
  /// **'Access our complete database of fiber-rich foods'**
  String get accessCompleteFoodDatabase;

  /// No description provided for @saveQuickAccessFavorites.
  ///
  /// In en, this message translates to:
  /// **'Save and quickly access your favorite fiber sources'**
  String get saveQuickAccessFavorites;

  /// No description provided for @progressTracking.
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get progressTracking;

  /// No description provided for @advancedCharts.
  ///
  /// In en, this message translates to:
  /// **'Advanced Charts'**
  String get advancedCharts;

  /// No description provided for @detailedProgressVisualization.
  ///
  /// In en, this message translates to:
  /// **'Detailed progress visualization'**
  String get detailedProgressVisualization;

  /// No description provided for @personalizedInsights.
  ///
  /// In en, this message translates to:
  /// **'Personalized insights & recommendations'**
  String get personalizedInsights;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'SPECIAL OFFER'**
  String get specialOffer;

  /// No description provided for @endsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in'**
  String get endsIn;

  /// No description provided for @premiumFeatureMessage.
  ///
  /// In en, this message translates to:
  /// **'Premium feature. Upgrade to access period data.'**
  String get premiumFeatureMessage;

  /// No description provided for @monthlyData.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get monthlyData;

  /// No description provided for @yearlyData.
  ///
  /// In en, this message translates to:
  /// **'yearly'**
  String get yearlyData;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upgradeExclamation.
  ///
  /// In en, this message translates to:
  /// **'Upgrade!'**
  String get upgradeExclamation;

  /// No description provided for @trialEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Trial ends in'**
  String get trialEndsIn;

  /// No description provided for @trialExpired.
  ///
  /// In en, this message translates to:
  /// **'Trial Expired'**
  String get trialExpired;

  /// No description provided for @unlimitedProteinTracking.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Fiber Tracking'**
  String get unlimitedProteinTracking;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// No description provided for @detailedHistory.
  ///
  /// In en, this message translates to:
  /// **'Detailed History'**
  String get detailedHistory;

  /// No description provided for @unlimitedFavorites.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Favorites'**
  String get unlimitedFavorites;

  /// No description provided for @progressInsightsFeature.
  ///
  /// In en, this message translates to:
  /// **'Progress Insights'**
  String get progressInsightsFeature;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all these amazing features today!'**
  String get unlockAllFeatures;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @last12Months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 Months'**
  String get last12Months;

  /// No description provided for @trackYearlyMeasurementProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your yearly measurement progress'**
  String get trackYearlyMeasurementProgress;

  /// No description provided for @monitorMonthlyMeasurementChanges.
  ///
  /// In en, this message translates to:
  /// **'Monitor monthly measurement changes'**
  String get monitorMonthlyMeasurementChanges;

  /// No description provided for @noDataAvailableForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data available for this period'**
  String get noDataAvailableForPeriod;

  /// No description provided for @addFirstMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add your first measurement'**
  String get addFirstMeasurement;

  /// No description provided for @measurementUnit.
  ///
  /// In en, this message translates to:
  /// **'Measurement Unit'**
  String get measurementUnit;

  /// No description provided for @measurementSettings.
  ///
  /// In en, this message translates to:
  /// **'Measurement Settings'**
  String get measurementSettings;

  /// No description provided for @bodyParts.
  ///
  /// In en, this message translates to:
  /// **'Body Parts'**
  String get bodyParts;

  /// No description provided for @selectBodyPartsToTrack.
  ///
  /// In en, this message translates to:
  /// **'Select which body parts you want to track measurements for:'**
  String get selectBodyPartsToTrack;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @upperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBody;

  /// No description provided for @arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// No description provided for @lowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBody;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @leftRightTracking.
  ///
  /// In en, this message translates to:
  /// **'Left & Right Tracking'**
  String get leftRightTracking;

  /// No description provided for @trackLeftRightSeparately.
  ///
  /// In en, this message translates to:
  /// **'Track measurements for left and right sides separately'**
  String get trackLeftRightSeparately;

  /// No description provided for @muscleSymmetry.
  ///
  /// In en, this message translates to:
  /// **'Track muscle symmetry and imbalances'**
  String get muscleSymmetry;

  /// No description provided for @monitorProgress.
  ///
  /// In en, this message translates to:
  /// **'Monitor progress for each side independently'**
  String get monitorProgress;

  /// No description provided for @trackRehabilitation.
  ///
  /// In en, this message translates to:
  /// **'Track rehabilitation progress for injuries'**
  String get trackRehabilitation;

  /// No description provided for @createLeftRightPair.
  ///
  /// In en, this message translates to:
  /// **'Create Left & Right Pair'**
  String get createLeftRightPair;

  /// No description provided for @createSeparateMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Create separate measurements for left and right sides'**
  String get createSeparateMeasurements;

  /// No description provided for @saveCustomMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save Custom Measurement'**
  String get saveCustomMeasurement;

  /// No description provided for @customMeasurementAdded.
  ///
  /// In en, this message translates to:
  /// **'Custom measurement added'**
  String get customMeasurementAdded;

  /// No description provided for @leftRightMeasurementsAdded.
  ///
  /// In en, this message translates to:
  /// **'Left & Right measurements added'**
  String get leftRightMeasurementsAdded;

  /// No description provided for @deleteMeasurementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Measurement'**
  String get deleteMeasurementTitle;

  /// No description provided for @deleteMeasurementConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this? This cannot be undone.'**
  String get deleteMeasurementConfirm;

  /// No description provided for @measurementHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Forearm, Calf, etc.'**
  String get measurementHint;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'data.'**
  String get data;

  /// No description provided for @measurement.
  ///
  /// In en, this message translates to:
  /// **'measurement'**
  String get measurement;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSureDelete;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @progressPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotosTitle;

  /// No description provided for @noProgressPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No progress photos yet'**
  String get noProgressPhotosYet;

  /// No description provided for @addPhotosToTrackProgress.
  ///
  /// In en, this message translates to:
  /// **'Add photos to track your progress'**
  String get addPhotosToTrackProgress;

  /// No description provided for @addFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add First Photo'**
  String get addFirstPhoto;

  /// No description provided for @addProgressPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Progress Photo'**
  String get addProgressPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @viewFullImage.
  ///
  /// In en, this message translates to:
  /// **'View Full Image'**
  String get viewFullImage;

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @downloadImage.
  ///
  /// In en, this message translates to:
  /// **'Download Image'**
  String get downloadImage;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @editExistingNote.
  ///
  /// In en, this message translates to:
  /// **'Edit existing note'**
  String get editExistingNote;

  /// No description provided for @addNoteToPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a note to this photo'**
  String get addNoteToPhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @selectOneMorePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select one more photo to compare'**
  String get selectOneMorePhoto;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note:'**
  String get note;

  /// No description provided for @enterNoteForPhoto.
  ///
  /// In en, this message translates to:
  /// **'Enter a note for this photo'**
  String get enterNoteForPhoto;

  /// No description provided for @deletePhotoConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo?'**
  String get deletePhotoConfirmation;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @photoSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Photo saved successfully'**
  String get photoSavedSuccessfully;

  /// No description provided for @errorSavingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error saving photo'**
  String get errorSavingPhoto;

  /// No description provided for @errorLoadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Error loading photos'**
  String get errorLoadingPhotos;

  /// No description provided for @imageSavedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'Image saved to Downloads folder'**
  String get imageSavedToDownloads;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get share;

  /// No description provided for @errorSavingImage.
  ///
  /// In en, this message translates to:
  /// **'Error saving image'**
  String get errorSavingImage;

  /// No description provided for @progressPhotoFromApp.
  ///
  /// In en, this message translates to:
  /// **'Progress photo from Fiber Tracker\n\nTrack your fitness journey with our app'**
  String get progressPhotoFromApp;

  /// No description provided for @welcomeToProgressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Progress Photos!'**
  String get welcomeToProgressPhotos;

  /// No description provided for @trackFitnessJourney.
  ///
  /// In en, this message translates to:
  /// **'Track your fitness journey with progress photos. Select two photos to compare them side by side or with our interactive slider.'**
  String get trackFitnessJourney;

  /// No description provided for @photoManagementTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Long-press on photos to add notes or manage them.'**
  String get photoManagementTip;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get last90Days;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @photoComparison.
  ///
  /// In en, this message translates to:
  /// **'Photo Comparison'**
  String get photoComparison;

  /// No description provided for @sideBySide.
  ///
  /// In en, this message translates to:
  /// **'Side by Side'**
  String get sideBySide;

  /// No description provided for @sliderView.
  ///
  /// In en, this message translates to:
  /// **'Slider View'**
  String get sliderView;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @beforeNote.
  ///
  /// In en, this message translates to:
  /// **'Before Note:'**
  String get beforeNote;

  /// No description provided for @afterNote.
  ///
  /// In en, this message translates to:
  /// **'After Note:'**
  String get afterNote;

  /// No description provided for @proteinCalculator.
  ///
  /// In en, this message translates to:
  /// **'Fiber Calculator'**
  String get proteinCalculator;

  /// No description provided for @calculateDailyProtein.
  ///
  /// In en, this message translates to:
  /// **'Calculate Daily Fiber'**
  String get calculateDailyProtein;

  /// No description provided for @updateProteinTarget.
  ///
  /// In en, this message translates to:
  /// **'Update Fiber Target'**
  String get updateProteinTarget;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'Enter weight in kg'**
  String get weightHint;

  /// No description provided for @whatGender.
  ///
  /// In en, this message translates to:
  /// **'What is your gender?'**
  String get whatGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @whatGoal.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get whatGoal;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// No description provided for @maintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// No description provided for @gainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain Muscle'**
  String get gainMuscle;

  /// No description provided for @applyForever.
  ///
  /// In en, this message translates to:
  /// **'Apply Forever'**
  String get applyForever;

  /// No description provided for @enterWeightToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight to calculate fiber needs'**
  String get enterWeightToCalculate;

  /// No description provided for @dailyProteinGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Fiber Goal'**
  String get dailyProteinGoal;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// No description provided for @enjoyingApp.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Fiber Tracker?'**
  String get enjoyingApp;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How would you rate your experience?'**
  String get rateYourExperience;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @proteinGoal.
  ///
  /// In en, this message translates to:
  /// **'Fiber goal'**
  String get proteinGoal;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @proteinTarget.
  ///
  /// In en, this message translates to:
  /// **'Fiber Target'**
  String get proteinTarget;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @addSupplement.
  ///
  /// In en, this message translates to:
  /// **'Add Supplement'**
  String get addSupplement;

  /// No description provided for @editSupplement.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplement'**
  String get editSupplement;

  /// No description provided for @supplementDetails.
  ///
  /// In en, this message translates to:
  /// **'Supplement Details'**
  String get supplementDetails;

  /// No description provided for @supplementNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Vitamin D, Zinc, etc.'**
  String get supplementNameHint;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @supplementDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Supports immune function'**
  String get supplementDescriptionHint;

  /// No description provided for @defaultAmount.
  ///
  /// In en, this message translates to:
  /// **'Default Amount'**
  String get defaultAmount;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1000'**
  String get amountHint;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., mg, IU'**
  String get unitHint;

  /// No description provided for @pleaseEnterUnit.
  ///
  /// In en, this message translates to:
  /// **'Please enter a unit'**
  String get pleaseEnterUnit;

  /// No description provided for @updateSupplement.
  ///
  /// In en, this message translates to:
  /// **'Update Supplement'**
  String get updateSupplement;

  /// No description provided for @supplementUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get supplementUpdatedSuccess;

  /// No description provided for @supplementAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get supplementAddedSuccess;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @monthlyYearlyViewsPremium.
  ///
  /// In en, this message translates to:
  /// **'Monthly and yearly views are premium features.'**
  String get monthlyYearlyViewsPremium;

  /// No description provided for @upgradeToPremiumTo.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to premium to:'**
  String get upgradeToPremiumTo;

  /// No description provided for @viewMonthlyYearlyData.
  ///
  /// In en, this message translates to:
  /// **'View monthly and yearly data'**
  String get viewMonthlyYearlyData;

  /// No description provided for @trackLongTermPatterns.
  ///
  /// In en, this message translates to:
  /// **'Track long-term supplement patterns'**
  String get trackLongTermPatterns;

  /// No description provided for @accessHistoricalData.
  ///
  /// In en, this message translates to:
  /// **'Access historical data analysis'**
  String get accessHistoricalData;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistoryFor.
  ///
  /// In en, this message translates to:
  /// **'No history for'**
  String get noHistoryFor;

  /// No description provided for @noSupplementHistory.
  ///
  /// In en, this message translates to:
  /// **'No supplement history'**
  String get noSupplementHistory;

  /// No description provided for @logSomeIntakesToSeeThemHere.
  ///
  /// In en, this message translates to:
  /// **'Log some intakes to see them here'**
  String get logSomeIntakesToSeeThemHere;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @supplementsTracker.
  ///
  /// In en, this message translates to:
  /// **'Supplements Tracker'**
  String get supplementsTracker;

  /// No description provided for @noSupplementsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No supplements added yet'**
  String get noSupplementsAddedYet;

  /// No description provided for @todaysIntakes.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Intakes'**
  String get todaysIntakes;

  /// No description provided for @intakes.
  ///
  /// In en, this message translates to:
  /// **'intakes'**
  String get intakes;

  /// No description provided for @noIntakesOn.
  ///
  /// In en, this message translates to:
  /// **'No intakes on'**
  String get noIntakesOn;

  /// No description provided for @tapButtonToLogSupplementIntake.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to log a supplement intake'**
  String get tapButtonToLogSupplementIntake;

  /// No description provided for @mySupplements.
  ///
  /// In en, this message translates to:
  /// **'My Supplements'**
  String get mySupplements;

  /// No description provided for @viewGraph.
  ///
  /// In en, this message translates to:
  /// **'View Graph'**
  String get viewGraph;

  /// No description provided for @logIntake.
  ///
  /// In en, this message translates to:
  /// **'Log Intake'**
  String get logIntake;

  /// No description provided for @deleteSupplementConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this supplement? This will also delete all intake records for this supplement.'**
  String get deleteSupplementConfirmation;

  /// No description provided for @selectASupplement.
  ///
  /// In en, this message translates to:
  /// **'Select a supplement'**
  String get selectASupplement;

  /// No description provided for @pleaseSelectASupplement.
  ///
  /// In en, this message translates to:
  /// **'Please select a supplement'**
  String get pleaseSelectASupplement;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @logSupplementIntake.
  ///
  /// In en, this message translates to:
  /// **'Log Supplement Intake'**
  String get logSupplementIntake;

  /// No description provided for @selectSupplement.
  ///
  /// In en, this message translates to:
  /// **'Select a supplement:'**
  String get selectSupplement;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount:'**
  String get amount;

  /// No description provided for @pleaseEnterAnAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAnAmount;

  /// No description provided for @supplementIntakeLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Intake logged successfully'**
  String get supplementIntakeLoggedSuccess;

  /// No description provided for @waterHistory.
  ///
  /// In en, this message translates to:
  /// **'Water History'**
  String get waterHistory;

  /// No description provided for @waterTracker.
  ///
  /// In en, this message translates to:
  /// **'Water Tracker'**
  String get waterTracker;

  /// No description provided for @waterTrackerSettings.
  ///
  /// In en, this message translates to:
  /// **'Water Tracker Settings'**
  String get waterTrackerSettings;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @weeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get weeklyAverage;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @ofDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'of goal'**
  String get ofDailyGoal;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @dailyGoalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Daily goal achieved! 🎉'**
  String get dailyGoalAchieved;

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievement;

  /// No description provided for @todaysEntries.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Entries'**
  String get todaysEntries;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// No description provided for @tea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get tea;

  /// No description provided for @juice.
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get juice;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @editWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Edit Water Intake'**
  String get editWaterIntake;

  /// No description provided for @addWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Add Water Intake'**
  String get addWaterIntake;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select Unit'**
  String get selectUnit;

  /// No description provided for @milliliters.
  ///
  /// In en, this message translates to:
  /// **'Milliliters (ml)'**
  String get milliliters;

  /// No description provided for @fluidOunces.
  ///
  /// In en, this message translates to:
  /// **'Fluid Ounces (fl oz)'**
  String get fluidOunces;

  /// No description provided for @setDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Goal'**
  String get setDailyGoal;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @selectedDaySummary.
  ///
  /// In en, this message translates to:
  /// **'Selected Day Summary'**
  String get selectedDaySummary;

  /// No description provided for @totalIntake.
  ///
  /// In en, this message translates to:
  /// **'Total Intake'**
  String get totalIntake;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @drinkTypes.
  ///
  /// In en, this message translates to:
  /// **'Drink Types'**
  String get drinkTypes;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data available for this period'**
  String get noDataForPeriod;

  /// No description provided for @noWaterRecords.
  ///
  /// In en, this message translates to:
  /// **'No water intake records yet'**
  String get noWaterRecords;

  /// No description provided for @dailyGoalAmount.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal Amount'**
  String get dailyGoalAmount;

  /// No description provided for @weightHistory.
  ///
  /// In en, this message translates to:
  /// **'Weight History'**
  String get weightHistory;

  /// No description provided for @weightTracker.
  ///
  /// In en, this message translates to:
  /// **'Weight Tracker'**
  String get weightTracker;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @recentItems.
  ///
  /// In en, this message translates to:
  /// **'Recent Items'**
  String get recentItems;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @addWeight.
  ///
  /// In en, this message translates to:
  /// **'Add Weight'**
  String get addWeight;

  /// No description provided for @pleaseEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight'**
  String get pleaseEnterWeight;

  /// No description provided for @noWeightLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No weight logs yet'**
  String get noWeightLogsYet;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @noWeightLogsForSelectedDateRange.
  ///
  /// In en, this message translates to:
  /// **'No weight logs for selected date range'**
  String get noWeightLogsForSelectedDateRange;

  /// No description provided for @noWeightLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No weight logs found'**
  String get noWeightLogsFound;

  /// No description provided for @highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highest;

  /// No description provided for @lowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get lowest;

  /// No description provided for @addWidgetToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add Widget to Home Screen'**
  String get addWidgetToHomeScreen;

  /// No description provided for @chooseWidgetToAddToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Choose a widget to add to your home screen:'**
  String get chooseWidgetToAddToHomeScreen;

  /// No description provided for @weeklyProteinWidget.
  ///
  /// In en, this message translates to:
  /// **'Weekly Fiber Widget'**
  String get weeklyProteinWidget;

  /// No description provided for @monthlyCalendarWidget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Calendar Widget'**
  String get monthlyCalendarWidget;

  /// No description provided for @longPressOnHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Long press on home screen'**
  String get longPressOnHomeScreen;

  /// No description provided for @findWidgetsOption.
  ///
  /// In en, this message translates to:
  /// **'Find Widgets option'**
  String get findWidgetsOption;

  /// No description provided for @lookForWidgetsOrAWidgetIconInTheMenuThatAppears.
  ///
  /// In en, this message translates to:
  /// **'Look for \"Widgets\" or a widget icon in the menu that appears'**
  String get lookForWidgetsOrAWidgetIconInTheMenuThatAppears;

  /// No description provided for @trackYourWeeklyProteinIntakeProgressWithAVisualBarChart.
  ///
  /// In en, this message translates to:
  /// **'Track your weekly fiber intake progress with a visual bar chart'**
  String get trackYourWeeklyProteinIntakeProgressWithAVisualBarChart;

  /// No description provided for @viewYourMonthlyProteinIntakeWithACalendarView.
  ///
  /// In en, this message translates to:
  /// **'View your monthly fiber intake with a calendar view'**
  String get viewYourMonthlyProteinIntakeWithACalendarView;

  /// No description provided for @findAnEmptySpaceOnYourHomeScreenAndLongPressIt.
  ///
  /// In en, this message translates to:
  /// **'Find an empty space on your home screen and long press it'**
  String get findAnEmptySpaceOnYourHomeScreenAndLongPressIt;

  /// No description provided for @dragAndDropTheWidgetToYourDesiredLocation.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop the widget to your desired location'**
  String get dragAndDropTheWidgetToYourDesiredLocation;

  /// No description provided for @addTheWidget.
  ///
  /// In en, this message translates to:
  /// **'Add the widget'**
  String get addTheWidget;

  /// No description provided for @findProteinTrackerInTheWidgetsList.
  ///
  /// In en, this message translates to:
  /// **'Find \"Fiber Tracker\" in the widgets list'**
  String get findProteinTrackerInTheWidgetsList;

  /// No description provided for @searchForTheApp.
  ///
  /// In en, this message translates to:
  /// **'Search for the app'**
  String get searchForTheApp;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'added successfully'**
  String get addedSuccessfully;

  /// No description provided for @tapThePlusButtonToLogASupplementIntake.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to log a supplement intake'**
  String get tapThePlusButtonToLogASupplementIntake;

  /// No description provided for @areYouSureYouWantToDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSureYouWantToDelete;

  /// No description provided for @thisWillAlsoDeleteAllIntakeRecordsForThisSupplement.
  ///
  /// In en, this message translates to:
  /// **'This will also delete all intake records for this supplement'**
  String get thisWillAlsoDeleteAllIntakeRecordsForThisSupplement;

  /// No description provided for @pleaseAddASupplementFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add a supplement first'**
  String get pleaseAddASupplementFirst;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @intakeLoggedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'intake logged successfully'**
  String get intakeLoggedSuccessfully;

  /// No description provided for @pleaseEnterAValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterAValidAmount;

  /// No description provided for @maxIntake.
  ///
  /// In en, this message translates to:
  /// **'Max Intake'**
  String get maxIntake;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @intakeChart.
  ///
  /// In en, this message translates to:
  /// **'Intake Chart'**
  String get intakeChart;

  /// No description provided for @extendedTimePeriods.
  ///
  /// In en, this message translates to:
  /// **'Extended Time Periods'**
  String get extendedTimePeriods;

  /// No description provided for @viewMonthlyAndYearlySupplementData.
  ///
  /// In en, this message translates to:
  /// **'View monthly and yearly supplement data'**
  String get viewMonthlyAndYearlySupplementData;

  /// No description provided for @trackPatternsAndImprovementsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Track patterns and improvements over time'**
  String get trackPatternsAndImprovementsOverTime;

  /// No description provided for @accessPastMonthsAndAnalyzeTrends.
  ///
  /// In en, this message translates to:
  /// **'Access past months and analyze trends'**
  String get accessPastMonthsAndAnalyzeTrends;

  /// No description provided for @monthlyChart.
  ///
  /// In en, this message translates to:
  /// **'Monthly Chart'**
  String get monthlyChart;

  /// No description provided for @yearlyChart.
  ///
  /// In en, this message translates to:
  /// **'Yearly Chart'**
  String get yearlyChart;

  /// No description provided for @unlockPremiumAndMaximizeProteinGoals.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium &\nMaximize Fiber Goals'**
  String get unlockPremiumAndMaximizeProteinGoals;

  /// No description provided for @trackWeeklyMonthlyAndYearlyProteinIntakeTrends.
  ///
  /// In en, this message translates to:
  /// **'Track weekly, monthly, and yearly fiber intake trends'**
  String get trackWeeklyMonthlyAndYearlyProteinIntakeTrends;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get dataExport;

  /// No description provided for @addUnlimitedProteinEntriesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Add unlimited fiber entries per day'**
  String get addUnlimitedProteinEntriesPerDay;

  /// No description provided for @saveAndQuicklyAccessYourFavoriteProteinSources.
  ///
  /// In en, this message translates to:
  /// **'Save and quickly access your favorite fiber sources'**
  String get saveAndQuicklyAccessYourFavoriteProteinSources;

  /// No description provided for @addUnlimitedCustomFoodItemsToYourDailyTracking.
  ///
  /// In en, this message translates to:
  /// **'Add unlimited custom food items to your daily tracking'**
  String get addUnlimitedCustomFoodItemsToYourDailyTracking;

  /// No description provided for @viewDetailedMonthlyCalendarAndYearlyProgressCharts.
  ///
  /// In en, this message translates to:
  /// **'View detailed monthly calendar and yearly progress charts'**
  String get viewDetailedMonthlyCalendarAndYearlyProgressCharts;

  /// No description provided for @exportYourProteinWaterAndWeightDataToPDFAndCSVFormats.
  ///
  /// In en, this message translates to:
  /// **'Export your fiber, water, and weight data to PDF and CSV formats'**
  String get exportYourProteinWaterAndWeightDataToPDFAndCSVFormats;

  /// No description provided for @getDetailedInsightsAndStatisticsAboutYourProteinGoals.
  ///
  /// In en, this message translates to:
  /// **'Get detailed insights and statistics about your fiber goals'**
  String get getDetailedInsightsAndStatisticsAboutYourProteinGoals;

  /// No description provided for @detailedAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your fiber intake progress with detailed analytics'**
  String get detailedAnalyticsDescription;

  /// No description provided for @advancedFoodSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for fiber-rich foods with advanced filters'**
  String get advancedFoodSearchDescription;

  /// No description provided for @progressInsightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get detailed insights and statistics about your fiber goals'**
  String get progressInsightsDescription;

  /// No description provided for @unlimitedDailyItemsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add unlimited fiber entries per day'**
  String get unlimitedDailyItemsDescription;

  /// No description provided for @favoriteItemsDescription.
  ///
  /// In en, this message translates to:
  /// **'Save and quickly access your favorite fiber sources'**
  String get favoriteItemsDescription;

  /// No description provided for @unlimitedFoodItemsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add unlimited custom food items to your daily tracking'**
  String get unlimitedFoodItemsDescription;

  /// No description provided for @advancedChartsDescription.
  ///
  /// In en, this message translates to:
  /// **'View detailed monthly calendar and yearly progress charts'**
  String get advancedChartsDescription;

  /// No description provided for @dataExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your fiber, water, and weight data to PDF and CSV formats'**
  String get dataExportDescription;

  /// No description provided for @accessOurCompleteDatabaseOfProteinRichFoods.
  ///
  /// In en, this message translates to:
  /// **'Access our complete database of fiber-rich foods'**
  String get accessOurCompleteDatabaseOfProteinRichFoods;

  /// No description provided for @unlimitedDailyItems.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Daily Items'**
  String get unlimitedDailyItems;

  /// No description provided for @favoriteItems.
  ///
  /// In en, this message translates to:
  /// **'Favorite Items'**
  String get favoriteItems;

  /// No description provided for @unlimitedFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Food Items'**
  String get unlimitedFoodItems;

  /// No description provided for @limitedTimeOffer.
  ///
  /// In en, this message translates to:
  /// **'Limited time Offer: '**
  String get limitedTimeOffer;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @startMyJourney.
  ///
  /// In en, this message translates to:
  /// **'Start My Journey'**
  String get startMyJourney;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noPlansAvailable;

  /// No description provided for @twentyFourSeven.
  ///
  /// In en, this message translates to:
  /// **'24/7'**
  String get twentyFourSeven;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @fitnessCommunity.
  ///
  /// In en, this message translates to:
  /// **'Fitness Community'**
  String get fitnessCommunity;

  /// No description provided for @goalSetting.
  ///
  /// In en, this message translates to:
  /// **'Goal Setting'**
  String get goalSetting;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @joinOurGrowingCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join Our Growing Community'**
  String get joinOurGrowingCommunity;

  /// No description provided for @thisAppHelpsMeStayConsistentWithMyProteinGoalsTheTrackingFeaturesAreExactlyWhatINeeded.
  ///
  /// In en, this message translates to:
  /// **'This app helps me stay consistent with my protein goals. The tracking features are exactly what I needed.'**
  String
      get thisAppHelpsMeStayConsistentWithMyProteinGoalsTheTrackingFeaturesAreExactlyWhatINeeded;

  /// No description provided for @greatForTrackingMyDailyProteinIntakeSimpleToUseAndHelpsMeMaintainMyFitnessRoutine.
  ///
  /// In en, this message translates to:
  /// **'Great for tracking my daily fiber intake. Simple to use and helps me maintain my fitness routine.'**
  String
      get greatForTrackingMyDailyProteinIntakeSimpleToUseAndHelpsMeMaintainMyFitnessRoutine;

  /// No description provided for @thePremiumFeaturesMakeProteinTrackingMuchEasierWorthTheUpgradeForTheAdvancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'The premium features make fiber tracking much easier. Worth the upgrade for the advanced analytics.'**
  String
      get thePremiumFeaturesMakeProteinTrackingMuchEasierWorthTheUpgradeForTheAdvancedAnalytics;

  /// No description provided for @whatOurUsersSay.
  ///
  /// In en, this message translates to:
  /// **'What Our Users Say'**
  String get whatOurUsersSay;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @monthlyRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically every month. Cancel anytime on Google Play'**
  String get monthlyRenews;

  /// No description provided for @annualRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically every year. Cancel anytime on Google Play'**
  String get annualRenews;

  /// No description provided for @lifetimeRenews.
  ///
  /// In en, this message translates to:
  /// **'One Time Payment. 3 day money-back guarantee'**
  String get lifetimeRenews;

  /// No description provided for @threeDayMoneyBackGuarantee.
  ///
  /// In en, this message translates to:
  /// **'3-day Money-Back Guarantee'**
  String get threeDayMoneyBackGuarantee;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get oneTime;

  /// No description provided for @annualFreeTrialRenews.
  ///
  /// In en, this message translates to:
  /// **'Free trial for 3 days, then renews automatically every year. Cancel anytime on Google Play'**
  String get annualFreeTrialRenews;

  /// No description provided for @threeDayFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'3-day Free Trial'**
  String get threeDayFreeTrial;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get startFreeTrial;

  /// No description provided for @aiProteinGeneration.
  ///
  /// In en, this message translates to:
  /// **'AI Fiber Generation'**
  String get aiProteinGeneration;

  /// No description provided for @unlimitedAIPoweredProteinCalculationsFromFoodDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI-powered fiber calculations from food descriptions'**
  String get unlimitedAIPoweredProteinCalculationsFromFoodDescriptions;

  /// No description provided for @unlockAiPoweredProteinTracking.
  ///
  /// In en, this message translates to:
  /// **'Unlock AI-powered fiber tracking! Upgrade to premium for unlimited AI generation.'**
  String get unlockAiPoweredProteinTracking;

  /// No description provided for @weeklyRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically every week. Cancel anytime on Google Play'**
  String get weeklyRenews;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bn',
        'de',
        'en',
        'es',
        'fr',
        'gu',
        'hi',
        'id',
        'it',
        'ja',
        'kn',
        'ko',
        'ml',
        'mr',
        'ms',
        'nl',
        'pa',
        'pl',
        'pt',
        'ru',
        'ta',
        'te',
        'th',
        'tr',
        'ur',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'nl':
      return AppLocalizationsNl();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
