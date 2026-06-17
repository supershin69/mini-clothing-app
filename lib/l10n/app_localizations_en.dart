// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navBarHome => 'Home';

  @override
  String get newArrivals => 'New Arrivals';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get clothing => 'Clothing';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get discountAds => 'Get Up to 30% OFF';

  @override
  String get explore => 'Explore';

  @override
  String get emptyCart => 'Your cart is empty!';

  @override
  String get addClothesEmptyCartText => 'Add some items to get started.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpText => 'Sign up to get started on your shopping profile';

  @override
  String get name => 'Full Name';

  @override
  String get email => 'Email Address';

  @override
  String get phoneNo => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAcc => 'Already have an account? Login';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInText => 'Sign in to your clothing account';

  @override
  String get login => 'Login';

  @override
  String get donthaveAcc => 'Don\'t have an account? Register here';

  @override
  String get search => 'Search clothing...';

  @override
  String get selectSize => 'Select Size';

  @override
  String get description => 'Description';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String get size => 'Size';

  @override
  String get subTotal => 'Subtotal';

  @override
  String get shippingFee => 'Shipping Fee';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get proceedToCheckout => 'PROCEED TO CHECKOUT';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get noDescription => 'No description available for this option.';

  @override
  String get outOfStock => 'OUT OF STOCK';

  @override
  String get checkoutSuccess => 'Order Placed Successfully!';

  @override
  String get returnHome => 'RETURN TO HOME';

  @override
  String get myOrders => 'My Orders';

  @override
  String get errorLoadingOrders => 'Error loading orders';

  @override
  String get noOrderHistory => 'You have no order history yet.';

  @override
  String get order => 'Order';

  @override
  String get orderOn => 'Order on';

  @override
  String get logout => 'Logout';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String verificationReqText(Object email) {
    return 'Please type in the OTP we sent to your email, $email.';
  }

  @override
  String get verifyAndCreateAccount => 'Verify & Create Account';
}
