import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdHelper {
  static bool showAds = true;
  static String? _dynamicBannerAdUnitId;
  static String? _dynamicInterstitialAdUnitId;
  static String? _dynamicRewardedAdUnitId;
  static String? _dynamicAppOpenAdUnitId;

  static String get bannerAdUnitId {
    if (_dynamicBannerAdUnitId != null && _dynamicBannerAdUnitId!.isNotEmpty) {
      return _dynamicBannerAdUnitId!;
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-8488137796617875/2267233930'; // Production ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (_dynamicInterstitialAdUnitId != null && _dynamicInterstitialAdUnitId!.isNotEmpty) {
      return _dynamicInterstitialAdUnitId!;
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-8488137796617875/6179247142'; // Production ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get rewardedAdUnitId {
    if (_dynamicRewardedAdUnitId != null && _dynamicRewardedAdUnitId!.isNotEmpty) {
      return _dynamicRewardedAdUnitId!;
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-8488137796617875/9926920462'; // Production ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get appOpenAdUnitId {
    if (_dynamicAppOpenAdUnitId != null && _dynamicAppOpenAdUnitId!.isNotEmpty) {
      return _dynamicAppOpenAdUnitId!;
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-8488137796617875/6747203291'; // Production ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5662855259'; // Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  static InterstitialAd? _interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  static RewardedAd? _rewardedAd;
  static int _numRewardedLoadAttempts = 0;

  static AppOpenAd? _appOpenAd;
  static bool _isShowingAppOpenAd = false;
  static DateTime? _appOpenLoadTime;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('settings').doc('appSettings').get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        print('--- AD SETTINGS FROM FIREBASE ---');
        print(data);
        showAds = data['showAds'] ?? true;
        _dynamicBannerAdUnitId = data['bannerAdUnitId'];
        _dynamicInterstitialAdUnitId = data['interstitialAdUnitId'];
        _dynamicRewardedAdUnitId = data['rewardedAdUnitId'];
        _dynamicAppOpenAdUnitId = data['appOpenAdUnitId'];
      }
    } catch (e) {
      debugPrint('Error fetching ad settings: $e');
    }

    if (showAds) {
      _createInterstitialAd();
      _createRewardedAd();
      loadAppOpenAd();
    }
  }

  static void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  static void showInterstitialAd({void Function()? onAdDismissed}) {
    if (!showAds || _interstitialAd == null) {
      onAdDismissed?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
        onAdDismissed?.call();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  static int _interstitialCounter = 0;

  /// Shows interstitial ad only every [frequency] calls to prevent spamming
  static void showSmartInterstitialAd({void Function()? onAdDismissed, int frequency = 3}) {
    _interstitialCounter++;
    if (_interstitialCounter % frequency == 0) {
      showInterstitialAd(onAdDismissed: onAdDismissed);
    } else {
      onAdDismissed?.call();
    }
  }

  static bool get isRewardedAdLoaded => _rewardedAd != null;

  static void loadRewardedAd() {
    if (_rewardedAd == null) {
      _createRewardedAd();
    }
  }

  static void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            _rewardedAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numRewardedLoadAttempts += 1;
            _rewardedAd = null;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  static void showRewardedAd({
    required void Function(RewardItem) onUserEarnedReward,
    void Function()? onAdDismissed,
  }) {
    if (!showAds) {
      onUserEarnedReward(RewardItem(1, 'prompt_unlock'));
      onAdDismissed?.call();
      return;
    }

    if (_rewardedAd == null) {
      // Reload for next time
      _createRewardedAd();
      // Grant reward to prevent locking user out if network failed
      onUserEarnedReward(RewardItem(1, 'prompt_unlock'));
      onAdDismissed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _createRewardedAd(); // Preload next rewarded ad immediately
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _createRewardedAd();
        // Give reward if ad failed to show so user isn't stuck
        onUserEarnedReward(RewardItem(1, 'prompt_unlock'));
        onAdDismissed?.call();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onUserEarnedReward(reward);
    });
    _rewardedAd = null;
  }

  // --- App Open Ad Implementation ---
  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  static bool get _isAdAvailable {
    return _appOpenAd != null && _appOpenLoadTime != null && 
           DateTime.now().subtract(const Duration(hours: 4)).isBefore(_appOpenLoadTime!);
  }

  static void showAppOpenAdIfAvailable() {
    if (!showAds) return;
    
    if (!_isAdAvailable) {
      loadAppOpenAd();
      return;
    }
    if (_isShowingAppOpenAd) {
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAppOpenAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }
}


