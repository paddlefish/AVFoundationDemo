//
//  DemoParentLayer.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/12/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit

class DemoParentLayer: CALayer {
	var myLayer: CALayer!
	var myLabelLayer: CATextLayer!
	var exLayer: CAShapeLayer!
	var nonSquare = false
	
	func build() {
		backgroundColor = UIColor.blue.withAlphaComponent(0.3).cgColor
		
		let sublayer: CALayer
		if let alreadySetLayer = myLayer {
			sublayer = alreadySetLayer
		} else {
			sublayer = CALayer()
		}
		myLayer = sublayer
		myLabelLayer = CATextLayer()
		exLayer = CAShapeLayer()

//		sublayer.delegate = NoAnimationLayerDelegate.shared
		addSublayer(sublayer)
		myLabelLayer.string = "Parent\n\nLayer"
		myLabelLayer.fontSize = 20
		myLabelLayer.foregroundColor = UIColor.purple.cgColor
		addSublayer(myLabelLayer)
		let path = CGMutablePath()
		path.move(to: CGPoint(x: -10, y: -10))
		path.addLine(to: CGPoint(x: 10, y: 10))
		path.move(to: CGPoint(x: 10, y: -10))
		path.addLine(to: CGPoint(x: -10, y: 10))
		exLayer.path = path
		exLayer.strokeColor = UIColor.red.cgColor
		exLayer.fillColor = UIColor.clear.cgColor
		exLayer.lineWidth = 3
		addSublayer(exLayer)
	}
	
	override func layoutSublayers() {
		let parentBounds = bounds
		let subBounds = CGRect(x: 0, y: 0, width: max(0, parentBounds.width - (nonSquare ? 100.0 : 50.0)), height: max(0, parentBounds.height - 50))
		let anchorPoint = CGPoint(x: 0.5, y: 0.5)
		let position = CGPoint(x: (parentBounds.minX + parentBounds.maxX) / 2.0, y: (parentBounds.minY + parentBounds.maxY) / 2.0)
		myLayer.anchorPoint = anchorPoint
		myLayer.position = position
		myLayer.bounds = subBounds
		myLabelLayer.position = CGPoint(x: 0, y: 0)
		myLabelLayer.bounds = bounds
		exLayer.position = position
		exLayer.anchorPoint = anchorPoint

//			myLayer?.frame = bounds.insetBy(dx: 100, dy: 100)
//			print(myLayer?.bounds)
//			print(myLayer?.position)
//			print(myLayer?.anchorPoint)
	}
}

