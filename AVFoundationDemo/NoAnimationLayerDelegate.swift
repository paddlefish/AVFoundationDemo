//
//  NoAnimationLayerDelegate.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/12/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit

class NoAnimationLayerDelegate: NSObject, CALayerDelegate {
	static var shared: NoAnimationLayerDelegate = NoAnimationLayerDelegate()
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
    	return NSNull()
	}
}
