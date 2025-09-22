import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class ATTService {
  static const int _maxRetryAttempts = 30;
  static const int _retryDelaySeconds = 2;

  /// Request App Tracking Transparency permission with retry mechanism
  static Future<void> requestATTPermission({int attempt = 1}) async {
    // Only request on iOS devices
    if (!Platform.isIOS) {
      print('ATT: Not an iOS device, skipping ATT request');
      return;
    }

    try {
      print('ATT: Requesting permission (attempt $attempt/$_maxRetryAttempts)');

      // Check current tracking status first
      final TrackingStatus currentStatus =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      print('ATT: Current status: $currentStatus');

      // Only request if status is not determined
      if (currentStatus != TrackingStatus.notDetermined) {
        print('ATT: Permission already determined: $currentStatus');
        return;
      }

      // Request permission
      final TrackingStatus requestStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      print('ATT: Permission request result: $requestStatus');

      // Handle the result
      switch (requestStatus) {
        case TrackingStatus.authorized:
          print('ATT: User granted tracking permission');
          break;
        case TrackingStatus.denied:
          print('ATT: User denied tracking permission');
          break;
        case TrackingStatus.restricted:
          print('ATT: Tracking restricted by device settings');
          break;
        case TrackingStatus.notDetermined:
          print('ATT: Permission still not determined, retrying...');
          await _retryATTRequest(attempt);
          break;
        case TrackingStatus.notSupported:
          print('ATT: Tracking not supported on this device');
          break;
      }
    } catch (e) {
      print('ATT: Error requesting permission: $e');
      await _retryATTRequest(attempt);
    }
  }

  /// Retry ATT request with delay
  static Future<void> _retryATTRequest(int currentAttempt) async {
    if (currentAttempt < _maxRetryAttempts) {
      final int delaySeconds = _retryDelaySeconds * currentAttempt;
      print('ATT: Retrying in $delaySeconds seconds...');

      await Future.delayed(Duration(seconds: delaySeconds));
      await requestATTPermission(attempt: currentAttempt + 1);
    } else {
      print('ATT: Max retry attempts reached, giving up');
    }
  }

  /// Initialize ATT service and request permission if needed
  static Future<void> initialize() async {
    if (!Platform.isIOS) return;

    print('ATT: Initializing ATT service...');

    try {
      // Check current status
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      // Only request if status is not determined
      if (status == TrackingStatus.notDetermined) {
        // Add a small delay to ensure app is fully loaded
        await Future.delayed(const Duration(seconds: 1));
        await requestATTPermission();
      } else {
        print('ATT: Current status is $status, no need to request');
      }
    } catch (e) {
      print('ATT: Error initializing: $e');
    }
  }
}
