//
//  ExportController.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import AVFoundation

let PREFERRED_TIMESCALE: CMTimeScale = 600
private let MAXIMUM_VIDEO_DURATION: Double = 30

class ExportController: UIViewController {

	var exportedVideoView: VideoView!
	var syncVideoView: SynchronizedVideoView!
	
	let duration = CMTime(seconds: 10.0, preferredTimescale: PREFERRED_TIMESCALE)
	let videoSize = CGSize(width: 540, height: 540)
	
	override func loadView() {
		let view = UIView(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
		view.backgroundColor = UIColor.white
//		view.translatesAutoresizingMaskIntoConstraints = false
		
		let exportedVideoView = VideoView()
		exportedVideoView.translatesAutoresizingMaskIntoConstraints = false
		self.exportedVideoView = exportedVideoView
		
		let syncVideoView = SynchronizedVideoView()
		syncVideoView.translatesAutoresizingMaskIntoConstraints = false
		self.syncVideoView = syncVideoView
		
		let exportButton = UIButton()
		exportButton.translatesAutoresizingMaskIntoConstraints = false
		exportButton.setTitle("Export Video", for: UIControlState.normal)
		exportButton.backgroundColor = UIColor.blue
		exportButton.addTarget(self, action: #selector(export(_:)), for: UIControlEvents.touchUpInside)

		let pauseButton = UIButton()
		pauseButton.translatesAutoresizingMaskIntoConstraints = false
		pauseButton.setTitle("Pause", for: UIControlState.normal)
		pauseButton.backgroundColor = UIColor.blue
		pauseButton.addTarget(self, action: #selector(pause(_:)), for: UIControlEvents.touchUpInside)

		let playButton = UIButton()
		playButton.translatesAutoresizingMaskIntoConstraints = false
		playButton.setTitle("Play", for: UIControlState.normal)
		playButton.backgroundColor = UIColor.blue
		playButton.addTarget(self, action: #selector(play(_:)), for: UIControlEvents.touchUpInside)

		view.addSubview(exportedVideoView)
		view.addSubview(syncVideoView)
		view.addSubview(exportButton)
		view.addSubview(pauseButton)
		view.addSubview(playButton)

		let views = [
			"exportedVideoView": exportedVideoView,
			"syncVideoView": syncVideoView,
			"exportButton": exportButton,
			"pauseButton": pauseButton,
			"playButton": playButton,
		]
		NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-[syncVideoView]-[exportedVideoView(==syncVideoView)]-|",
			options: [],
			metrics: [:],
			views: views)
		)
		NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-[exportButton]-|",
			options: [],
			metrics: [:],
			views: views)
		)
		NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-[pauseButton(==playButton)]-[playButton]-|",
			options: [NSLayoutFormatOptions.alignAllBottom],
			metrics: [:],
			views: views)
		)
		NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-[exportedVideoView]-[exportButton]-[pauseButton]-(>=0)-|",
			options: [],
			metrics: [:],
			views: views)
		)
		NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-[syncVideoView]-(>=0)-|",
			options: [],
			metrics: [:],
			views: views)
		)
		syncVideoView.widthAnchor.constraint(equalTo: syncVideoView.heightAnchor, multiplier: 1.0).isActive = true
		exportedVideoView.widthAnchor.constraint(equalTo: exportedVideoView.heightAnchor, multiplier: 1.0).isActive = true

		self.view = view

	}
	
	// MARK: Lifecycle
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if let player = exportedVideoView.player, let playerItem = player.currentItem {
			removeObservations(playerItem: playerItem)
		}
		if let player = syncVideoView.player, let playerItem = player.currentItem {
			removeObservations(playerItem: playerItem)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let player = exportedVideoView.player, let playerItem = player.currentItem {
			addPlaybackObservations(playerItem: playerItem)
		}

		if let player = syncVideoView.player, let playerItem = player.currentItem {
			addPlaybackObservations(playerItem: playerItem)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let url = Bundle.main.url(forResource: "IMG_3352", withExtension: "MOV")!
//		let asset = AVURLAsset(url: url)
//		let playerItem = AVPlayerItem(asset: asset)
		if let itemAndLayer = toPlayerItemAndLayer(size: videoSize, mediaUrl: url) {
			syncVideoView.playerItem = itemAndLayer.0
			syncVideoView.animationLayer = itemAndLayer.1
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
	
	// MARK: - Animation
	
	func addAnimation(toLayer layer: CALayer, flipped: Bool) {
		
		// FIXME: actually figure out to vertically flip this animation
		// based on flipped
		
		let childLayer = CALayer()
		childLayer.frame = layer.frame.insetBy(dx: 100.0, dy: 100.0).offsetBy(dx: 60, dy: 20)
		childLayer.contents = #imageLiteral(resourceName: "00").cgImage
		layer.addSublayer(childLayer)
		
		layer.borderColor = UIColor.blue.cgColor
		layer.borderWidth = 30
		
		let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
		animation.beginTime = AVCoreAnimationBeginTimeAtZero
		animation.values = [Float(0.0), Float.pi/2.0, Float.pi, Float.pi/(-2.0), 0]
		animation.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 0.25), NSNumber(value: 0.5), NSNumber(value: 1.0)]
		animation.duration = CFTimeInterval(10.0)
		animation.autoreverses = false
		animation.repeatCount = 10
		animation.isRemovedOnCompletion = false
		layer.add(animation, forKey: "demo")
	}

	// MARK: - Actions

	@objc func export(_ sender: Any) {
		let filePath = String(format: "%@-demo-%@.mp4", NSTemporaryDirectory(), UUID().uuidString)
		let videoSize = CGSize(width: 540, height: 540)
		let url = Bundle.main.url(forResource: "IMG_3352", withExtension: "MOV")!
		exportToPath(filePath, preset: AVAssetExportPreset960x540, size: videoSize, mediaUrl: url) { (success, maybeError) in
			if success {
				let url = URL(fileURLWithPath: filePath)
				let asset = AVURLAsset(url: url)
				let playerItem = AVPlayerItem(asset: asset)
				self.exportedVideoView.playerItem = playerItem
			} else {
				print("Failed")
			}
		}
	}

	@objc func play(_ sender: Any) {
		syncVideoView.player?.play()
		exportedVideoView.player?.play()
	}

	@objc func pause(_ sender: Any) {
		syncVideoView.player?.pause()
		exportedVideoView.player?.pause()
	}

	// MARK: - Player item notifications
	
	@objc func itemDidPlayToEnd(_ notification: Foundation.Notification) {
//		player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
//		player?.play()
	}
	
	@objc func itemTimeJumped(_ notification: Foundation.Notification) {
		print(notification)
	}
	
	@objc func itemFailedToPlayToEnd(_ notification: Foundation.Notification) {
//		player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
	}
	
	@objc func pausePlaybackWhileInBackground(_ notification: Foundation.Notification) {
//		player?.pause()
	}
	
	@objc func maybeResumePlaybackAfterEnteringForeground(_ notification: Foundation.Notification) {
//		player?.play()
	}
	
	// MARK: Video Support

	func toPlayerItemAndLayer(size videoSize: CGSize, mediaUrl: URL) -> (AVPlayerItem, CALayer)? {

		guard let exportState = buildExportState(size: videoSize, mediaUrl: mediaUrl, flipped: false) else {
			return nil
		}

		return exportState.toPlayerItemAndLayer()
	}

	@discardableResult
	func appendVideoSegment(_ mediaUrl: URL, atTime startingTime: CMTime, maxDuration: CMTime, toComposition compositionVideoTrack: AVMutableCompositionTrack, compositionAudioTrack maybeCompositionAudioTrack: AVMutableCompositionTrack?, layerInstruction: AVMutableVideoCompositionLayerInstruction, fitInSize videoSize: CGSize) -> CMTime {
		var time = startingTime
//		mediaUrls.append(mediaUrl)
		if !FileManager.default.fileExists(atPath: mediaUrl.path) {
			print("\n\n*** Warning asset is not there ***\n\n\(mediaUrl)")
		}

		let asset = AVURLAsset(url: mediaUrl, options:[AVURLAssetPreferPreciseDurationAndTimingKey:true])

		guard let sourceVideoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
			return time
		}
		let assetTransform = asset.preferredTransform
		let trackTransform = sourceVideoTrack.preferredTransform
		let transform = assetTransform.concatenating(trackTransform)
		let temp = sourceVideoTrack.naturalSize.applying(transform)
		let size = CGSize(width: fabs(temp.width), height: fabs(temp.height))
		let hScale = videoSize.width / size.width
		let vScale = videoSize.height / size.height
		let scale = hScale > vScale ? hScale : vScale
		let scaledSize = size * scale

		let new = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))

		let x: CGFloat = floor((videoSize.width - scaledSize.width) / 2.0)
		let y: CGFloat = floor((videoSize.height - scaledSize.height) / 2.0)

		let newer = new.concatenating(CGAffineTransform(translationX: x, y: y))
		
	//						let rotated = CGAffineTransformConcat(newer, asset.orientation.transform)

		layerInstruction.setTransform(newer, at:time)

		do {
			let amountToInsert: CMTimeRange
			let fullTimeRange = sourceVideoTrack.timeRange
			if fullTimeRange.duration > maxDuration {
				amountToInsert = CMTimeRange(start: fullTimeRange.start, duration: maxDuration)
			} else {
				amountToInsert = fullTimeRange
			}
			try compositionVideoTrack.insertTimeRange(amountToInsert, of: sourceVideoTrack, at: time)
			if let firstAudioTrack = asset.tracks(withMediaType: AVMediaType.audio).first, let compositionAudioTrack = maybeCompositionAudioTrack {
				do {
					try compositionAudioTrack.insertTimeRange(amountToInsert, of: firstAudioTrack, at: time)
				} catch _ {
					print("Cannot insert audio track")
				}
			}
			time = time + amountToInsert.duration
		} catch _ {
			print("Cannot insert video track")
		}
		
		return time
	}

	private func buildExportState(size videoSize: CGSize, mediaUrl: URL, flipped: Bool) -> ExportState? {
		guard let exportState = ExportState(duration: duration, videoSize: videoSize) else {
			return nil
		}

		addAnimation(toLayer: exportState.animationLayer, flipped: flipped)
		let maxDuration = exportState.duration - exportState.startTime
		appendVideoSegment(mediaUrl, atTime: exportState.startTime, maxDuration: maxDuration, toComposition: exportState.cameraVideoTrack, compositionAudioTrack: exportState.cameraAudioTrack, layerInstruction: exportState.layerInstruction, fitInSize: videoSize)
		
		return exportState
	}

	func exportToPath(_ filePath: String, preset: String, size videoSize: CGSize, mediaUrl: URL, callback: @escaping (_ success: Bool, _ error: VideoError?) -> ()) {
		guard let exportState = buildExportState(size: videoSize, mediaUrl: mediaUrl, flipped: true) else {
			callback(false, VideoError.cannotAddToComposition)
			return
		}

		guard let session = AVAssetExportSession(asset: exportState.composition, presetName: preset) else {
			callback(false, VideoError.cannotCreateExportSession)
			return
		}
		exportState.setupForExport()
		session.videoComposition = exportState.videoComposition
		if !session.supportedFileTypes.contains(AVFileType.mp4) {
			// Sanity check that AVFoundation can export our format
			callback(false, VideoError.cannotExportMpeg4)
			return
		}

		session.shouldOptimizeForNetworkUse = true
		session.outputFileType = AVFileType.mp4
		session.canPerformMultiplePassesOverSourceMediaData = true

		session.timeRange = exportState.sequenceTimeRange

		// Assign the output URL built from the expanded output file path.
		session.outputURL = URL(fileURLWithPath: filePath, isDirectory:false)

		session.exportAsynchronously( completionHandler: {
			exportState.release()
			if let err = session.error {
				let domain: String
				let code: String
				let nserr = err as NSError
			
				domain = nserr.domain
				code = "\(nserr.code)"
				print("Video Encoding Error \(domain) \(code)")
				nserr.userInfo.forEach {
					print("\($0): \($1)")
				}
				DispatchQueue.main.async {
					callback(false, VideoError.other(err: err))
				}
			}
			else if case AVAssetExportSessionStatus.completed = session.status {
				DispatchQueue.main.async {
					callback(true, nil)
				}
//				self.cleanupTempFiles()
			}
			else {
				DispatchQueue.main.async {
					callback(false, VideoError.exportFailed)
				}
			}
		})
	}
	

}
