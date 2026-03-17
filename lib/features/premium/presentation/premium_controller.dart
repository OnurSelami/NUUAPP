import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Define the API Keys
const String revenueCatApiKeyApple = "test_GOyydrQjFHyjXMVFePNiHnNSLqS";
const String revenueCatApiKeyGoogle = "test_GOyydrQjFHyjXMVFePNiHnNSLqS";

/// Represents the subscription state of the user.
class PremiumState {
  final bool isPremium;
  final bool isLoading;
  final String? error;
  final List<Package>? availablePackages;

  const PremiumState({
    this.isPremium = false,
    this.isLoading = false,
    this.error,
    this.availablePackages,
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
    List<Package>? availablePackages,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availablePackages: availablePackages ?? this.availablePackages,
    );
  }
}

/// The Riverpod Notifier for handling RevenueCat logic
class PremiumController extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    _initRevenueCat();
    return const PremiumState();
  }

  Future<void> _initRevenueCat() async {
    state = state.copyWith(isLoading: true);

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(revenueCatApiKeyApple);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(revenueCatApiKeyGoogle);
      } else {
        state = state.copyWith(isLoading: false, isPremium: false);
        return;
      }

      await Purchases.configure(configuration);
      await _checkSubscriptionStatus();
      await fetchOfferings();
    } catch (e) {
      debugPrint("Error initializing RevenueCat: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Checks the current purchaser info for active entitlements
  Future<void> _checkSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.all["premium"]?.isActive ?? false;
      state = state.copyWith(isPremium: isPremium, isLoading: false);
    } catch (e) {
      debugPrint("Error checking subscription status: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fetches the available products from RevenueCat
  Future<void> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        state = state.copyWith(availablePackages: offerings.current!.availablePackages);
      }
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
    }
  }

  /// Purchase a specific package
  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      final isPremium = customerInfo.entitlements.all["premium"]?.isActive ?? false;
      state = state.copyWith(isPremium: isPremium, isLoading: false);
      return isPremium;
    } catch (e) {
      debugPrint("Purchase failed: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.all["premium"]?.isActive ?? false;
      state = state.copyWith(isPremium: isPremium, isLoading: false);
      return isPremium;
    } catch (e) {
      debugPrint("Restore purchases failed: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// The global provider for the PremiumController
final premiumControllerProvider = NotifierProvider<PremiumController, PremiumState>(() {
  return PremiumController();
});
