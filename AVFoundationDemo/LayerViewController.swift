//
//  LayerViewController.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
	convenience init(contents: UIImage) {
		self.init()
		self.contents = contents.cgImage
	}
}

class LayerViewController: UIViewController, LayerBasedDemo {

	var actionDelegate: ActionCollectionViewDelegate!
	var demoView: DemoParentLayerView!
	var label: UILabel!
	
	enum Actions: Int {
		case resizeAspectFill
		case resizeAspectFillNonSquare
		case resizeAspectFillNonSquareMasked
		case resizeAspect
		case resizeAspectNonSquare
		case rotate90
		case rotate90Masked
		case rotatePi
		case translate10
		case translate100
		case scale50
		case scale200
		case scale200ParentMasked
		case scale200Masked
		case skew10
		case shapeMask

		var title: String {
			switch self {
				case .resizeAspectFill: return "resizeAspectFill"
				case .resizeAspectFillNonSquare: return "(non square)"
				case .resizeAspectFillNonSquareMasked: return "(masked)"
				case .resizeAspect: return "resizeAspect"
				case .resizeAspectNonSquare: return "(non square)"
				case .rotate90: return "rotate 90"
				case .rotate90Masked: return "(masked)"
				case .rotatePi: return "rotate π"
				case .translate10: return "translate 10"
				case .translate100: return "100"
				case .scale50: return "scale 0.5"
				case .scale200: return "2.0"
				case .scale200ParentMasked: return "(masked)"
				case .scale200Masked: return "(self)"
				case .skew10: return "skew 10"
				case .shapeMask: return "masked"
			}
		}
		
		var info: String {
			switch self {
				case .resizeAspectFill, .resizeAspectFillNonSquare: return "contentsGravity = kCAGravityResizeAspectFill"
				case .resizeAspectFillNonSquareMasked: return "masksToBounds = true"
				case .resizeAspect, .resizeAspectNonSquare: return "contentsGravity = kCAGravityResizeAspect"
				case .rotate90: return "setAffineTransform(rotationAngle: 90))"
				case .rotate90Masked: return "parentLayer.masksToBounds = true"
				case .rotatePi: return "setAffineTransform(rotationAngle: CGFloat.pi))"
				case .translate10: return "CGAffineTransform(translationX: 10, y: 10)"
				case .translate100: return "CGAffineTransform(translationX: 100, y: 100)"
				case .scale50: return "CGAffineTransform(scaleX: 0.5, y: 0.5)"
				case .scale200: return "CGAffineTransform(scaleX: 2.0, y: 2.0)"
				case .scale200ParentMasked: return "parentLayer.masksToBounds = true"
				case .scale200Masked: return "masksToBounds = true"
				case .skew10: return "CGAffineTransform(a: 1.0, b: 1.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)"
				case .shapeMask: return "mask = layer2"
			}
		}
		
		var gravity: String {
			switch self {
				case .resizeAspect, .resizeAspectNonSquare:
					return kCAGravityResizeAspect
				default:
					return kCAGravityResizeAspectFill
			}
		}
		
		var nonSquare: Bool {
			switch self {
				case .resizeAspectFillNonSquare, .resizeAspectNonSquare, .resizeAspectFillNonSquareMasked:
					return true
				default:
					return false
			}
		}
		
		var masksParentToBounds: Bool {
			switch self {
				case .rotate90Masked, .scale200ParentMasked:
					return true
				default:
					return false
			}
		}
		
		var masksToBounds: Bool {
			switch self {
				case .scale200Masked, .resizeAspectFillNonSquareMasked, .shapeMask:
					return true
				default:
					return false
			}
		}

		var affineTransform: CGAffineTransform {
			switch self {
				case .rotate90, .rotate90Masked:
					return CGAffineTransform(rotationAngle: 90)
				case .rotatePi:
					return CGAffineTransform(rotationAngle: CGFloat.pi)
				case .translate10:
					return CGAffineTransform(translationX: 10, y: 10)
				case .translate100:
					return CGAffineTransform(translationX: 100, y: 100)
				case .scale50:
					return CGAffineTransform(scaleX: 0.5, y: 0.5)
				case .scale200, .scale200Masked, .scale200ParentMasked:
					return CGAffineTransform(scaleX: 2.0, y: 2.0)
				case .skew10:
					return CGAffineTransform(a: 1.0, b: 1.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)
				default:
					return CGAffineTransform.identity
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
		
		var layerMask: CALayer? {
			switch self {
				case .shapeMask:
					return CALayer(contents: #imageLiteral(resourceName: "mask"))
				default:
					return nil
			}
		}
	}
	var mode: Actions = .resizeAspectFill
	
	var actions: [ActionCell.Action]!
	
	func setupLayer() {
		guard let layer = self.layer else {
			return
		}
		
		parentLayer.nonSquare = mode.nonSquare
		parentLayer.setNeedsLayout()

		parentLayer.borderColor = UIColor.purple.withAlphaComponent(0.2).cgColor
		parentLayer.borderWidth = 10

		layer.borderColor = UIColor.red.withAlphaComponent(0.2).cgColor
		layer.borderWidth = 10

		layer.setAffineTransform(mode.affineTransform)
		layer.contents = #imageLiteral(resourceName: "layer_texture").cgImage
			// Setting contents to a UIImage is not a compile error, nor a runtime error
			// but does not work.
		
		layer.backgroundColor = UIColor.blue.cgColor
		layer.contentsGravity = mode.gravity
		parentLayer.masksToBounds = mode.masksParentToBounds
		layer.masksToBounds = mode.masksToBounds
		if let layerMask = mode.layerMask {
			layerMask.contentsGravity = kCAGravityResizeAspect
			layerMask.anchorPoint = layer.anchorPoint
			layerMask.frame = layer.bounds
			layer.mask = layerMask
		} else {
			layer.mask = nil
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
