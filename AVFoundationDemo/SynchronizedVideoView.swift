//
//  SynchronizedVideoView.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/13/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices
import AVKit
import AVFoundation

class SynchronizedVideoView: VideoView {
	fileprivate var syncLayer: AVSynchronizedLayer?
	var animationLayer: CALayer? {
		didSet {
			if let oldLayer = oldValue {
				oldLayer.removeFromSuperlayer()
			}
			if let syncLayer = self.syncLayer {
				syncLayer.removeFromSuperlayer()
			}
			guard let animationLayer = animationLayer else {
				self.syncLayer = nil
				return
			}
			guard let playerItem = playerItem else {
				self.syncLayer = nil
				print("WARNING: Setting animation prior to setting playerItem will not work")

				return
			}
			let syncLayer = AVSynchronizedLayer(playerItem: playerItem)
			self.syncLayer = syncLayer
			
			let frame = layer.bounds
			syncLayer.frame = frame
			let animationSize = animationLayer.frame.size
			let frameSize = frame.size
			let dx = frameSize.width / animationSize.width
			let dy = frameSize.height / animationSize.height
			let scaleTransform = CGAffineTransform(scaleX: dx, y: dy)
			animationLayer.setAffineTransform(scaleTransform)
			animationLayer.frame = frame

			syncLayer.addSublayer(animationLayer)

			layer.addSublayer(syncLayer)
			layer.masksToBounds = true
		}
	}
}
