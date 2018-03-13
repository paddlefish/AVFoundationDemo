//
//  VideoError.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/13/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation

enum VideoError: Error {
	case invalidResultDictionary
	case cannotCreateExportSession
	case cannotAddToComposition
	case cannotExportMpeg4
	case exportFailed
	case other(err: Error)
}
