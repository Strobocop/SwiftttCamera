// Copyright © 2021 Roger Oba. All rights reserved.

import Foundation

/// An error type that describes possible errors that can occur in the SwiftttCamera.
public enum SwiftttCameraError: Error, Equatable {
    /// The camera session timed out while waiting for the view to appear.
    case cameraSessionTimedOutWaitingForViewToAppear
}