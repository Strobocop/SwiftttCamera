//
//  CGImagePropertyOrientation+UIDeviceOrientation.swift
//  SwiftttCamera
//
//  Created by Brian Strobach on 1/27/22.
//  Copyright © 2022 Brian Strobach. All rights reserved.
//

import UIKit

extension CGImagePropertyOrientation {
    public init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portraitUpsideDown:
            self = .left
        case .landscapeLeft:
            self = .upMirrored
        case .landscapeRight:
            self = .down
        case .portrait:
            self = .up
        default:
            self = .up
        }
    }
}
