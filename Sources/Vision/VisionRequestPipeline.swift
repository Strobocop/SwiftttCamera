//
//  VisionHandler.swift
//  SwiftttCamera
//
//  Created by Brian Strobach on 1/27/22.
//  Copyright © 2022 Brian Strobach. All rights reserved.
//

import Foundation
import Vision
import AVFoundation
import UIKit

//public protocol VisionRequestPipelineDelegate: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func visionRequest(from pipeline: VisionRequestPipeline, didFailWith error: Error)
//}
//
//public extension VisionRequestPipelineDelegate {
//    func visionRequest(from pipeline: VisionRequestPipeline, didFailWith error: Error) {
//        dump(error)
//    }
//}
//
//open class VisionRequestPipeline: NSObject, VideoDataOutputDelegate {
//    public var requests: [VNRequest]
//    public var options: [VNImageOption : Any]
//    weak var delegate: VisionRequestPipelineDelegate?
//
//    public init(delegate: VisionRequestPipelineDelegate? = nil, requests: [VNRequest] = [], options: [VNImageOption : Any] = [:]) {
//        self.delegate = delegate
//        self.requests = requests
//        self.options = options
//    }
//
//    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        delegate?.captureOutput?(output, didDrop: sampleBuffer, from: connection)
//    }
//    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Received sample buffer of size \(sampleBuffer.totalSampleSize).")
//        delegate?.captureOutput?(output, didOutput: sampleBuffer, from: connection)
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        let exifOrientation = CGImagePropertyOrientation(deviceOrientation: UIDevice.current.orientation)
//
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: options)
//
//        do {
//            try imageRequestHandler.perform(self.requests)
//        } catch {
//            delegate?.visionRequest(from: self, didFailWith: error)
//        }
//    }
//}

//Options on a per request basis

public protocol VisionRequestPipelineDelegate: AVCaptureVideoDataOutputSampleBufferDelegate {
    func vision(request: VisionRequest, from pipeline: VisionRequestPipeline, didFailWith error: Error)
    func vision(requestPipeline pipeline: VisionRequestPipeline, didFailToCreateRequestWith error: Error)
}

public extension VisionRequestPipelineDelegate {
    func vision(request: VisionRequest, from pipeline: VisionRequestPipeline, didFailWith error: Error) {
        dump(error)
    }
    func vision(requestPipeline pipeline: VisionRequestPipeline, didFailToCreateRequestWith error: Error) {
        dump(error)
    }
}

public typealias VisionRequestsBuilder = (_ sampleBuffer: CMSampleBuffer, _ connection: AVCaptureConnection) throws -> [VisionRequestProtocol]

open class VisionRequestPipeline: NSObject, VideoDataOutputDelegate {
    
    public var requests: [VisionRequest]
    weak var delegate: VisionRequestPipelineDelegate?
    let imageRequestHandler = VNSequenceRequestHandler()
    private var requestsBuilder: VisionRequestsBuilder?

    public init(delegate: VisionRequestPipelineDelegate? = nil, requests: [VisionRequestProtocol]) {
        self.delegate = delegate
        self.requests = requests.toVisionRequests()
    }

    public init(delegate: VisionRequestPipelineDelegate? = nil, requestBuilder: VisionRequestsBuilder?) {
        self.delegate = delegate
        self.requestsBuilder = requestBuilder
        self.requests = [] //Will build later with context of CMSampleBuffer and AVCaptureConnection
    }

    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput?(output, didDrop: sampleBuffer, from: connection)
    }
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput?(output, didOutput: sampleBuffer, from: connection)

        if let builder = requestsBuilder, self.requests.isEmpty {
            do {
                requests = try builder(sampleBuffer, connection).toVisionRequests()
            }
            catch {
                delegate?.vision(requestPipeline: self, didFailToCreateRequestWith: error)
            }

        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        for request in self.requests {
            guard request.active else { continue }
//            DispatchQueue.global(qos: .background).async {

//            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: request.options)

                do {
                    try self.imageRequestHandler.perform([request.request], on: pixelBuffer)
                } catch {
                    self.vision(request: request, didFailWith: error)
                }
//            }
        }

    }

    func vision(request: VisionRequest, didFailWith error: Error) {
        delegate?.vision(request: request, from: self, didFailWith: error)
    }
}
