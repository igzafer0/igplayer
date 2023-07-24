//
//  VideoPlayerViewFactory.swift
//  igplayer
//
//  Created by Zafer Çetin on 6.05.2023.
//

import Foundation
import AVFoundation
import Flutter
import MediaPlayer
import AVKit

class VideoPlayerFactory: NSObject, FlutterPlatformViewFactory {
    
    var videoPlayer:VideoPlayerView?
    
    var registrar:FlutterPluginRegistrar?
    
    private var messenger:FlutterBinaryMessenger
    
    /* register video player */
    static func register(with registrar: FlutterPluginRegistrar) {
        
     
        let plugin = VideoPlayerFactory(messenger: registrar.messenger())
        
        plugin.registrar = registrar
            
        registrar.register(plugin, withId: "igzafer/IgVideoPlayerNative")
    }
    
    init(messenger:FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        
        self.videoPlayer = VideoPlayerView(frame: frame, viewId: viewId, messenger: messenger, args: args)
        
        self.registrar?.addApplicationDelegate(self.videoPlayer!)
        
        return self.videoPlayer!
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterJSONMessageCodec()
    }
    
    public func applicationDidEnterBackground() {}
    
    public func applicationWillEnterForeground() {}
}

