//
//  DemoParentLayerView.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/12/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit

class DemoParentLayerView: UIView {
	override class var layerClass: AnyClass {
		return DemoParentLayer.self
	}
	
	var parentLayer: DemoParentLayer {
		return layer as! DemoParentLayer
	}
}

