//
//  VideoView.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/13/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//
//
//  VideoPlayerView.swift
//  BitMines
//
//  Created by Andrew Rahn on 2/20/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices
import AVKit
import AVFoundation

class VideoView: UIView {
	var playerLayer: AVPlayerLayer {
		return layer as! AVPlayerLayer
	}

	// Override UIView property
	override class var layerClass: AnyClass {
		return AVPlayerLayer.self
	}

    var player: AVPlayer? {
		didSet {
			playerLayer.player = player
		}
	}

	var playerItem: AVPlayerItem? {
		didSet {
			let ctr = NotificationCenter.default
			if let oldItem = self.playerItem {
				ctr.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: oldItem)
				ctr.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: oldItem)
				ctr.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: oldItem)
				ctr.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: oldItem)
			}
			self.player?.pause()
			if let item = playerItem {
				player = AVPlayer(playerItem: item)
				ctr.addObserver(self, selector: #selector(itemDidPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
				ctr.addObserver(self, selector: #selector(itemFailedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: item)
				ctr.addObserver(self, selector: #selector(pausePlaybackWhileInBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
				ctr.addObserver(self, selector: #selector(maybeResumePlaybackAfterEnteringForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
				player?.play()
			}
			else {
				player = nil
			}
		}
	}
	
	// MARK: - Lifecycle
	
	deinit {
		playerItem = nil
	}

	override func awakeFromNib() {
		playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
		playerLayer.backgroundColor = UIColor.black.cgColor
	}

	// MARK: - Player item notifications
	
	@objc func itemDidPlayToEnd(_ notification: Foundation.Notification) {
		player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
		player?.play()
	}
	
	@objc func itemFailedToPlayToEnd(_ notification: Foundation.Notification) {
		player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
	}
	
	@objc func pausePlaybackWhileInBackground(_ notification: Foundation.Notification) {
		player?.pause()
	}
	
	@objc func maybeResumePlaybackAfterEnteringForeground(_ notification: Foundation.Notification) {
		player?.play()
	}

}
