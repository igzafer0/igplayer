import Flutter
import UIKit

public class IgplayerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        VideoPlayerFactory.register(with: registrar)
       }
}
