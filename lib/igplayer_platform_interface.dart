import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'igplayer_method_channel.dart';

abstract class IgplayerPlatform extends PlatformInterface {
  /// Constructs a IgplayerPlatform.
  IgplayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static IgplayerPlatform _instance = MethodChannelIgplayer();

  /// The default instance of [IgplayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelIgplayer].
  static IgplayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IgplayerPlatform] when
  /// they register themselves.
  static set instance(IgplayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
