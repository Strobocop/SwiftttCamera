// Copyright © 2021 Roger Oba. All rights reserved.

import CoreMotion
import UIKit

/// Struct used to manage the device's actual orientation.
final class DeviceOrientation {
    private lazy var motionManager: CMMotionManager? = {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        #if TARGET_IPHONE_SIMULATOR
        return nil
        #else
        let result = CMMotionManager()
        result.accelerometerUpdateInterval = 0.005
        result.startAccelerometerUpdates()
        return result
        #endif
    }()

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        #if !TARGET_IPHONE_SIMULATOR
        motionManager?.stopAccelerometerUpdates()
        #endif
        motionManager = nil
    }

    private var _orientation: UIDeviceOrientation = UIDevice.current.orientation

    /// The current actual orientation of the device, based on accelerometer data if on a device, or [[UIDevice currentDevice] orientation] if on the simulator.
    var orientation: UIDeviceOrientation {
        #if TARGET_IPHONE_SIMULATOR
        return .portrait
        #else
        guard let acceleration: CMAcceleration = motionManager?.accelerometerData?.acceleration else { return _orientation }

        if (acceleration.z < -0.75) {
            _orientation = .faceUp
        }

        if (acceleration.z > 0.75) {
            _orientation = .faceDown
        }

        if acceleration.x >= 0.75 {
            _orientation = .landscapeRight
        }
        else if acceleration.x <= -0.75 {
            _orientation = .landscapeLeft
        }
        else if acceleration.y <= -0.75 {
            _orientation = .portrait
        }
        else if acceleration.y >= 0.75 {
            _orientation = .portraitUpsideDown
        }
        return _orientation

        #endif
    }

    /// Whether the physical orientation of the device matches the device's interface orientation.
    /// Expect this to return true when orientation lock is off, and false when orientation lock is on.
    /// This returns true if the device's interface orientation matches the physical device orientation, and false if the interface and physical orientation are different (when orientation lock is on).
    var deviceOrientationMatchesInterfaceOrientation: Bool {
        return orientation == UIDevice.current.orientation
    }
}
