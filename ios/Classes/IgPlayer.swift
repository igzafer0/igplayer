//
//  IgPlayer.swift
//  igplayer
//
//  Created by Zafer Çetin on 6.05.2023.
//

import Foundation
import Flutter
import AVKit

class IgPlayer: AVPlayer {
    var flutterEventSink:FlutterEventSink?
    
    
    
    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        
        let position = self.currentTime().seconds
        
        super.seek(to: time, toleranceBefore: toleranceAfter, toleranceAfter: toleranceAfter, completionHandler: { (isCompleted) in
         
            
            /* call super completion handler */
            completionHandler(isCompleted)
        })
    }
}
