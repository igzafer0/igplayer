import 'package:flutter_test/flutter_test.dart';
import 'package:igplayer/igplayer.dart';
import 'package:igplayer/igplayer_platform_interface.dart';
import 'package:igplayer/igplayer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIgplayerPlatform
    with MockPlatformInterfaceMixin
    implements IgplayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IgplayerPlatform initialPlatform = IgplayerPlatform.instance;

  test('$MethodChannelIgplayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIgplayer>());
  });

  test('getPlatformVersion', () async {
    Igplayer igplayerPlugin = Igplayer();
    MockIgplayerPlatform fakePlatform = MockIgplayerPlatform();
    IgplayerPlatform.instance = fakePlatform;

    expect(await igplayerPlugin.getPlatformVersion(), '42');
  });
}
