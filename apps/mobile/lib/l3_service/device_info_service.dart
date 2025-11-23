import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Model for device information
class DeviceInformation {
  final String deviceId;
  final String platform;
  final String osVersion;
  final String model;

  DeviceInformation({
    required this.deviceId,
    required this.platform,
    required this.osVersion,
    required this.model,
  });
}

/// Service to retrieve device information
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get comprehensive device information
  static Future<DeviceInformation> getDeviceInfo() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return DeviceInformation(
          deviceId: iosInfo.identifierForVendor ?? 'Unknown',
          platform: 'iOS',
          osVersion: iosInfo.systemVersion,
          model: iosInfo.utsname.machine,
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return DeviceInformation(
          deviceId: androidInfo.id,
          platform: 'Android',
          osVersion: androidInfo.version.release,
          model: '${androidInfo.manufacturer} ${androidInfo.model}',
        );
      } else {
        // Fallback for other platforms
        return DeviceInformation(
          deviceId: 'Unknown',
          platform: Platform.operatingSystem,
          osVersion: Platform.operatingSystemVersion,
          model: 'Unknown',
        );
      }
    } catch (e) {
      // Return fallback info if there's an error
      return DeviceInformation(
        deviceId: 'Error retrieving ID',
        platform: Platform.operatingSystem,
        osVersion: 'Unknown',
        model: 'Unknown',
      );
    }
  }

  /// Get just the device ID
  static Future<String> getDeviceId() async {
    final info = await getDeviceInfo();
    return info.deviceId;
  }

  /// Get just the platform name
  static Future<String> getPlatform() async {
    final info = await getDeviceInfo();
    return info.platform;
  }

  /// Get just the OS version
  static Future<String> getOsVersion() async {
    final info = await getDeviceInfo();
    return info.osVersion;
  }

  /// Get just the device model
  static Future<String> getDeviceModel() async {
    final info = await getDeviceInfo();
    return info.model;
  }
}
