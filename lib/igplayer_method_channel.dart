import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'igplayer_platform_interface.dart';

/// An implementation of [IgplayerPlatform] that uses method channels.
class MethodChannelIgplayer extends IgplayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('igplayer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
