// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SOLMA';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to continue to SOLMA';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get emailRequired => 'Email required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password required';

  @override
  String get passwordMinLength => 'Min. 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinSubtitle => 'Join SOLMA for the best shoe experience';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'John Doe';

  @override
  String get nameRequired => 'Name required';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Profile';

  @override
  String get bestSale => 'Best Sale';

  @override
  String get bestChoice => 'Best Choice';

  @override
  String get discount => 'Discount';

  @override
  String get upTo => 'Up to ';

  @override
  String get shopNow => 'Shop Now';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryMen => 'Men';

  @override
  String get categoryWomen => 'Women';

  @override
  String get categoryKids => 'Kids';

  @override
  String get sectionPopular => 'Popular';

  @override
  String get sectionNewArrivals => 'Advertising';

  @override
  String get sectionNew => 'New arrivals';

  @override
  String get sectionTenuesAfricaines => 'African Outfits';

  @override
  String get sectionSacsAMain => 'Handbags';

  @override
  String get sectionSports => 'Sports';

  @override
  String get seeAll => 'See all';

  @override
  String get loadingProducts => 'Loading products…';

  @override
  String get loading => 'Loading…';

  @override
  String get loadError => 'Load error.';

  @override
  String get retry => 'Retry';

  @override
  String get errorConnection => 'No connection. Check your network.';

  @override
  String get noConnectionTitle => 'No connection';

  @override
  String get noConnectionSubtitle =>
      'Make sure Wi‑Fi or mobile data is turned on, then try again.';

  @override
  String get noConnectionRetry => 'Try again';

  @override
  String get connectionErrorToast => 'Internet connection error';

  @override
  String get errorTimeout => 'Connection timed out. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get noProducts => 'No products';

  @override
  String get profile => 'Profile';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get edit => 'Edit';

  @override
  String get statistics => 'Statistics';

  @override
  String get moreDetails => 'More Details';

  @override
  String get totalShipping => 'Total Shipping';

  @override
  String get rating => 'Rating';

  @override
  String get point => 'Point';

  @override
  String get review => 'Review';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacySecuritySubtitle =>
      'Manage your password, data, and privacy preferences.';

  @override
  String get privacySecuritySectionAccount => 'Account';

  @override
  String get privacySecurityChangePassword => 'Change password';

  @override
  String get privacySecurityChangePasswordDesc =>
      'Update your password regularly for better security';

  @override
  String get privacySecurityNewPassword => 'New password';

  @override
  String get privacySecurityPasswordUpdated => 'Password updated';

  @override
  String get privacySecuritySectionData => 'Data & privacy';

  @override
  String get privacySecurityPolicyDesc =>
      'See how we collect and use your data';

  @override
  String get privacySecuritySectionDanger => 'Danger zone';

  @override
  String get privacySecurityDeleteAccount => 'Delete account';

  @override
  String get privacySecurityDeleteAccountDesc =>
      'Permanently delete your account and all your data';

  @override
  String get privacySecurityDeleteAccountConfirm =>
      'This action is irreversible. All your data will be permanently deleted. Are you sure you want to continue?';

  @override
  String get privacySecurityDeleteAccountContact =>
      'To delete your account, please contact support@solma.com';

  @override
  String get notificationPreference => 'Notification Preference';

  @override
  String get faq => 'FAQ';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Choose language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get locationNotSet => 'Not set';

  @override
  String get orderHistory => 'Order History';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get addresses => 'Addresses';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get signOut => 'Sign Out';

  @override
  String get settings => 'Settings';

  @override
  String get myCart => 'My Cart';

  @override
  String get clear => 'Clear';

  @override
  String get promoCode => 'Promo code';

  @override
  String get apply => 'Apply';

  @override
  String get promoCodeApplied => 'Code applied';

  @override
  String get invalidPromoCode => 'Invalid code';

  @override
  String get total => 'Total';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get checkout => 'Checkout';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get payment => 'Payment';

  @override
  String get change => 'Change';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get tax => 'Tax';

  @override
  String get paySecurely => 'Pay Securely';

  @override
  String get orderRecapSubtitle => 'Order summary';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get sportShoes => 'Sport Shoes';

  @override
  String get selectSize => 'Select Size';

  @override
  String get pleaseSelectSize => 'Please select a size';

  @override
  String get pleaseSelectColour => 'Please select a colour';

  @override
  String get description => 'Description';

  @override
  String get productInformation => 'Information';

  @override
  String get colour => 'Colour';

  @override
  String get quantityLabel => 'Quantity:';

  @override
  String get priceLabel => 'Price';

  @override
  String get readMore => 'Read More';

  @override
  String get showLess => 'Show less';

  @override
  String get descriptions => 'Descriptions';

  @override
  String get specifications => 'Specifications';

  @override
  String get colors => 'Colors';

  @override
  String get stock => 'Stock';

  @override
  String get learnMore => 'Learn more';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get specialOffers => 'Special Offers';

  @override
  String sizeLabel(String value) {
    return 'Size $value';
  }

  @override
  String get onboardingTitle1 => 'Time Journey With Premium Shoes';

  @override
  String get onboardingSubtitle1 =>
      'Every smart choice will highlight your style anywhere.';

  @override
  String get onboardingTitle2 => 'Discover Your Perfect Fit';

  @override
  String get onboardingSubtitle2 =>
      'Browse Men, Women and Kids collections with ease.';

  @override
  String get onboardingTitle3 => 'Secure Checkout & Fast Delivery';

  @override
  String get onboardingSubtitle3 =>
      'Pay safely with Stripe and get your order delivered quickly.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get orderHistoryTitle => 'Order History';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get noOrdersSubtitle => 'Your past orders will appear here';

  @override
  String get delivered => 'Delivered';

  @override
  String orderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String pageNotFound(String uri) {
    return 'Page not found: $uri';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get about => 'About';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get noAddresses => 'No saved addresses';

  @override
  String get addAddress => 'Add address';

  @override
  String get noPaymentMethods => 'No payment methods';

  @override
  String get addCard => 'Add card';

  @override
  String get paymentOnDelivery => 'Payment on delivery';

  @override
  String get paymentOnDeliveryDescription =>
      'Pay in cash or by card when you receive your order.';

  @override
  String get paymentMobileMoney => 'Mobile Money';

  @override
  String get paymentMobileMoneyDescription =>
      'Orange Money, MTN Money, Wave… Pay from your mobile wallet.';

  @override
  String get paymentByCard => 'Credit / debit card';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get ordersAndReminders => 'Orders and reminders';

  @override
  String get offersAndPromos => 'Offers and promos';

  @override
  String get discountsAndNew => 'Discounts and ads';

  @override
  String get orderPlacedSuccess => 'Order placed successfully';

  @override
  String get addressLabel => 'Label (e.g. Home, Office)';

  @override
  String get fullNameRequired => 'Full name required';

  @override
  String get addressLine1 => 'Address line 1';

  @override
  String get addressLine1Required => 'Address required';

  @override
  String get addressLine2 => 'Address line 2 (optional)';

  @override
  String get city => 'City';

  @override
  String get cityRequired => 'City required';

  @override
  String get region => 'Region';

  @override
  String get regionOptional => 'Region (for shipping calculation)';

  @override
  String get postalCode => 'Postal code';

  @override
  String get country => 'Country';

  @override
  String get countryRequired => 'Country required';

  @override
  String get phone => 'Phone';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get saveAddress => 'Save';

  @override
  String get editAddress => 'Edit address';

  @override
  String get deleteAddress => 'Delete';

  @override
  String get deleteAddressConfirm => 'Delete this address?';

  @override
  String get cancel => 'Cancel';

  @override
  String get addressSaved => 'Address saved';

  @override
  String get addressDeleted => 'Address deleted';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsThisWeek => 'This week';

  @override
  String get notificationsOlder => 'Older';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle =>
      'You\'ll see orders, promos and updates here.';

  @override
  String get signInToSeeNotifications => 'Sign in to see your notifications.';

  @override
  String get notificationsTabAll => 'All';

  @override
  String get notificationsTabOrders => 'Orders';

  @override
  String get notificationsTabPromo => 'Promo';

  @override
  String get notificationsTabSystem => 'System';

  @override
  String get noNotificationsFilterSubtitle =>
      'Try changing your search criteria';

  @override
  String get close => 'Close';

  @override
  String get bannerNewCollection => 'New Collection';

  @override
  String get bannerNewCollectionSub => 'Spring 2026';

  @override
  String get bannerExplore => 'Explore';

  @override
  String get bannerFreeShipping => 'Free Shipping';

  @override
  String get bannerFreeShippingSub => 'On all orders';

  @override
  String get bannerOver => 'Over ';

  @override
  String get bannerOrderNow => 'Order Now';

  @override
  String get bannerExclusive => 'Exclusive';

  @override
  String get bannerExclusiveSub => 'Limited Edition';

  @override
  String get bannerOnlyOn => 'Only on ';

  @override
  String get bannerDiscover => 'Discover';

  @override
  String get wishlistEmptySubtitle => 'Add favorites from product pages.';

  @override
  String get removeFromWishlist => 'Remove from wishlist';

  @override
  String get addAllToCart => 'Add all to cart';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneNumberHint => '+33 6 12 34 56 78';

  @override
  String get emailAddress => 'Email address';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get dateOfBirthHint => 'DD/MM/YYYY';

  @override
  String get addressAndLocation => 'Address & Location';

  @override
  String get addLocation => 'Add Location';

  @override
  String get save => 'Save';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get cardholderName => 'Cardholder name';

  @override
  String get cardholderNameHint => 'John Doe';

  @override
  String get cardholderNameRequired => 'Cardholder name required';

  @override
  String get cardNumber => 'Card number';

  @override
  String get cardNumberHint => '1234 5678 9012 3456';

  @override
  String get cardNumberRequired => 'Card number required';

  @override
  String get cardNumberInvalid => 'Invalid card number';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get expiryDateHint => 'MM/YY';

  @override
  String get expiryDateRequired => 'Expiry date required';

  @override
  String get expiryDateInvalid => 'Invalid expiry date';

  @override
  String get cvv => 'CVV';

  @override
  String get cvvHint => '123';

  @override
  String get cvvRequired => 'CVV required';

  @override
  String get cvvInvalid => 'Invalid CVV';

  @override
  String get cardSaved => 'Card saved';

  @override
  String get orderDetailTitle => 'Order Details';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusPaid => 'Paid';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderReceiptThankYou => 'Thank you for your order';

  @override
  String get checkoutRecapFooter => 'Pay in the app or order via WhatsApp.';

  @override
  String get orderViaWhatsApp => 'Order via WhatsApp';

  @override
  String get orderReceiptSeeDetails => 'View details';

  @override
  String get shippingAddressLabel => 'Shipping Address';

  @override
  String get orderItems => 'Items';

  @override
  String quantity(int count) {
    return 'Qty: $count';
  }

  @override
  String size(String value) {
    return 'Size: $value';
  }

  @override
  String get noShippingAddress => 'No shipping address';

  @override
  String get deleteCard => 'Delete card';

  @override
  String get deleteCardConfirm => 'Remove this card?';

  @override
  String get connectionCancelled => 'Sign in cancelled';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordSent => 'Password reset email sent';

  @override
  String get termsPrefix => 'By continuing, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andText => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get faqSubtitle =>
      'Find quick answers to the most frequently asked questions.';

  @override
  String get faqQ1 => 'How do I track my order?';

  @override
  String get faqA1 =>
      'Once your order is shipped, you will receive an email with a tracking link. You can also check order history in your profile.';

  @override
  String get faqQ2 => 'What are the delivery times?';

  @override
  String get faqA2 =>
      'Standard delivery takes 3 to 5 business days. Express delivery (when available) is delivered within 24 to 48 hours.';

  @override
  String get faqQ3 => 'How do I make a return?';

  @override
  String get faqA3 =>
      'Items can be returned within 14 days in their original condition. Contact our support for a return label.';

  @override
  String get faqQ4 => 'What payment methods do you accept?';

  @override
  String get faqA4 =>
      'We accept credit cards (Visa, Mastercard), cash on delivery, and Mobile Money depending on availability.';

  @override
  String get faqQ5 => 'How do I change my delivery address?';

  @override
  String get faqA5 =>
      'Go to Profile > Addresses to add or edit your addresses. You can choose the address at checkout.';

  @override
  String get helpCenterSubtitle =>
      'We\'re here to help. Choose an option below.';

  @override
  String get helpCenterSearchHint => 'Search for answers…';

  @override
  String get helpCenterFaqDesc =>
      'Browse answers to frequently asked questions';

  @override
  String get helpCenterContactTitle => 'Contact support';

  @override
  String get helpCenterCallTitle => 'Call us';

  @override
  String get helpCenterCallDesc => 'Speak with our support team';

  @override
  String get helpCenterWhatsAppTitle => 'WhatsApp';

  @override
  String get helpCenterWhatsAppDesc => 'Chat with us on WhatsApp';

  @override
  String get helpCenterChatTitle => 'Chat assistant';

  @override
  String get helpCenterChatDesc => '24/7 virtual assistant for your questions';

  @override
  String get chatWelcome =>
      'Hi! I\'m the SOLMA assistant. Ask me anything about delivery, returns, payment, or your account. How can I help you?';

  @override
  String get chatFallback =>
      'I didn\'t quite understand. Try asking about delivery times, returns, payment methods, or how to change your address. You can also call us or use WhatsApp for immediate assistance!';

  @override
  String get chatPlaceholder => 'Type your question…';

  @override
  String get chatSend => 'Send';

  @override
  String get helpCenterHoursTitle => 'Support hours';

  @override
  String get helpCenterHours =>
      'Support available 24/7. We\'re here for you at any time.';

  @override
  String get privacyPolicyLastUpdate => 'Last updated: March 2026';

  @override
  String get privacyIntro =>
      'SOLMA is committed to protecting your privacy. This policy explains how we collect, use, and protect your personal data.';

  @override
  String get privacySection1Title => '1. Data we collect';

  @override
  String get privacySection1Content =>
      'We collect data you provide directly: account credentials, name, email address, phone number, date of birth (optional), profile photo (optional); delivery addresses (name, postal address, city, postal code, country, phone); order data (items, amounts, status). If you use Google or Apple sign-in, we receive the associated name and email. For push notifications, we store a technical identifier (FCM token). The app stores your preferences (theme, language, currency) locally on your device.';

  @override
  String get privacySection2Title => '2. Purposes of processing';

  @override
  String get privacySection2Content =>
      'Your data is used to: create and manage your account; process orders and payments; manage delivery addresses; send you notifications (order confirmation, delivery, promotions if you have consented); personalize the app (currency, language); ensure security and prevent fraud. We never sell your data to third parties.';

  @override
  String get privacySection3Title => '3. Service providers and partners';

  @override
  String get privacySection3Content =>
      'We rely on trusted technical providers: Supabase (hosting, database, authentication); Stripe (secure payments, PCI-DSS compliant); Firebase/Google (push notifications); Google and Apple (social sign-in, if you use it); Exchange Rate API (exchange rates for price display). These providers process your data in accordance with our instructions and legal requirements.';

  @override
  String get privacySection4Title => '4. Data retention';

  @override
  String get privacySection4Content =>
      'Account and profile data is retained for as long as your account is active. Order data is retained for legal and accounting obligations (typically 5 to 10 years depending on regulations). Notification tokens are deleted upon logout. You may request account deletion at any time.';

  @override
  String get privacySection5Title => '5. Your rights (GDPR)';

  @override
  String get privacySection5Content =>
      'Under the General Data Protection Regulation (GDPR), you have the right to: access your data; rectify inaccurate data; erasure (« right to be forgotten »); restrict processing; data portability; object to processing; withdraw consent. To exercise these rights, contact us at support@solma.com. You may also lodge a complaint with your country\'s supervisory authority.';

  @override
  String get privacySection6Title => '6. Security';

  @override
  String get privacySection6Content =>
      'We implement appropriate technical and organizational measures: HTTPS encryption for all communications; secure authentication; payments delegated to Stripe (PCI-DSS); storage of sensitive data on secure infrastructure. No credit card numbers are stored on our servers.';

  @override
  String get privacySection7Title => '7. Local storage and preferences';

  @override
  String get privacySection7Content =>
      'The app uses your device\'s local storage for preferences (light/dark theme, language, currency), cart, and wishlist. This data remains on your device and is not shared with third parties, except for account sync when you are signed in. Exchange rates are cached locally to improve performance.';

  @override
  String get privacySection8Title => '8. Changes and contact';

  @override
  String get privacySection8Content =>
      'We may update this policy to reflect changes in our practices or regulations. The last update date is shown at the top. For any questions regarding your personal data, contact us: support@solma.com or via the app\'s Help Center.';

  @override
  String get sessionExpired => 'Session Expired';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please sign in again.';

  @override
  String get reconnect => 'Sign In';

  @override
  String get reviews => 'Reviews';

  @override
  String reviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String get noReviews => 'No reviews yet';

  @override
  String get beFirstToReview => 'Be the first to review this product';

  @override
  String get writeReview => 'Write a review';

  @override
  String get editReview => 'Edit my review';

  @override
  String get yourRating => 'Your rating';

  @override
  String get yourComment => 'Your comment (optional)';

  @override
  String get submitReview => 'Submit';

  @override
  String get reviewSubmitted => 'Review submitted';

  @override
  String get reviewUpdated => 'Review updated';

  @override
  String get reviewDeleted => 'Review deleted';

  @override
  String get deleteReview => 'Delete review';

  @override
  String get deleteReviewConfirm => 'Delete this review?';

  @override
  String get loginToReview => 'Sign in to leave a review';

  @override
  String get verifiedPurchase => 'Verified purchase';

  @override
  String get helpful => 'Helpful';

  @override
  String get notHelpful => 'Not helpful';

  @override
  String peopleFoundHelpful(int count) {
    return '$count people found this review helpful';
  }

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortRecent => 'Most recent';

  @override
  String get sortHighest => 'Highest rating';

  @override
  String get sortLowest => 'Lowest rating';

  @override
  String get sortHelpful => 'Most helpful';

  @override
  String get seeAllReviews => 'See all reviews';

  @override
  String seeMoreReviews(int count) {
    return 'See more ($count remaining)';
  }

  @override
  String get reviewTitle => 'Review title';

  @override
  String get reviewTitleHint => 'Summarize your experience in a few words';

  @override
  String get pros => 'Pros';

  @override
  String get prosHint => 'What you liked...';

  @override
  String get cons => 'Cons';

  @override
  String get consHint => 'What could be improved...';

  @override
  String get starExcellent => 'Excellent';

  @override
  String get starGood => 'Good';

  @override
  String get starAverage => 'Average';

  @override
  String get starPoor => 'Poor';

  @override
  String get starBad => 'Bad';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get daysAgo => 'days ago';

  @override
  String get promoCodePlaceholder => 'Enter a promo code';

  @override
  String promoApplied(String amount) {
    return 'Promo code applied: -$amount';
  }

  @override
  String get promoMinOrder => 'Minimum order amount not reached';

  @override
  String get promoExpired => 'This promo code has expired';

  @override
  String get promoMaxUsed => 'This promo code is no longer available';

  @override
  String get promoNotFound => 'Promo code not found';

  @override
  String get discountLabel => 'Discount';

  @override
  String get removePromo => 'Remove';

  @override
  String get orderTracking => 'Order Tracking';

  @override
  String get trackingOrdered => 'Ordered';

  @override
  String get trackingConfirmed => 'Confirmed';

  @override
  String get trackingPreparing => 'Preparing';

  @override
  String get trackingShipped => 'Shipped';

  @override
  String get trackingInDelivery => 'Out for delivery';

  @override
  String get trackingDelivered => 'Delivered';

  @override
  String get noTrackingInfo => 'No tracking information available';

  @override
  String get whyChooseSOLMA => 'Why choose SOLMA?';

  @override
  String get dataProtection => 'Data protection';

  @override
  String get securePayment => 'Secure payment';

  @override
  String get deliveryWorldwide => 'Delivery worldwide';

  @override
  String get searchHint => 'Nike, Jordan…';

  @override
  String get noNewArrivals => 'No ads';

  @override
  String get newArrivals => 'Advertising';

  @override
  String get currency => 'Currency';

  @override
  String get currentCurrency => 'Current currency';

  @override
  String get chooseCurrency => 'Choose a currency';

  @override
  String get currencyInfoTitle => 'Information';

  @override
  String get currencyInfoBody =>
      'The selected currency will be used to display all prices in the app. Conversion rates will be applied automatically.';

  @override
  String get currencyInfoNote =>
      'Note: Conversions are based on real-time exchange rates.';

  @override
  String get currencyXof => 'West African CFA franc';

  @override
  String get currencyUsd => 'US Dollar';

  @override
  String get currencyEur => 'Euro';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get notificationChannelName => 'SOLMA Notifications';

  @override
  String get notificationChannelDesc => 'SOLMA app notifications';

  @override
  String get orderConfirmed => 'Order confirmed';

  @override
  String orderConfirmedBodyMultiple(String shortId, int count, String total) {
    return 'Your order #$shortId has been recorded. $count items, total $total.';
  }

  @override
  String orderConfirmedBodySingle(String shortId, String total) {
    return 'Your order #$shortId has been recorded. Total $total.';
  }
}
