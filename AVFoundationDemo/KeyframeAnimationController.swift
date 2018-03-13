//
//  KeyframeAnimationController.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class KeyframeAnimationController: UIViewController, LayerBasedDemo {

	var actionDelegate: ActionCollectionViewDelegate!
	var demoView: DemoParentLayerView!
	var label: UILabel!
	
	enum Actions: Int {
		case wander
		case pulse
		case propeller
		case paddle

		var contents: Any? {
			switch self {
				default:
					return #imageLiteral(resourceName: "layer_texture").cgImage
			}
		}
		
		var backgroundColor: CGColor? {
			switch self {
				default:
					return UIColor.blue.cgColor
			}
		}

		var title: String {
			switch self {
				case .wander:
					return "wander"
				case .pulse:
					return "pulse"
				case .propeller:
					return "propeller"
				case .paddle:
					return "paddle"
			}
		}
		
		var info: String {
			switch self {
				case .wander:
					return "anchorPoint"
				case .pulse:
					return "opacity"
				case .propeller:
					return "transform.rotation.z"
				case .paddle:
					return "transform.rotation.y"
			}
		}

		var keyPath: String {
			switch self {
				case .wander:
					return "anchorPoint"
				case .pulse:
					return "opacity"
				case .propeller:
					return "transform.rotation.z"
				case .paddle:
					return "transform.rotation.y"
			}
		}
		
		var values: [Any] {
			switch self {
				case .wander:
					return [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]
				case .pulse:
					return [1.0, 0.0, 1.0]
				case .propeller, .paddle:
					return [0.0, CGFloat.pi, 2*CGFloat.pi, 3*CGFloat.pi, 4*CGFloat.pi]
						// .map { CATransform3DMakeRotation($0, 0, 0, 1.0) }
			}
		}
		
		var keyTimes: [NSNumber] {
			let t: [Double]
			switch self {
				case .wander:
					t = [0.0, 0.25, 0.5, 0.75, 1.0]
				case .pulse:
					t = [0.0, 0.125, 1.0]
				case .propeller, .paddle:
					t = [0.0, 0.5, 0.75, 0.875, 1.0]
			}
			return t.map { NSNumber(value: $0) }
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
	var mode: Actions = .wander
	
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

		layer.setAffineTransform(CGAffineTransform.identity)
		layer.contents = mode.contents
			// Setting contents to a UIImage is not a compile error, nor a runtime error
			// but does not work.
		
		layer.backgroundColor = mode.backgroundColor
		parentLayer.masksToBounds = true
		
		DispatchQueue.main.async {
			let animation = CAKeyframeAnimation(keyPath: mode.keyPath)
			animation.values = mode.values
			animation.keyTimes = mode.keyTimes
			animation.duration = CFTimeInterval(1.0)
			animation.autoreverses = false
			animation.repeatCount = 1
			layer.add(animation, forKey: "demo")
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

	override func loadView() {
		let layerView = DemoParentLayerView()
		let views = setupDemoView(layerView: layerView)
		self.view = views.0
		self.demoView = views.1
		self.actionDelegate = views.2
		self.label = views.3
		
		setupLayer()
	}
}
