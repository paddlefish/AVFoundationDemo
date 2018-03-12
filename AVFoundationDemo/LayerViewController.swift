//
//  LayerViewController.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit

class LayerViewController: UIViewController {

	class ParentLayer: CALayer {
		var myLayer: CALayer?
		var nonSquare = false
		
		override func layoutSublayers() {
			let parentBounds = bounds
			let subBounds = CGRect(x: 0, y: 0, width: max(0, parentBounds.width - (nonSquare ? 100.0 : 50.0)), height: max(0, parentBounds.height - 50))
			let anchorPoint = CGPoint(x: 0.5, y: 0.5)
			let position = CGPoint(x: (parentBounds.minX + parentBounds.maxX) / 2.0, y: (parentBounds.minY + parentBounds.maxY) / 2.0)
			myLayer?.anchorPoint = anchorPoint
			myLayer?.position = position
			myLayer?.bounds = subBounds
			
//			myLayer?.frame = bounds.insetBy(dx: 100, dy: 100)
//			print(myLayer?.bounds)
//			print(myLayer?.position)
//			print(myLayer?.anchorPoint)
		}
	}
	
	class ParentLayerView: UIView {
		override class var layerClass: AnyClass {
			return ParentLayer.self
		}
	}
	
	var squareConstraint: NSLayoutConstraint!
	var actionDelegate: ActionCollectionViewDelegate!
	var layer: CALayer!
	var parentLayer: ParentLayer!
	
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
			}
		}
		
		var gravity: String {
			switch self {
				case .resizeAspect, .resizeAspectNonSquare:
					return "resizeAspect"
				default:
					return "resizeAspectFill"
			}
		}
		
		var squareConstraintActive: Bool {
			switch self {
				case .resizeAspectFillNonSquare, .resizeAspectNonSquare, .resizeAspectFillNonSquareMasked:
					return false
				default:
					return true
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
				case .scale200Masked, .resizeAspectFillNonSquareMasked:
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
	}
	var mode: Actions = .resizeAspectFill
	
	var actions: [ActionCell.Action]!

	@discardableResult
	func addLayerView(toView view: UIView) -> UIView {
		let layerView = ParentLayerView()
		layerView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(layerView)

		layerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		layerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
		layerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
		layerView.widthAnchor.constraint(equalTo: layerView.heightAnchor).isActive = true
		
		self.parentLayer = layerView.layer as! ParentLayer
		
		let sublayer = CALayer()
		parentLayer.addSublayer(sublayer)
		parentLayer.myLayer = sublayer

		self.layer = sublayer

		return layerView
	}
	
	func setupLayer() {
		guard let layer = self.layer else {
			return
		}
		
		parentLayer.nonSquare = !mode.squareConstraintActive
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

	}
	
	@discardableResult
	func addActionsView(toView view: UIView, belowView: UIView, actions: [ActionCell.Action]) -> UIView {
		let delegate = ActionCollectionViewDelegate(actions: actions)
		
		self.actionDelegate = delegate
		let collectionView = delegate.setup()
		
		view.addSubview(collectionView)
		
		collectionView.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 10).isActive = true
		collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
		collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true

		return collectionView
	}
	
	func setupActions() {
		self.actions = Actions.all.map { action in
			ActionCell.Action(title: action.title, action: { [weak self] in
				self?.mode = action
				self?.setupLayer()
			})
		}
	}

	override func loadView() {
		let view = UIView()
		view.backgroundColor = UIColor.white
		
		let layerView = addLayerView(toView: view)
		
		setupLayer()
		
		setupActions()
		
		addActionsView(toView: view, belowView: layerView, actions: actions)
		
		self.view = view
	}
}
