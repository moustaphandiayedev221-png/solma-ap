import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SOLMA'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to SOLMA'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get passwordMinLength;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join SOLMA for the best shoe experience'**
  String get joinSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get fullNameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get nameRequired;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @bestSale.
  ///
  /// In en, this message translates to:
  /// **'Best Sale'**
  String get bestSale;

  /// No description provided for @bestChoice.
  ///
  /// In en, this message translates to:
  /// **'Best Choice'**
  String get bestChoice;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @upTo.
  ///
  /// In en, this message translates to:
  /// **'Up to '**
  String get upTo;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get categoryMen;

  /// No description provided for @categoryWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get categoryWomen;

  /// No description provided for @categoryKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get categoryKids;

  /// No description provided for @sectionPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sectionPopular;

  /// No description provided for @sectionNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'Advertising'**
  String get sectionNewArrivals;

  /// No description provided for @sectionNew.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get sectionNew;

  /// No description provided for @sectionTenuesAfricaines.
  ///
  /// In en, this message translates to:
  /// **'African Outfits'**
  String get sectionTenuesAfricaines;

  /// No description provided for @sectionSacsAMain.
  ///
  /// In en, this message translates to:
  /// **'Handbags'**
  String get sectionSacsAMain;

  /// No description provided for @sectionSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sectionSports;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @loadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading products…'**
  String get loadingProducts;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Load error.'**
  String get loadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network.'**
  String get errorConnection;

  /// No description provided for @noConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnectionTitle;

  /// No description provided for @noConnectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure Wi‑Fi or mobile data is turned on, then try again.'**
  String get noConnectionSubtitle;

  /// No description provided for @noConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get noConnectionRetry;

  /// No description provided for @connectionErrorToast.
  ///
  /// In en, this message translates to:
  /// **'Internet connection error'**
  String get connectionErrorToast;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More Details'**
  String get moreDetails;

  /// No description provided for @totalShipping.
  ///
  /// In en, this message translates to:
  /// **'Total Shipping'**
  String get totalShipping;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get point;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your password, data, and privacy preferences.'**
  String get privacySecuritySubtitle;

  /// No description provided for @privacySecuritySectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get privacySecuritySectionAccount;

  /// No description provided for @privacySecurityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get privacySecurityChangePassword;

  /// No description provided for @privacySecurityChangePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your password regularly for better security'**
  String get privacySecurityChangePasswordDesc;

  /// No description provided for @privacySecurityNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get privacySecurityNewPassword;

  /// No description provided for @privacySecurityPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get privacySecurityPasswordUpdated;

  /// No description provided for @privacySecuritySectionData.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get privacySecuritySectionData;

  /// No description provided for @privacySecurityPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'See how we collect and use your data'**
  String get privacySecurityPolicyDesc;

  /// No description provided for @privacySecuritySectionDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get privacySecuritySectionDanger;

  /// No description provided for @privacySecurityDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get privacySecurityDeleteAccount;

  /// No description provided for @privacySecurityDeleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all your data'**
  String get privacySecurityDeleteAccountDesc;

  /// No description provided for @privacySecurityDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your data will be permanently deleted. Are you sure you want to continue?'**
  String get privacySecurityDeleteAccountConfirm;

  /// No description provided for @privacySecurityDeleteAccountContact.
  ///
  /// In en, this message translates to:
  /// **'To delete your account, please contact support@solma.com'**
  String get privacySecurityDeleteAccountContact;

  /// No description provided for @notificationPreference.
  ///
  /// In en, this message translates to:
  /// **'Notification Preference'**
  String get notificationPreference;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get selectLanguage;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get locationNotSet;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get promoCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @promoCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Code applied'**
  String get promoCodeApplied;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidPromoCode;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @paySecurely.
  ///
  /// In en, this message translates to:
  /// **'Pay Securely'**
  String get paySecurely;

  /// No description provided for @orderRecapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderRecapSubtitle;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @sportShoes.
  ///
  /// In en, this message translates to:
  /// **'Sport Shoes'**
  String get sportShoes;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select Size'**
  String get selectSize;

  /// No description provided for @pleaseSelectSize.
  ///
  /// In en, this message translates to:
  /// **'Please select a size'**
  String get pleaseSelectSize;

  /// No description provided for @pleaseSelectColour.
  ///
  /// In en, this message translates to:
  /// **'Please select a colour'**
  String get pleaseSelectColour;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @productInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get productInformation;

  /// No description provided for @colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity:'**
  String get quantityLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @descriptions.
  ///
  /// In en, this message translates to:
  /// **'Descriptions'**
  String get descriptions;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size {value}'**
  String sizeLabel(String value);

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Time Journey With Premium Shoes'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Every smart choice will highlight your style anywhere.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Discover Your Perfect Fit'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Browse Men, Women and Kids collections with ease.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Secure Checkout & Fast Delivery'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Pay safely with Stripe and get your order delivered quickly.'**
  String get onboardingSubtitle3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistoryTitle;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrders;

  /// No description provided for @noOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your past orders will appear here'**
  String get noOrdersSubtitle;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumber(String number);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {uri}'**
  String pageNotFound(String uri);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @noAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get noAddresses;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods'**
  String get noPaymentMethods;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCard;

  /// No description provided for @paymentOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Payment on delivery'**
  String get paymentOnDelivery;

  /// No description provided for @paymentOnDeliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Pay in cash or by card when you receive your order.'**
  String get paymentOnDeliveryDescription;

  /// No description provided for @paymentMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get paymentMobileMoney;

  /// No description provided for @paymentMobileMoneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Orange Money, MTN Money, Wave… Pay from your mobile wallet.'**
  String get paymentMobileMoneyDescription;

  /// No description provided for @paymentByCard.
  ///
  /// In en, this message translates to:
  /// **'Credit / debit card'**
  String get paymentByCard;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @ordersAndReminders.
  ///
  /// In en, this message translates to:
  /// **'Orders and reminders'**
  String get ordersAndReminders;

  /// No description provided for @offersAndPromos.
  ///
  /// In en, this message translates to:
  /// **'Offers and promos'**
  String get offersAndPromos;

  /// No description provided for @discountsAndNew.
  ///
  /// In en, this message translates to:
  /// **'Discounts and ads'**
  String get discountsAndNew;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get orderPlacedSuccess;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g. Home, Office)'**
  String get addressLabel;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name required'**
  String get fullNameRequired;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address line 1'**
  String get addressLine1;

  /// No description provided for @addressLine1Required.
  ///
  /// In en, this message translates to:
  /// **'Address required'**
  String get addressLine1Required;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address line 2 (optional)'**
  String get addressLine2;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City required'**
  String get cityRequired;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @regionOptional.
  ///
  /// In en, this message translates to:
  /// **'Region (for shipping calculation)'**
  String get regionOptional;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country required'**
  String get countryRequired;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddress;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this address?'**
  String get deleteAddressConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get addressSaved;

  /// No description provided for @addressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted'**
  String get addressDeleted;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsYesterday;

  /// No description provided for @notificationsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get notificationsThisWeek;

  /// No description provided for @notificationsOlder.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get notificationsOlder;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see orders, promos and updates here.'**
  String get noNotificationsSubtitle;

  /// No description provided for @signInToSeeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your notifications.'**
  String get signInToSeeNotifications;

  /// No description provided for @notificationsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsTabAll;

  /// No description provided for @notificationsTabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get notificationsTabOrders;

  /// No description provided for @notificationsTabPromo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get notificationsTabPromo;

  /// No description provided for @notificationsTabSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationsTabSystem;

  /// No description provided for @noNotificationsFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search criteria'**
  String get noNotificationsFilterSubtitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @bannerNewCollection.
  ///
  /// In en, this message translates to:
  /// **'New Collection'**
  String get bannerNewCollection;

  /// No description provided for @bannerNewCollectionSub.
  ///
  /// In en, this message translates to:
  /// **'Spring 2026'**
  String get bannerNewCollectionSub;

  /// No description provided for @bannerExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get bannerExplore;

  /// No description provided for @bannerFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping'**
  String get bannerFreeShipping;

  /// No description provided for @bannerFreeShippingSub.
  ///
  /// In en, this message translates to:
  /// **'On all orders'**
  String get bannerFreeShippingSub;

  /// No description provided for @bannerOver.
  ///
  /// In en, this message translates to:
  /// **'Over '**
  String get bannerOver;

  /// No description provided for @bannerOrderNow.
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get bannerOrderNow;

  /// No description provided for @bannerExclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get bannerExclusive;

  /// No description provided for @bannerExclusiveSub.
  ///
  /// In en, this message translates to:
  /// **'Limited Edition'**
  String get bannerExclusiveSub;

  /// No description provided for @bannerOnlyOn.
  ///
  /// In en, this message translates to:
  /// **'Only on '**
  String get bannerOnlyOn;

  /// No description provided for @bannerDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get bannerDiscover;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add favorites from product pages.'**
  String get wishlistEmptySubtitle;

  /// No description provided for @removeFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from wishlist'**
  String get removeFromWishlist;

  /// No description provided for @addAllToCart.
  ///
  /// In en, this message translates to:
  /// **'Add all to cart'**
  String get addAllToCart;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+33 6 12 34 56 78'**
  String get phoneNumberHint;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dateOfBirthHint;

  /// No description provided for @addressAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Address & Location'**
  String get addressAndLocation;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get cardholderName;

  /// No description provided for @cardholderNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get cardholderNameHint;

  /// No description provided for @cardholderNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name required'**
  String get cardholderNameRequired;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @cardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'1234 5678 9012 3456'**
  String get cardNumberHint;

  /// No description provided for @cardNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Card number required'**
  String get cardNumberRequired;

  /// No description provided for @cardNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid card number'**
  String get cardNumberInvalid;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @expiryDateHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryDateHint;

  /// No description provided for @expiryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date required'**
  String get expiryDateRequired;

  /// No description provided for @expiryDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid expiry date'**
  String get expiryDateInvalid;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cvvHint.
  ///
  /// In en, this message translates to:
  /// **'123'**
  String get cvvHint;

  /// No description provided for @cvvRequired.
  ///
  /// In en, this message translates to:
  /// **'CVV required'**
  String get cvvRequired;

  /// No description provided for @cvvInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid CVV'**
  String get cvvInvalid;

  /// No description provided for @cardSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved'**
  String get cardSaved;

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailTitle;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get orderStatusPaid;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderReceiptThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your order'**
  String get orderReceiptThankYou;

  /// No description provided for @checkoutRecapFooter.
  ///
  /// In en, this message translates to:
  /// **'Pay in the app or order via WhatsApp.'**
  String get checkoutRecapFooter;

  /// No description provided for @orderViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Order via WhatsApp'**
  String get orderViaWhatsApp;

  /// No description provided for @orderReceiptSeeDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get orderReceiptSeeDetails;

  /// No description provided for @shippingAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddressLabel;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderItems;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qty: {count}'**
  String quantity(int count);

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size: {value}'**
  String size(String value);

  /// No description provided for @noShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'No shipping address'**
  String get noShippingAddress;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteCard;

  /// No description provided for @deleteCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this card?'**
  String get deleteCardConfirm;

  /// No description provided for @connectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign in cancelled'**
  String get connectionCancelled;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get resetPasswordSent;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get termsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andText.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andText;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @faqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find quick answers to the most frequently asked questions.'**
  String get faqSubtitle;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I track my order?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Once your order is shipped, you will receive an email with a tracking link. You can also check order history in your profile.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'What are the delivery times?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Standard delivery takes 3 to 5 business days. Express delivery (when available) is delivered within 24 to 48 hours.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I make a return?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Items can be returned within 14 days in their original condition. Contact our support for a return label.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'What payment methods do you accept?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'We accept credit cards (Visa, Mastercard), cash on delivery, and Mobile Money depending on availability.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I change my delivery address?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Addresses to add or edit your addresses. You can choose the address at checkout.'**
  String get faqA5;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help. Choose an option below.'**
  String get helpCenterSubtitle;

  /// No description provided for @helpCenterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for answers…'**
  String get helpCenterSearchHint;

  /// No description provided for @helpCenterFaqDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse answers to frequently asked questions'**
  String get helpCenterFaqDesc;

  /// No description provided for @helpCenterContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get helpCenterContactTitle;

  /// No description provided for @helpCenterCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get helpCenterCallTitle;

  /// No description provided for @helpCenterCallDesc.
  ///
  /// In en, this message translates to:
  /// **'Speak with our support team'**
  String get helpCenterCallDesc;

  /// No description provided for @helpCenterWhatsAppTitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get helpCenterWhatsAppTitle;

  /// No description provided for @helpCenterWhatsAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with us on WhatsApp'**
  String get helpCenterWhatsAppDesc;

  /// No description provided for @helpCenterChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat assistant'**
  String get helpCenterChatTitle;

  /// No description provided for @helpCenterChatDesc.
  ///
  /// In en, this message translates to:
  /// **'24/7 virtual assistant for your questions'**
  String get helpCenterChatDesc;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m the SOLMA assistant. Ask me anything about delivery, returns, payment, or your account. How can I help you?'**
  String get chatWelcome;

  /// No description provided for @chatFallback.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t quite understand. Try asking about delivery times, returns, payment methods, or how to change your address. You can also call us or use WhatsApp for immediate assistance!'**
  String get chatFallback;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type your question…'**
  String get chatPlaceholder;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @helpCenterHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Support hours'**
  String get helpCenterHoursTitle;

  /// No description provided for @helpCenterHours.
  ///
  /// In en, this message translates to:
  /// **'Support available 24/7. We\'re here for you at any time.'**
  String get helpCenterHours;

  /// No description provided for @privacyPolicyLastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 2026'**
  String get privacyPolicyLastUpdate;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'SOLMA is committed to protecting your privacy. This policy explains how we collect, use, and protect your personal data.'**
  String get privacyIntro;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Data we collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Content.
  ///
  /// In en, this message translates to:
  /// **'We collect data you provide directly: account credentials, name, email address, phone number, date of birth (optional), profile photo (optional); delivery addresses (name, postal address, city, postal code, country, phone); order data (items, amounts, status). If you use Google or Apple sign-in, we receive the associated name and email. For push notifications, we store a technical identifier (FCM token). The app stores your preferences (theme, language, currency) locally on your device.'**
  String get privacySection1Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Purposes of processing'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to: create and manage your account; process orders and payments; manage delivery addresses; send you notifications (order confirmation, delivery, promotions if you have consented); personalize the app (currency, language); ensure security and prevent fraud. We never sell your data to third parties.'**
  String get privacySection2Content;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Service providers and partners'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Content.
  ///
  /// In en, this message translates to:
  /// **'We rely on trusted technical providers: Supabase (hosting, database, authentication); Stripe (secure payments, PCI-DSS compliant); Firebase/Google (push notifications); Google and Apple (social sign-in, if you use it); Exchange Rate API (exchange rates for price display). These providers process your data in accordance with our instructions and legal requirements.'**
  String get privacySection3Content;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data retention'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Content.
  ///
  /// In en, this message translates to:
  /// **'Account and profile data is retained for as long as your account is active. Order data is retained for legal and accounting obligations (typically 5 to 10 years depending on regulations). Notification tokens are deleted upon logout. You may request account deletion at any time.'**
  String get privacySection4Content;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your rights (GDPR)'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Content.
  ///
  /// In en, this message translates to:
  /// **'Under the General Data Protection Regulation (GDPR), you have the right to: access your data; rectify inaccurate data; erasure (« right to be forgotten »); restrict processing; data portability; object to processing; withdraw consent. To exercise these rights, contact us at support@solma.com. You may also lodge a complaint with your country\'s supervisory authority.'**
  String get privacySection5Content;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Security'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Content.
  ///
  /// In en, this message translates to:
  /// **'We implement appropriate technical and organizational measures: HTTPS encryption for all communications; secure authentication; payments delegated to Stripe (PCI-DSS); storage of sensitive data on secure infrastructure. No credit card numbers are stored on our servers.'**
  String get privacySection6Content;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Local storage and preferences'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Content.
  ///
  /// In en, this message translates to:
  /// **'The app uses your device\'s local storage for preferences (light/dark theme, language, currency), cart, and wishlist. This data remains on your device and is not shared with third parties, except for account sync when you are signed in. Exchange rates are cached locally to improve performance.'**
  String get privacySection7Content;

  /// No description provided for @privacySection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Changes and contact'**
  String get privacySection8Title;

  /// No description provided for @privacySection8Content.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy to reflect changes in our practices or regulations. The last update date is shown at the top. For any questions regarding your personal data, contact us: support@solma.com or via the app\'s Help Center.'**
  String get privacySection8Content;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get sessionExpired;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get reconnect;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(int count);

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @beFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this product'**
  String get beFirstToReview;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit my review'**
  String get editReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your comment (optional)'**
  String get yourComment;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitReview;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmitted;

  /// No description provided for @reviewUpdated.
  ///
  /// In en, this message translates to:
  /// **'Review updated'**
  String get reviewUpdated;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted'**
  String get reviewDeleted;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete review'**
  String get deleteReview;

  /// No description provided for @deleteReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this review?'**
  String get deleteReviewConfirm;

  /// No description provided for @loginToReview.
  ///
  /// In en, this message translates to:
  /// **'Sign in to leave a review'**
  String get loginToReview;

  /// No description provided for @verifiedPurchase.
  ///
  /// In en, this message translates to:
  /// **'Verified purchase'**
  String get verifiedPurchase;

  /// No description provided for @helpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get helpful;

  /// No description provided for @notHelpful.
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get notHelpful;

  /// No description provided for @peopleFoundHelpful.
  ///
  /// In en, this message translates to:
  /// **'{count} people found this review helpful'**
  String peopleFoundHelpful(int count);

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get sortRecent;

  /// No description provided for @sortHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest rating'**
  String get sortHighest;

  /// No description provided for @sortLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest rating'**
  String get sortLowest;

  /// No description provided for @sortHelpful.
  ///
  /// In en, this message translates to:
  /// **'Most helpful'**
  String get sortHelpful;

  /// No description provided for @seeAllReviews.
  ///
  /// In en, this message translates to:
  /// **'See all reviews'**
  String get seeAllReviews;

  /// No description provided for @seeMoreReviews.
  ///
  /// In en, this message translates to:
  /// **'See more ({count} remaining)'**
  String seeMoreReviews(int count);

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review title'**
  String get reviewTitle;

  /// No description provided for @reviewTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Summarize your experience in a few words'**
  String get reviewTitleHint;

  /// No description provided for @pros.
  ///
  /// In en, this message translates to:
  /// **'Pros'**
  String get pros;

  /// No description provided for @prosHint.
  ///
  /// In en, this message translates to:
  /// **'What you liked...'**
  String get prosHint;

  /// No description provided for @cons.
  ///
  /// In en, this message translates to:
  /// **'Cons'**
  String get cons;

  /// No description provided for @consHint.
  ///
  /// In en, this message translates to:
  /// **'What could be improved...'**
  String get consHint;

  /// No description provided for @starExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get starExcellent;

  /// No description provided for @starGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get starGood;

  /// No description provided for @starAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get starAverage;

  /// No description provided for @starPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get starPoor;

  /// No description provided for @starBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get starBad;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @promoCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter a promo code'**
  String get promoCodePlaceholder;

  /// No description provided for @promoApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied: -{amount}'**
  String promoApplied(String amount);

  /// No description provided for @promoMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum order amount not reached'**
  String get promoMinOrder;

  /// No description provided for @promoExpired.
  ///
  /// In en, this message translates to:
  /// **'This promo code has expired'**
  String get promoExpired;

  /// No description provided for @promoMaxUsed.
  ///
  /// In en, this message translates to:
  /// **'This promo code is no longer available'**
  String get promoMaxUsed;

  /// No description provided for @promoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Promo code not found'**
  String get promoNotFound;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountLabel;

  /// No description provided for @removePromo.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePromo;

  /// No description provided for @orderTracking.
  ///
  /// In en, this message translates to:
  /// **'Order Tracking'**
  String get orderTracking;

  /// No description provided for @trackingOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get trackingOrdered;

  /// No description provided for @trackingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get trackingConfirmed;

  /// No description provided for @trackingPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get trackingPreparing;

  /// No description provided for @trackingShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get trackingShipped;

  /// No description provided for @trackingInDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get trackingInDelivery;

  /// No description provided for @trackingDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get trackingDelivered;

  /// No description provided for @noTrackingInfo.
  ///
  /// In en, this message translates to:
  /// **'No tracking information available'**
  String get noTrackingInfo;

  /// No description provided for @whyChooseSOLMA.
  ///
  /// In en, this message translates to:
  /// **'Why choose SOLMA?'**
  String get whyChooseSOLMA;

  /// No description provided for @dataProtection.
  ///
  /// In en, this message translates to:
  /// **'Data protection'**
  String get dataProtection;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure payment'**
  String get securePayment;

  /// No description provided for @deliveryWorldwide.
  ///
  /// In en, this message translates to:
  /// **'Delivery worldwide'**
  String get deliveryWorldwide;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Nike, Jordan…'**
  String get searchHint;

  /// No description provided for @noNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get noNewArrivals;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'Advertising'**
  String get newArrivals;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currentCurrency.
  ///
  /// In en, this message translates to:
  /// **'Current currency'**
  String get currentCurrency;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose a currency'**
  String get chooseCurrency;

  /// No description provided for @currencyInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get currencyInfoTitle;

  /// No description provided for @currencyInfoBody.
  ///
  /// In en, this message translates to:
  /// **'The selected currency will be used to display all prices in the app. Conversion rates will be applied automatically.'**
  String get currencyInfoBody;

  /// No description provided for @currencyInfoNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Conversions are based on real-time exchange rates.'**
  String get currencyInfoNote;

  /// No description provided for @currencyXof.
  ///
  /// In en, this message translates to:
  /// **'West African CFA franc'**
  String get currencyXof;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUsd;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEur;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'SOLMA Notifications'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'SOLMA app notifications'**
  String get notificationChannelDesc;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get orderConfirmed;

  /// No description provided for @orderConfirmedBodyMultiple.
  ///
  /// In en, this message translates to:
  /// **'Your order #{shortId} has been recorded. {count} items, total {total}.'**
  String orderConfirmedBodyMultiple(String shortId, int count, String total);

  /// No description provided for @orderConfirmedBodySingle.
  ///
  /// In en, this message translates to:
  /// **'Your order #{shortId} has been recorded. Total {total}.'**
  String orderConfirmedBodySingle(String shortId, String total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
