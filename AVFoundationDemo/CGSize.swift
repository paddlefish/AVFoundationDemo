//
//  CGSize.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/13/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import CoreGraphics

func * (sz: CGSize, m: CGFloat) -> CGSize {
	return CGSize(width: sz.width * m, height: sz.height * m)
}

func * (sz: CGSize, m: CGPoint) -> CGSize {
	return CGSize(width: sz.width * m.x, height: sz.height * m.y)
}
