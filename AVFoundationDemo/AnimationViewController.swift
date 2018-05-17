//
//  AnimationViewController.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class AnimationViewController: UIViewController, LayerBasedDemo {

	var actionDelegate: ActionCollectionViewDelegate!
	var demoView: DemoParentLayerView!
	var label: UILabel!
	
	enum Actions: Int {
		case opacity
		case borderWidth
		case cornerRadius
		case cornerRadiusClipping
		case backgroundUIColor
		case backgroundCGColor
		case rasterizationScale
		case shadowColor
		case shadowRadius
		case position
		case anchorPoint
		case contentUIImage
		case contentCGImage
		case contentsCGImage
		case isHidden

		var stuff: (String, String, String, Any, Any) {
			switch self {
				// If you get a crash here, it's a compiler bug
				// Try again in Xcode 9.3 beta
				case .opacity: return ("opacity", "CABasicAnimation(\"opacity\")", "opacity", 1.0, 0.0)
				case .borderWidth: return ("borderWidth", "CABasicAnimation(\"borderWidth\")", "borderWidth", 5.0, 50.0)
				case .cornerRadius: return ("cornerRadius", "CABasicAnimation(\"cornerRadius\")", "cornerRadius", 0.0, 200.0)
				case .cornerRadiusClipping: return ("(masked)", "masksToBounds = true", "cornerRadius", 0.0, 200.0)
				case .backgroundUIColor: return ("background UIColor", "fromValue = UIColor.yellow", "backgroundColor", UIColor.yellow, UIColor.green)
				case .backgroundCGColor: return ("background CGColor", "fromValue = UIColor.yellow.cgColor", "backgroundColor", UIColor.yellow.cgColor, UIColor.green.cgColor)
				case .rasterizationScale: return ("rasterization", "rasterizationScale = 0.01", "rasterizationScale", 1.0, 0.01)
				case .shadowColor: return ("shadowColor", "shadowColor = CGColor", "shadowColor", UIColor.black.cgColor, UIColor.orange.cgColor)
				case .shadowRadius: return ("shadowRadius", "shadowRadius = 50", "shadowRadius", CGFloat(3.0), CGFloat(50))
				case .position: return ("position", "position = CGPoint(x: 100, y: 100)", "position", CGPoint(x: -100, y: -100), CGPoint(x: 100, y: 100))
				case .anchorPoint: return ("anchorPoint", "anchorPoint = CGPoint(x: 1, y: 1)", "anchorPoint", CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
				case .contentUIImage: return ("content UIImage", "content = UIImage", "content", #imageLiteral(resourceName: "00"), #imageLiteral(resourceName: "01"))
				case .contentCGImage: return ("content CGImage", "content = CGImage", "content", #imageLiteral(resourceName: "00").cgImage!, #imageLiteral(resourceName: "01").cgImage!)
				case .contentsCGImage: return ("contents CGImage", "contents = CGImage", "contents", #imageLiteral(resourceName: "00").cgImage!, #imageLiteral(resourceName: "01").cgImage!)
				case .isHidden: return ("isHidden", "isHidden = true", "isHidden", true, false)
			}
		}
		
		var shadowOpacity: Float {
			switch self {
				case .shadowColor, .shadowRadius: return 1.0
				default: return 0.0
			}
		}
		
		var shadowRadius: CGFloat {
			switch self {
				case .shadowColor: return 20.0
				default: return 0.0
			}
		}
		
		var masksToBounds: Bool {
			switch self {
				case .cornerRadiusClipping:
					return true
				default:
					return false
			}
		}
		
		var contents: Any? {
			switch self {
				case .backgroundCGColor, .backgroundUIColor, .contentCGImage, .contentsCGImage, .contentUIImage:
					return nil
				default:
					return #imageLiteral(resourceName: "layer_texture").cgImage
			}
		}
		
		var backgroundColor: CGColor? {
			switch self {
				case .backgroundCGColor, .backgroundUIColor, .contentCGImage, .contentsCGImage, .contentUIImage:
					return nil
				default:
					return UIColor.blue.cgColor
			}
		}

		var title: String {
			return stuff.0
		}
		
		var info: String {
			return stuff.1
		}

		var keyPath: String {
			return stuff.2
		}
		
		var fromValue: Any {
			return stuff.3
		}
		
		var toValue: Any {
			return stuff.4
		}
		
		var shouldRasterize: Bool {
			switch self {
				case .rasterizationScale: return true
				default: return false
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
	var mode: Actions = .opacity
	
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
		
		layer.shadowOpacity = mode.shadowOpacity
		
		layer.backgroundColor = mode.backgroundColor
		parentLayer.masksToBounds = true
		
		layer.masksToBounds = mode.masksToBounds
		layer.shouldRasterize = mode.shouldRasterize

		let animation = CABasicAnimation(keyPath: mode.keyPath)
		animation.fromValue = mode.fromValue
		animation.toValue = mode.toValue
		animation.duration = CFTimeInterval(1.0)
		animation.autoreverses = true
		animation.repeatCount = 1
		layer.add(animation, forKey: "demo")

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
