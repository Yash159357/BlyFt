import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Blyft'**
  String get appTitle;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes answer
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No answer
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Unknown status
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Never status
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Search functionality
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Bookmarks screen title
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Sign in action
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up action
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Create account title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Login redirect text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Don't have account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Theme selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme Color'**
  String get selectTheme;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Edit profile action
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Profile update description
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updatePersonalInfo;

  /// Delete account action
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Password confirmation prompt
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get enterPasswordToConfirm;

  /// Reminder time setting
  ///
  /// In en, this message translates to:
  /// **'Set Reminder Time'**
  String get setReminderTime;

  /// Hour label
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// Minute label
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// Notification permission required message
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required for reminders'**
  String get notificationPermissionRequired;

  /// Daily reminders disabled message
  ///
  /// In en, this message translates to:
  /// **'Daily reminders disabled'**
  String get dailyRemindersDisabled;

  /// User label
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Contact label
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// Chinese language option
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// Russian language option
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// Hindi language option
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// Profile settings screen title
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Email address field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Email verification status
  ///
  /// In en, this message translates to:
  /// **'Email Verified'**
  String get emailVerified;

  /// Account creation date label
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreated;

  /// Last update date label
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Gallery photo option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Remove photo option
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Profile photo removal success message
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed successfully'**
  String get profilePhotoRemovedSuccessfully;

  /// No changes detected message
  ///
  /// In en, this message translates to:
  /// **'No changes to save'**
  String get noChangesToSave;

  /// Name validation error message
  ///
  /// In en, this message translates to:
  /// **'Name cannot be blank'**
  String get nameCannotBeBlank;

  /// Image picker error message
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

  /// Camera error message
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo'**
  String get failedToTakePhoto;

  /// Photo removal error message
  ///
  /// In en, this message translates to:
  /// **'Error removing photo'**
  String get errorRemovingPhoto;

  /// Retry search action
  ///
  /// In en, this message translates to:
  /// **'Retry Search'**
  String get retrySearch;

  /// Search query prompt
  ///
  /// In en, this message translates to:
  /// **'Please enter a search query'**
  String get pleaseEnterSearchQuery;

  /// Read article action
  ///
  /// In en, this message translates to:
  /// **'Read Article'**
  String get readArticle;

  /// Contact us title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Get in touch subtitle
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get getInTouch;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// Message copy success notification
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopiedToClipboard;

  /// Image cropper error message
  ///
  /// In en, this message translates to:
  /// **'Failed to open image cropper.'**
  String get failedToOpenImageCropper;

  /// Tutorial message for swipe up gesture
  ///
  /// In en, this message translates to:
  /// **'Swipe Up for More News'**
  String get swipeUpForMoreNews;

  /// Swipe right instruction
  ///
  /// In en, this message translates to:
  /// **'Swipe right to bookmark'**
  String get swipeRightToBookmark;

  /// AI chat feature description
  ///
  /// In en, this message translates to:
  /// **'Chat with AI assistant'**
  String get chatWithAI;

  /// Text-to-speech instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to hear the news'**
  String get tapToHearNews;

  /// Like article action
  ///
  /// In en, this message translates to:
  /// **'Like this article'**
  String get likeThisArticle;

  /// Dislike article action
  ///
  /// In en, this message translates to:
  /// **'Dislike this article'**
  String get dislikeThisArticle;

  /// Read headline action
  ///
  /// In en, this message translates to:
  /// **'Read the headline'**
  String get readHeadline;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Daily bookmark reminder setting
  ///
  /// In en, this message translates to:
  /// **'Daily Bookmark Reminder'**
  String get dailyBookmarkReminder;

  /// Reminder time setting
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// Share app action
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// Share app subtitle
  ///
  /// In en, this message translates to:
  /// **'Tell your friends about us'**
  String get tellYourFriends;

  /// Rate app action
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// Rate app subtitle
  ///
  /// In en, this message translates to:
  /// **'Leave feedback on the store'**
  String get leaveFeedback;

  /// About us section
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// About us subtitle
  ///
  /// In en, this message translates to:
  /// **'Learn more about us'**
  String get learnMoreAboutUs;

  /// Log out action
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Log out subtitle
  ///
  /// In en, this message translates to:
  /// **'See you again soon'**
  String get seeYouAgainSoon;

  /// App theme setting
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// Theme setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Change app accent color'**
  String get changeAppAccentColor;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Intro screen welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nBrevity'**
  String get welcomeToBrevity;

  /// Intro screen welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'Your Smart News Companion'**
  String get yourSmartNewsCompanion;

  /// Intro screen personalization title
  ///
  /// In en, this message translates to:
  /// **'A Feed\nJust For You'**
  String get aFeedJustForYou;

  /// Intro screen personalization subtitle
  ///
  /// In en, this message translates to:
  /// **'Tailored to Your Tastes'**
  String get tailoredToYourTastes;

  /// Intro screen AI title
  ///
  /// In en, this message translates to:
  /// **'AI-Powered\nInsights'**
  String get aiPoweredInsights;

  /// Intro screen AI subtitle
  ///
  /// In en, this message translates to:
  /// **'Go Beyond the Headlines'**
  String get goBeyondHeadlines;

  /// Intro screen customization title
  ///
  /// In en, this message translates to:
  /// **'Personalize\nYour Experience'**
  String get personalizeYourExperience;

  /// Intro screen customization subtitle
  ///
  /// In en, this message translates to:
  /// **'Themes & Customization'**
  String get themesAndCustomization;

  /// Search field hint text
  ///
  /// In en, this message translates to:
  /// **'Search news topics...'**
  String get searchNewsTopics;

  /// Warning shown before deleting account
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get deleteAccountWarning;

  /// Message shown when reminder is set
  ///
  /// In en, this message translates to:
  /// **'Daily reminders enabled for {time}'**
  String reminderTimeSet(Object time);

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Top news section title
  ///
  /// In en, this message translates to:
  /// **'Top News'**
  String get topNews;

  /// Error when top news cannot be fetched
  ///
  /// In en, this message translates to:
  /// **'Failed to load top news'**
  String get failedToLoadTopNews;

  /// Topics section title
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// My feed label
  ///
  /// In en, this message translates to:
  /// **'My Feed'**
  String get myFeed;

  /// Top stories label
  ///
  /// In en, this message translates to:
  /// **'Top Stories'**
  String get topStories;

  /// Placeholder shown while news loads
  ///
  /// In en, this message translates to:
  /// **'Loading news...'**
  String get loadingNews;

  /// Placeholder for missing news description
  ///
  /// In en, this message translates to:
  /// **'News description text will come here...'**
  String get newsDescriptionPlaceholder;

  /// Message shown when no articles are available
  ///
  /// In en, this message translates to:
  /// **'No articles found.'**
  String get noArticlesFound;

  /// General category
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Technology category
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// Politics category
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get politics;

  /// Sports category
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// Entertainment category
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// Health category
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Business category
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// Customize theme button text
  ///
  /// In en, this message translates to:
  /// **'Customize Theme'**
  String get customizeTheme;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// Mode section title
  ///
  /// In en, this message translates to:
  /// **'MODE'**
  String get mode;

  /// Light mode option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Preview section title
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Sample article title
  ///
  /// In en, this message translates to:
  /// **'Sample News Article'**
  String get sampleNewsArticle;

  /// Preview card subtitle
  ///
  /// In en, this message translates to:
  /// **'This is how your news cards will look'**
  String get sampleNewsArticleSubtitle;

  /// Delete account subtitle
  ///
  /// In en, this message translates to:
  /// **'Permanently erase your data'**
  String get permanentlyEraseData;

  /// Tutorial label
  ///
  /// In en, this message translates to:
  /// **'Tap headline to bookmark news'**
  String get tapHeadlineToBookmark;

  /// Tutorial label
  ///
  /// In en, this message translates to:
  /// **'Tap this icon to open full article'**
  String get tapThisIconToOpenFullArticle;

  /// Tutorial label
  ///
  /// In en, this message translates to:
  /// **'Tap AI button to chat with assistant'**
  String get tapAIButtonToChat;

  /// Tutorial continuation hint
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to continue'**
  String get tapAnywhereToContinue;

  /// Step indicator with total steps
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total} • Tap anywhere to continue'**
  String stepStatus(Object current, Object total);

  /// Create account subtitle
  ///
  /// In en, this message translates to:
  /// **'Join the Blyft community'**
  String get joinBrevityCommunity;

  /// Full name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// Name validation message
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// Email validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createStrongPassword;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccountButton;

  /// OAuth separator text
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// Google OAuth button text
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// Apple OAuth button text
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Crop picture dialog title
  ///
  /// In en, this message translates to:
  /// **'Crop Profile Picture'**
  String get cropProfilePicture;

  /// Weak password strength
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// Medium password strength
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Strong password strength
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Blyft account'**
  String get signInToAccount;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// Create account link text
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount2;

  /// Theme selection description
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme and mode'**
  String get chooseThemeAndMode;

  /// Theme color section title
  ///
  /// In en, this message translates to:
  /// **'THEME COLOR'**
  String get themeColor;

  /// News card preview description
  ///
  /// In en, this message translates to:
  /// **'This is how your news cards will look'**
  String get newsCardPreview;

  /// Dismiss button
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get dismiss;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// Search again button
  ///
  /// In en, this message translates to:
  /// **'Search Again'**
  String get searchAgain;

  /// Bookmark tooltip
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// Remove bookmark tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Reset password title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset password subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive reset instructions'**
  String get enterEmailForReset;

  /// OTP field label
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// OTP validation message
  ///
  /// In en, this message translates to:
  /// **'OTP is required'**
  String get otpIsRequired;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Resend button
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// New password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// New password validation
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordIsRequired;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// Confirm password validation
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Password match validation
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// OTP sent message
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your email'**
  String get otpSentToEmail;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Report content dialog title
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContent;

  /// Submit report button
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// Report reason option
  ///
  /// In en, this message translates to:
  /// **'Inaccurate Information'**
  String get inaccurateInformation;

  /// Report reason option
  ///
  /// In en, this message translates to:
  /// **'Offensive Content'**
  String get offensiveContent;

  /// Report reason option
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get spam;

  /// Other option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// AI assistant name
  ///
  /// In en, this message translates to:
  /// **'NewsAI Assistant'**
  String get newsAiAssistant;

  /// AI powered by text
  ///
  /// In en, this message translates to:
  /// **'Powered by Gemini'**
  String get poweredByGemini;

  /// Article context label
  ///
  /// In en, this message translates to:
  /// **'Article Context'**
  String get articleContext;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Report option
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// About Unity title
  ///
  /// In en, this message translates to:
  /// **'About Unity'**
  String get aboutUnity;

  /// Unity News subtitle
  ///
  /// In en, this message translates to:
  /// **'Unity News'**
  String get unityNews;

  /// AI Chat Assistant feature title
  ///
  /// In en, this message translates to:
  /// **'AI Chat Assistant'**
  String get aiChatAssistant;

  /// AI Chat Assistant description
  ///
  /// In en, this message translates to:
  /// **'Discuss articles with our intelligent chatbot'**
  String get discussArticlesChatbot;

  /// Curated Content feature title
  ///
  /// In en, this message translates to:
  /// **'Curated Content'**
  String get curatedContent;

  /// Curated Content description
  ///
  /// In en, this message translates to:
  /// **'News from reliable sources'**
  String get newsReliableSources;

  /// Real-time Updates feature title
  ///
  /// In en, this message translates to:
  /// **'Real-time Updates'**
  String get realtimeUpdates;

  /// Real-time Updates description
  ///
  /// In en, this message translates to:
  /// **'Stay updated with the latest news'**
  String get stayUpdatedLatestNews;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Developers section title
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get developers;

  /// Share app message
  ///
  /// In en, this message translates to:
  /// **'Hey! I\'m using this amazing app. You can try it too! 📲\n\nDownload here: https://play.google.com/store/apps/details?id=com.placeholder'**
  String get shareAppMessage;

  /// Daily reminders enabled message
  ///
  /// In en, this message translates to:
  /// **'Daily reminders enabled for {time}'**
  String dailyRemindersEnabled(String time);

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPasswordButton;

  /// Back to login link
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Email verification title
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// Email verification subtitle
  ///
  /// In en, this message translates to:
  /// **'Check your email to continue'**
  String get checkYourEmailToContinue;

  /// Alternative email verification subtitle
  ///
  /// In en, this message translates to:
  /// **'Activate your Blyft account'**
  String get activateYourBrevityAccount;

  /// Verification pending status
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPending;

  /// Check verification button
  ///
  /// In en, this message translates to:
  /// **'CHECK VERIFICATION'**
  String get checkVerification;

  /// Resend email button
  ///
  /// In en, this message translates to:
  /// **'RESEND EMAIL'**
  String get resendEmail;

  /// No bookmarks message
  ///
  /// In en, this message translates to:
  /// **'No Bookmarks Yet'**
  String get noBookmarksYet;

  /// Empty bookmarks description
  ///
  /// In en, this message translates to:
  /// **'Articles you save will appear here'**
  String get articlesSavedWillAppearHere;

  /// Discover news button
  ///
  /// In en, this message translates to:
  /// **'Discover News'**
  String get discoverNews;

  /// End of news message
  ///
  /// In en, this message translates to:
  /// **'New stories will appear here soon'**
  String get newStoriesWillAppearSoon;

  /// Explore sections button
  ///
  /// In en, this message translates to:
  /// **'Explore other sections'**
  String get exploreOtherSections;

  /// End of news primary message
  ///
  /// In en, this message translates to:
  /// **'You\'re done for the day'**
  String get youreDoneForTheDay;

  /// End of news secondary message
  ///
  /// In en, this message translates to:
  /// **'Take a well-deserved break'**
  String get takeAWellDeservedBreak;

  /// Error message when article fails to open
  ///
  /// In en, this message translates to:
  /// **'Failed to open article'**
  String get failedToOpenArticle;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String noResultsFoundFor(String query);

  /// Password validation error message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8Characters;

  /// Tutorial description for swipe up gesture
  ///
  /// In en, this message translates to:
  /// **'Swipe up to scroll through more news articles and stay updated.'**
  String get swipeUpToScrollThroughNews;

  /// Tutorial message for swipe right gesture
  ///
  /// In en, this message translates to:
  /// **'Swipe Right for Dashboard'**
  String get swipeRightForDashboard;

  /// Tutorial description for swipe right gesture
  ///
  /// In en, this message translates to:
  /// **'Swipe right to access categories, bookmarks, and settings.'**
  String get swipeRightToAccessCategories;

  /// Tutorial message for bookmark tap
  ///
  /// In en, this message translates to:
  /// **'Tap to Bookmark'**
  String get tapToBookmark;

  /// Tutorial description for bookmark tap
  ///
  /// In en, this message translates to:
  /// **'Tap on any news headline to bookmark it for later reading.'**
  String get tapOnHeadlineToBookmark;

  /// Tutorial message for like button
  ///
  /// In en, this message translates to:
  /// **'Like News Articles'**
  String get likeNewsArticles;

  /// Tutorial description for like button
  ///
  /// In en, this message translates to:
  /// **'Tap thumbs up to like articles and improve your personalized feed.'**
  String get tapThumbsUpToLike;

  /// Tutorial message for dislike button
  ///
  /// In en, this message translates to:
  /// **'Dislike News Articles'**
  String get dislikeNewsArticles;

  /// Tutorial description for dislike button
  ///
  /// In en, this message translates to:
  /// **'Tap thumbs down to dislike articles and see fewer similar stories.'**
  String get tapThumbsDownToDislike;

  /// Tutorial message for TTS speaker
  ///
  /// In en, this message translates to:
  /// **'Listen to News'**
  String get listenToNews;

  /// Tutorial description for TTS speaker
  ///
  /// In en, this message translates to:
  /// **'Tap the speaker icon to hear the news article read aloud.'**
  String get tapSpeakerToListenNews;

  /// Tutorial description for chatbot
  ///
  /// In en, this message translates to:
  /// **'Tap the chatbot to start a conversation about this news article.'**
  String get tapChatbotToStartConversation;

  /// Skip button text for tutorial
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// Preferences section header
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// App section header
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// Account section header
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Search results header prefix
  ///
  /// In en, this message translates to:
  /// **'Results for'**
  String get resultsFor;

  /// Message directing users to contact support
  ///
  /// In en, this message translates to:
  /// **'For support, feedback, or questions about the app, reach out to our development team'**
  String get supportContactMessage;

  /// Information about response time for support
  ///
  /// In en, this message translates to:
  /// **'We typically respond within 1-2 business days'**
  String get responseTimeMessage;

  /// Role title for co-developer
  ///
  /// In en, this message translates to:
  /// **'Co-Developer'**
  String get coDeveloper;

  /// Title for shared news screen
  ///
  /// In en, this message translates to:
  /// **'Shared News'**
  String get sharedNews;

  /// Error message for invalid server data
  ///
  /// In en, this message translates to:
  /// **'Invalid data received from server.'**
  String get invalidDataReceived;

  /// Error message when news article fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load news article.'**
  String get failedToLoadNewsArticle;

  /// Generic error message for loading article
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the article.'**
  String get errorLoadingArticle;

  /// Button text to retry an action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Message when news article is not available
  ///
  /// In en, this message translates to:
  /// **'News article not found'**
  String get newsArticleNotFound;

  /// Prefix for author name
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get byAuthor;

  /// Error message when article URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the article.'**
  String get couldNotOpenArticle;

  /// Button text to read the complete article
  ///
  /// In en, this message translates to:
  /// **'Read Full Article'**
  String get readFullArticle;

  /// Instruction text for report dialog
  ///
  /// In en, this message translates to:
  /// **'Please select the reason for reporting:'**
  String get selectReasonForReporting;

  /// Report option for bullying or harassment
  ///
  /// In en, this message translates to:
  /// **'Bullying/Harassment'**
  String get bullyingHarassment;

  /// Confirmation message after submitting a report
  ///
  /// In en, this message translates to:
  /// **'Thank you for your report. We will review this content.'**
  String get thankYouForReport;

  /// Initial state message encouraging user to start chatting
  ///
  /// In en, this message translates to:
  /// **'Start a conversation about the article!'**
  String get startConversationAboutArticle;

  /// Subtitle for initial chat state
  ///
  /// In en, this message translates to:
  /// **'Your chat history will appear here.'**
  String get chatHistoryWillAppearHere;

  /// Loading message when chat is initializing
  ///
  /// In en, this message translates to:
  /// **'Initializing chat...'**
  String get initializingChat;

  /// Typing indicator text for AI responses
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// Input field hint text for chat
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about this article...'**
  String get askAnythingAboutArticle;

  /// Validation message for custom report reason
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason (max 50 characters)'**
  String get pleaseEnterReason;

  /// Error message for exceeding character limit
  ///
  /// In en, this message translates to:
  /// **'Maximum allowed is 50 characters'**
  String get maxAllowed50Chars;

  /// Hint text for custom report reason field
  ///
  /// In en, this message translates to:
  /// **'Please specify (max 50 characters)'**
  String get pleaseSpecifyMax50;

  /// Error message when AI service fails to respond
  ///
  /// In en, this message translates to:
  /// **'Failed to get response'**
  String get failedToGetResponse;
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
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
