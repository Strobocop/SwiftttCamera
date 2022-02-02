//
//  VisionRequest.swift
//  SwiftttCamera
//
//  Created by Brian Strobach on 1/27/22.
//  Copyright © 2022 Brian Strobach. All rights reserved.
//

import Vision

public struct VisionResponse<Result: VNObservation> {
    public var request: VNRequest
    public var error: Error?

    public func results() throws -> [Result] {
        if let error = error {
            throw error
        }
        return request.detectedResults()
    }
}


public protocol VNObservationInitializable {
    associatedtype ObservationType: VNObservation
    init(observation: ObservationType)
}

public extension VNRequest {
    func detectedResults<Result: VNObservation>() -> [Result] {
        guard let results = results as? [Result] else {
            return []
        }
        return results
    }

    convenience init<Result: VNObservation>(onResponse: @escaping (VisionResponse<Result>) -> ()) {
        self.init { request, error in
            onResponse(VisionResponse(request: request, error: error))
        }
    }

    convenience init<Result: VNObservationInitializable>(onObserve: @escaping ([Result]) -> ()) {
        self.init { (response: VisionResponse<Result.ObservationType>) in
            guard let results: [Result.ObservationType] = try? response.results() else {
                onObserve([])
                return
            }
            onObserve(results.map(Result.init))
        }
    }
}
