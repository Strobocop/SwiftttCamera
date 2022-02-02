//
//  VisionRequest.swift
//  SwiftttCamera
//
//  Created by Brian Strobach on 1/27/22.
//  Copyright © 2022 Brian Strobach. All rights reserved.
//

import Vision

public class VisionRequest {
    public var request: VNRequest
    public var options: [VNImageOption : Any]
    public var active: Bool

    public init(request: VNRequest, options: [VNImageOption : Any] = [:], active: Bool = true) {
        self.request = request
        self.options = options
        self.active = active
    }

    public init(options: [VNImageOption : Any] = [:], active: Bool = true, completionHandler: @escaping VNRequestCompletionHandler) {
        self.options = options
        self.active = active
        self.request = VNRequest(completionHandler: completionHandler)
    }
}

public protocol VisionRequestProtocol {
    func toVisionRequest() -> VisionRequest
}

extension VisionRequest: VisionRequestProtocol {
    public func toVisionRequest() -> VisionRequest {
        self
    }
}

extension VNRequest: VisionRequestProtocol {
    public func toVisionRequest() -> VisionRequest {
        VisionRequest(request: self)
    }
}

extension Array where Element == VisionRequestProtocol {
    public func toVisionRequests() -> [VisionRequest] {
        map({ $0.toVisionRequest() })
    }
}
