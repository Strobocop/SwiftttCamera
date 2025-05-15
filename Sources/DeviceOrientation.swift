// Copyright © 2021 Roger Oba. All rights reserved.

import CoreMotion
import UIKit

public final class DeviceOrientation {
    public lazy var motionManager: CMMotionManager? = {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        #if TARGET_IPHONE_SIMULATOR
        return nil
        #else
        let result = CMMotionManager()
        result.accelerometerUpdateInterval = 0.005
        return result
        #endif
    }()
    
    public var orientation: UIDeviceOrientation = UIDevice.current.orientation
    public var lastKnownCameraOrientation: UIDeviceOrientation = UIDevice.current.orientation
    

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        #if !TARGET_IPHONE_SIMULATOR
        motionManager?.stopAccelerometerUpdates()
        #endif
        motionManager = nil
    }


    init() {
        #if !TARGET_IPHONE_SIMULATOR
        motionManager?.startAccelerometerUpdates(to: .main) { [weak self] accelerometerData, error in
            guard let self, let acceleration = accelerometerData?.acceleration else { return }
            
            let newOrientation = self.calculateOrientation(from: acceleration)
            
            // Cache the orientation before switching to face up/down
            if newOrientation != .faceUp && newOrientation != .faceDown {
                self.lastKnownCameraOrientation = newOrientation
            }
            
            self.orientation = newOrientation
        }
        #endif
    }
    
    private func calculateOrientation(from acceleration: CMAcceleration) -> UIDeviceOrientation {
        if (acceleration.z < -0.75) {
            return .faceUp
        }
        
        if (acceleration.z > 0.75) {
            return .faceDown
        }
        
        if acceleration.x >= 0.75 {
            return .landscapeRight
        }
        else if acceleration.x <= -0.75 {
            return .landscapeLeft
        }
        else if acceleration.y <= -0.75 {
            return .portrait
        }
        else if acceleration.y >= 0.75 {
            return .portraitUpsideDown
        }
        
        return orientation
    }


    /// Whether the physical orientation of the device matches the device's interface orientation.
    /// Expect this to return true when orientation lock is off, and false when orientation lock is on.
    /// This returns true if the device's interface orientation matches the physical device orientation, and false if the interface and physical orientation are different (when orientation lock is on).
    var deviceOrientationMatchesInterfaceOrientation: Bool {
        return orientation == UIDevice.current.orientation
    }
}
