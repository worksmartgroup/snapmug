import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  String addId;
  BannerAdWidget({super.key, required this.addId});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  @override
  void initState() {
    if (mounted) {
      _bannerAd = BannerAd(
        adUnitId: widget.addId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) => debugPrint('Ad loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            debugPrint('Ad failed to load: $error');
          },
        ),
      );
      _bannerAd.load();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd),
    );
  }
}

class NativedAdWidget extends StatefulWidget {
  String addId;
  NativedAdWidget({super.key, required this.addId});

  @override
  State<NativedAdWidget> createState() => _NativedAdWidgetState();
}

class _NativedAdWidgetState extends State<NativedAdWidget> {
  NativeAd? _nativeAd;
  bool isAdLoaded = false;
  void loadNativeAd() {
    print('init native add');
    _nativeAd = NativeAd(
      adUnitId: widget.addId,
      // factoryId: 'SnapMug Native Track Details', // Custom factory ID, defined in native ad factory
      request: const AdRequest(),
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.medium),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
         setState(() {
           isAdLoaded = true;
         });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Failed to load native ad: ${error.message}');
        },
      ),
    )..load();
  }

  @override
  void initState() {
    if (mounted) {
      loadNativeAd();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isAdLoaded
        ? const SizedBox.shrink()
        : AdWidget(ad: _nativeAd!);
  }
}

class GoogleAdds {
  static bool openAppAddLoaded = false;
  static InterstitialAd? _interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  static String trackDetailsAdId = 'ca-app-pub-4005202226815050/7755488471';
  static String wallet = 'ca-app-pub-4005202226815050/8130954349';
  static String trackDetailsNativeAdId =
      'ca-app-pub-4005202226815050/2332926355';
  static String openAppAdId = 'ca-app-pub-4005202226815050/7608719632';
  static String mainPlayerAdId = 'ca-app-pub-4005202226815050/8794072129';

  static void createInterstitialAd(String addId) {
    debugPrint('inter add loaded');
    InterstitialAd.load(
        adUnitId: addId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            showInterstitialAd(addId);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 3) {
              createInterstitialAd(addId);
            }
          },
        ));
  }

  static void showInterstitialAd(String addId) {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd(addId);
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;

  /// Load an AppOpenAd.
  static createAppOpenedAd() {
    debugPrint('loading the app open ad');
    AppOpenAd.load(
      adUnitId: openAppAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenAd?.show();
          showAdIfAvailable();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Whether an ad is available to be shown.
  static bool get isAdAvailable {
    return _appOpenAd != null;
  }

  static void showAdIfAvailable() {
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      createAppOpenedAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        openAppAddLoaded = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd?.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd?.dispose();
        _appOpenAd = null;
      },
    );
  }
}
