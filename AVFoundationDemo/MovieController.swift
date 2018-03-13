//
//  MovieController.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import AVFoundation

class MovieController: UIViewController, LayerBasedDemo {

	var actionDelegate: ActionCollectionViewDelegate!
	var demoView: DemoParentLayerView!
	var label: UILabel!
	var player: AVPlayer!
	var playerLayer: AVPlayerLayer!
	
	enum Actions: Int {
		case plain
		case videoGravityResizeAspectFill
		case flip

		var title: String {
			switch self {
				case .plain:
					return "Play Movie"
				case .videoGravityResizeAspectFill:
					return "Aspect Fill"
				case .flip:
					return "Y-Axis Rotate"
			}
		}
		
		var info: String {
			switch self {
				case .plain:
					return "AVPlayer, AVPlayerLayer, AVPlayerItem"
				case .videoGravityResizeAspectFill:
					return "videoGravity = AVLayerVideoGravity.resizeAspectFill"
				case .flip:
					return "animate transform.rotation.y"
			}
		}
		
		var videoGravity: AVLayerVideoGravity {
			switch self {
				case .videoGravityResizeAspectFill:
					return AVLayerVideoGravity.resizeAspectFill
				default:
					return AVLayerVideoGravity.resizeAspect
			}
		}
		
		var basicAnimationStuff: (String, Any, Any)? {
			switch self {
				case .flip:
					return ("transform.rotation.y", -Float.pi, Float.pi)
				default:
					return nil
			}
		}

		static var all: [Actions] {
			var result: [Actions] = []
			var val = 0
			while true {
				guard let a = Actions(rawValue: val) else {
					break
				}
				result.append(a)
				val = val + 1
			}
			return result
		}
	}
	var mode: Actions = .plain
	
	var actions: [ActionCell.Action]!
	
	func setupLayer() {
		guard let layer = self.layer else {
			return
		}
		let mode = self.mode

		parentLayer.nonSquare = false
		parentLayer.setNeedsLayout()

		parentLayer.borderColor = UIColor.purple.withAlphaComponent(0.2).cgColor
		parentLayer.borderWidth = 10

		layer.borderColor = UIColor.red.withAlphaComponent(0.2).cgColor
		layer.borderWidth = 10
		
		parentLayer.masksToBounds = true
		
		DispatchQueue.main.async {
			self.playerLayer.videoGravity = mode.videoGravity
			if let basicAnimationStuff = mode.basicAnimationStuff {
				let animation = CABasicAnimation(keyPath: basicAnimationStuff.0)
				animation.fromValue = basicAnimationStuff.1
				animation.toValue = basicAnimationStuff.2
				animation.duration = CFTimeInterval(1.0)
				animation.autoreverses = false
				animation.repeatCount = 4
				layer.add(animation, forKey: "demo")
			}
//			let animation = CAKeyframeAnimation(keyPath: mode.keyPath)
//			animation.values = mode.values
//			animation.keyTimes = mode.keyTimes
//			animation.duration = CFTimeInterval(1.0)
//			animation.autoreverses = false
//			animation.repeatCount = 1
//			layer.add(animation, forKey: "demo")
		}
	}
	
	func setupActions() -> [ActionCell.Action] {
		self.actions = Actions.all.map { action in
			ActionCell.Action(title: action.title, action: { [weak self] in
				self?.mode = action
				self?.label.text = action.info
				self?.setupLayer()
			})
		}
		return self.actions
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if let player = self.player, let playerItem = player.currentItem {
			removeObservations(playerItem: playerItem)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let player = self.player, let playerItem = player.currentItem {
			addPlaybackObservations(playerItem: playerItem)
		}
	}
	
	func removeObservations(playerItem: AVPlayerItem) {
		let ctr = NotificationCenter.default

		ctr.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
		ctr.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: playerItem)
		ctr.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
		ctr.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: playerItem)
		ctr.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: playerItem)
	}
	
	func addPlaybackObservations(playerItem: AVPlayerItem) {
		let ctr = NotificationCenter.default
		
		ctr.addObserver(self, selector: #selector(itemDidPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
		ctr.addObserver(self, selector: #selector(itemTimeJumped), name: NSNotification.Name.AVPlayerItemTimeJumped, object: playerItem)
		ctr.addObserver(self, selector: #selector(itemFailedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
		ctr.addObserver(self, selector: #selector(pausePlaybackWhileInBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
		ctr.addObserver(self, selector: #selector(maybeResumePlaybackAfterEnteringForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
	}

	override func loadView() {
		let layerView = DemoParentLayerView()
		let playerLayer = AVPlayerLayer()
		self.playerLayer = playerLayer
		layerView.parentLayer.myLayer = playerLayer
		let url = Bundle.main.url(forResource: "time", withExtension: "mp4")!
		let asset = AVURLAsset(url: url)
		let playerItem = AVPlayerItem(asset: asset)
		let player = AVPlayer(playerItem: playerItem)
		self.player = player
		
		playerLayer.player = player

		player.play()
		
		let views = setupDemoView(layerView: layerView)
		self.view = views.0
		self.demoView = views.1
		self.actionDelegate = views.2
		self.label = views.3
		
		setupLayer()
	}


	// MARK: - Player item notifications
	
	@objc func itemDidPlayToEnd(_ notification: Foundation.Notification) {
		player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
		player?.play()
	}
	
	@objc func itemTimeJumped(_ notification: Foundation.Notification) {
		print(notification)
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
