//
//  ExportState.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 5/14/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class ExportState {
	let startTime = CMTime.init(value: 0, timescale: PREFERRED_TIMESCALE)
	let duration: CMTime
	let videoSize: CGSize
	let videoRect: CGRect
	let videoComposition = AVMutableVideoComposition()
	let sequenceTimeRange: CMTimeRange
	let composition = AVMutableComposition()
	let cameraVideoTrack: AVMutableCompositionTrack
	let cameraAudioTrack: AVMutableCompositionTrack
	let animationLayer = CALayer()
	let layerInstruction: AVMutableVideoCompositionLayerInstruction
	let instruction = AVMutableVideoCompositionInstruction()

	init?(duration: CMTime, videoSize: CGSize) {
		self.duration = duration
		self.videoSize = videoSize
		self.videoRect = CGRect(origin: .zeroPoint, size: videoSize)
		videoComposition.renderSize = videoSize
		videoComposition.frameDuration = CMTimeMake(1, 30)
		videoComposition.renderScale = 1.0
		guard let cameraVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID:kCMPersistentTrackID_Invalid) else {
			return nil
		}
		self.cameraVideoTrack = cameraVideoTrack
		guard let cameraAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID:kCMPersistentTrackID_Invalid) else {
			return nil
		}
		self.cameraAudioTrack = cameraAudioTrack

		animationLayer.frame = CGRect(origin: .zeroPoint, size: videoSize)
		animationLayer.backgroundColor = UIColor.clear.cgColor

		self.layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: cameraVideoTrack)

		sequenceTimeRange = CMTimeRangeMake(kCMTimeZero, duration)
	}
	
	func release() {
//			just here so we have a way to retain all those objects
//			until export is done
	}
	
	func toPlayerItemAndLayer() -> (AVPlayerItem, CALayer) {
		instruction.layerInstructions = [layerInstruction]
		instruction.timeRange = sequenceTimeRange

		videoComposition.instructions = [instruction]

		let videoCompositionCopy = videoComposition
		let compositionCopy = composition
		let animationLayerCopy = animationLayer

		let playerItem = AVPlayerItem(asset: compositionCopy)
		playerItem.videoComposition = videoCompositionCopy
		playerItem.forwardPlaybackEndTime = duration
		
		return (playerItem, animationLayerCopy)
	}
	
	func setupForExport() {
		_ = toPlayerItemAndLayer()
		let parentLayer = CALayer()
		parentLayer.frame = videoRect
		let videoLayer = CALayer()
		videoLayer.frame = videoRect
		animationLayer.isGeometryFlipped = true
		animationLayer.frame = videoRect
		
		parentLayer.addSublayer(videoLayer)
		parentLayer.addSublayer(animationLayer)
		
		let myAnimationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
		 videoComposition.animationTool = myAnimationTool
	}
}

