part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const GALLERY = _Paths.GALLERY;
  static const PROFILE = _Paths.PROFILE;
  static const WALLPAPER_DETAIL = _Paths.WALLPAPER_DETAIL;
  static const TOKEN_SHOP = _Paths.TOKEN_SHOP;
  static const PRIVACY_POLICY = _Paths.PRIVACY_POLICY;
  static const TERMS_OF_SERVICE = _Paths.TERMS_OF_SERVICE;
  static const ABOUT = _Paths.ABOUT;
}

abstract class _Paths {
  _Paths._();

  static const HOME = '/home';
  static const GALLERY = '/gallery';
  static const PROFILE = '/profile';
  static const WALLPAPER_DETAIL = '/wallpaper-detail';
  static const TOKEN_SHOP = '/token-shop';
  static const PRIVACY_POLICY = '/privacy-policy';
  static const TERMS_OF_SERVICE = '/terms-of-service';
  static const ABOUT = '/about';
}
