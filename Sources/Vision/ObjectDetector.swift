//
//  ObjectDetector.swift
//  SwiftttCamera
//
//  Created by Brian Strobach on 1/27/22.
//  Copyright © 2022 Brian Strobach. All rights reserved.
//

import Foundation
import CoreMotion
import AVFoundation
import UIKit
import Vision

public class ObjectDetector<Object: VNDetectedObjectObservation>: VisionRequest {

    public required init(configureRequest: @escaping (VNDetectRectanglesRequest) -> () = { _ in },
                         options: [VNImageOption : Any] = [:],
                         active: Bool,
                         onDidDetect: @escaping (([Object]?) -> ())) {


        let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: {  (request, error) in
            guard error == nil, let results = request.results as? [Object], !results.isEmpty else {
                onDidDetect(nil)
                return
            }
            onDidDetect(results)
        })

        rectDetectRequest.minimumConfidence = 0.8
        rectDetectRequest.maximumObservations = 15
        rectDetectRequest.minimumAspectRatio = 0.3

        configureRequest(rectDetectRequest)

        super.init(request: rectDetectRequest, options: options, active: active)

    }
}


