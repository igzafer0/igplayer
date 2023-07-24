//
//  VideoPlayerView.swift
//  igplayer
//
//  Created by Zafer Çetin on 6.05.2023.
//

import Foundation
import AVFoundation
import Flutter
import MediaPlayer
import AVKit



class VideoPlayerView: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterPlatformView {
    
    static func register(with registrar: FlutterPluginRegistrar) { }
    
    
    var frame:CGRect
    var viewId:Int64
    
    var player: IgPlayer?
    var playerViewController:AVPlayerViewController?
    
    var url:String = ""
    var speed:Float = 1.0
    var autoPlay:Bool = false
    var artworkUrl:String = ""
    var title:String = ""
    var subtitle:String = ""
    var initialPosition:Int = 0
    var volume:Float = 1
    var enablePip:Bool = false
    
    
    
    private var isPlaying = false
    private var timeObserverToken:Any?
    let requiredAssetKeys = [
        "playable",
    ]
    
    private var eventChannel:FlutterEventChannel?
    private var flutterEventSink:FlutterEventSink?
    
    private var nowPlayingInfo = [String : Any]()
    
    
    init(frame:CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        
        
        
        self.frame = frame
        self.viewId = viewId
        
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playback, mode: .moviePlayback, options: AVAudioSession.CategoryOptions.allowBluetooth)
            } else {
                try audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.allowBluetooth)
            }
        } catch _ { }
        
        setupEventChannel(viewId: viewId, messenger: messenger, instance: self)
        
        setupMethodChannel(viewId: viewId, messenger: messenger)
        
        
        let parsedData = args as! [String: Any]
        
        
        self.url = parsedData["url"] as! String
        self.autoPlay = parsedData["autoPlay"] as! Bool
        self.artworkUrl = parsedData["artworkUrl"] as! String
        self.title = parsedData["title"] as! String
        self.subtitle = parsedData["subtitle"] as! String
        self.initialPosition = parsedData["initialPosition"] as! Int
        self.volume = Float(truncating: parsedData["volume"] as! NSNumber)

        setupPlayer()
    }
    
    private func setupEventChannel(viewId: Int64, messenger:FlutterBinaryMessenger, instance:VideoPlayerView) {
        
        instance.eventChannel = FlutterEventChannel(name: "igzafer/NativeVideoPlayerEventChannel"+String(viewId) , binaryMessenger: messenger, codec: FlutterJSONMethodCodec.sharedInstance())
        
        instance.eventChannel!.setStreamHandler(instance)
        self.flutterEventSink?(["name":"created"])
        
    }
    
    private func setupMethodChannel(viewId: Int64, messenger:FlutterBinaryMessenger) {
        
        let nativeMethodsChannel = FlutterMethodChannel(name: "igzafer/NativeVideoPlayerMethodChannel"+String(viewId), binaryMessenger: messenger);
        
        nativeMethodsChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            
            
            if ("play" == call.method) {
                self.play()
            }
            else if ("pause" == call.method) {
                self.pause()
            }else if ("newPosition" == call.method) {
                self.newPosition(newPosition: call.arguments as! Int)
            }else if ("skipPosition" == call.method) {
                self.skipPosition(skipPosition: call.arguments as! Int )
            }else if ("changeVolume" == call.method) {
                self.volume = Float(truncating: call.arguments as! NSNumber)
                self.changeVolume()
            }else if("mediaChanged" == call.method){
                self.pause()
                let parsedData = call.arguments as! [String: Any]
                self.url = parsedData["url"] as! String
                self.volume = Float(truncating: parsedData["volume"] as! NSNumber)
                self.onMediaChanged()
                result(true)
            }else if("changeSpeed" == call.method){
            
                self.speed = call.arguments as! Float
                self.changeSpeed()
            }
            else if ("dispose" == call.method) {
                self.dispose()
                result(true)
            }
            else if("enablePip"==call.method){
                self.enablePip=call.arguments as! Bool
                self.playerViewController?.allowsPictureInPicturePlayback = self.enablePip
                if(self.enablePip){
                    if #available(iOS 14.2, *) {
                    if AVPictureInPictureController.isPictureInPictureSupported() {
                        self.playerViewController?.canStartPictureInPictureAutomaticallyFromInline = true
                    }
                }
                }
                
            }
            
            else { result(FlutterMethodNotImplemented) }
        })
    }
    func changeVolume(){
        self.player?.volume=self.volume
    }
    func setupPlayer(){
        
        if let videoURL = URL(string: self.url.trimmingCharacters(in: .whitespacesAndNewlines)) {
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                if #available(iOS 10.0, *) {
                    try audioSession.setCategory(AVAudioSession.Category.playback, mode: .moviePlayback, options: AVAudioSession.CategoryOptions.allowBluetooth)
                } else {
                    try audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.allowBluetooth)
                }
                try audioSession.setActive(true)
            } catch _ { }
            
            let asset = AVAsset(url: videoURL)
            
            if (asset.isPlayable) {
                
                let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)
                
                self.player = IgPlayer(playerItem: playerItem)
            }
            else {
                
                self.player = IgPlayer()
            }
            
            let center = NotificationCenter.default
            
            center.addObserver(self, selector: #selector(onComplete(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            
            if #available(iOS 12.0, *) {
                self.player?.preventsDisplaySleepDuringVideoPlayback = true
            }
            
            
            
            self.player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options:[.old, .new, .initial], context: nil)
            
            
            let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
                time in self.onTimeInterval(time: time)
            }
            
            
            
            
            self.playerViewController = AVPlayerViewController()
            if #available(iOS 10.0, *) {
                self.playerViewController?.updatesNowPlayingInfoCenter = false
            }
            
            self.playerViewController?.player = self.player
            self.playerViewController?.view.frame = self.frame
            self.playerViewController?.showsPlaybackControls = false
            
         
          
           
            
            setupRemoteTransportControls()
            
            setupNowPlayingInfoPanel()
            if(self.autoPlay){
               
                play()
               
            }
            self.player?.volume = self.volume
            self.player?.seek(to: CMTime(seconds: Double(self.initialPosition), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            let viewController = (UIApplication.shared.delegate?.window??.rootViewController)!
            viewController.addChild(self.playerViewController!)
        }
    }
    
    func view() -> UIView {
        return self.playerViewController!.view
    }
    
    private func changeSpeed(){
        player?.rate = self.speed
        self.play()
    }
    private func onMediaChanged() {
        if let p = self.player {
            if let videoURL = URL(string: self.url) {
                let asset = AVAsset(url: videoURL)
                let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)
                p.replaceCurrentItem(with: playerItem)
                p.seek(to: CMTime(seconds: Double(self.initialPosition), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
                p.volume=self.volume
                setupRemoteTransportControls()
                setupNowPlayingInfoPanel()
                
            }
        }
    }
    
    private func onShowControlsFlagChanged() {
        self.playerViewController?.showsPlaybackControls = false
    }
    
    @objc func onComplete(_ notification: Notification) {
        pause()
        isPlaying = false
        self.player?.seek(to: CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        updateInfoPanelOnComplete()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
            if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            
                guard let p = object as! AVPlayer? else {
                    return
                }
                
                switch (p.timeControlStatus) {
                case AVPlayer.TimeControlStatus.paused:
                    isPlaying = false
                    
                    break
                    
                case AVPlayer.TimeControlStatus.playing:
                    isPlaying = true
                    self.flutterEventSink?(["name":"onPlay"])
                    break
                    
                case .waitingToPlayAtSpecifiedRate: break
                @unknown default:
                    break
                }
                
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
       
    }
    
    
    private func setupRemoteTransportControls() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { event in
            if self.player?.rate == 0.0 {
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { event in
            if self.player?.rate == 1.0 {
                self.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    
    private func setupNowPlayingInfoPanel() {
        let urlArt = self.artworkUrl
        guard let url = URL(string: urlArt) else { return }
        getData(from: url) { [weak self] image in
            guard let self = self,
                  let downloadedImage = image else {
                return
            }
            
            if #available(iOS 10.0, *) {
                let artwork = MPMediaItemArtwork.init(boundsSize: downloadedImage.size, requestHandler: { _ -> UIImage in
                    return downloadedImage
                })
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            } else {
                let artwork = MPMediaItemArtwork(image: downloadedImage)
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
            
        }
        
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = self.subtitle
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.asset.duration.seconds
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func getData(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let data = data {
                completion(UIImage(data:data))
            }
        })
        .resume()
    }
    
    
    private func updateInfoPanelOnPause() {
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((self.player?.currentTime())!)
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    private func updateInfoPanelOnComplete() {
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateInfoPanelOnTime() {
        
        self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds((self.player?.currentTime())!)
        
        self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
    }
    
    @objc private func play() {
        self.flutterEventSink?(["name":"isPlaying","state":true] as [String : Any])
        player?.play()
       
        
    }
    
    private func pause() {
        self.flutterEventSink?(["name":"isPlaying","state":false] as [String : Any])
        player?.pause()
        updateInfoPanelOnPause()
     
        
        
    }
    
    private func newPosition(newPosition:Int) {
        let myTime = CMTime(seconds: Double(newPosition), preferredTimescale: 60000)
        player?.seek(to: myTime,toleranceBefore: .zero, toleranceAfter: .zero)
        self.flutterEventSink?(["name":"playerTime","time":Int(newPosition)] as [String : Any])
        
        updateInfoPanelOnPause()
        
        
    }
    private func skipPosition(skipPosition:Int) {
        if let currentItem = player?.currentItem {
            
            let currentTime = Int(CMTimeGetSeconds(currentItem.currentTime()))
            let myTime = CMTime(seconds: Double(currentTime + skipPosition), preferredTimescale: 60000)
            player?.seek(to: myTime,toleranceBefore: .zero, toleranceAfter: .zero)
            
            updateInfoPanelOnPause()
            
            
        }
        
        
    }
    
    
    
    private func onTimeInterval(time:CMTime) {
        
        if (isPlaying) {
            self.flutterEventSink?(["name":"playerTime","time":Int(time.seconds)] as [String : Any])
            
            if let currentItem = player?.currentItem {
                if(!currentItem.duration.seconds.isNaN){
                    let duration = CMTimeGetSeconds(currentItem.duration)
                    self.flutterEventSink?(["name":"playerDuration","duration":Int(duration)] as [String : Any])
                }
            }
            
            updateInfoPanelOnTime()
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        flutterEventSink = events
        self.player?.flutterEventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        flutterEventSink = nil
        self.player?.flutterEventSink = nil
        return nil
    }
    
    
    
    public func dispose() {
        
        self.player?.pause()
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        if let timeObserver = timeObserverToken {
            player?.removeTimeObserver(timeObserver)
            timeObserverToken = nil
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
        } catch _ { }
        
        NotificationCenter.default.removeObserver(self)
        self.player?.flutterEventSink = nil
        self.flutterEventSink = nil
        self.eventChannel?.setStreamHandler(nil)
        self.player = nil
    }
    
}

