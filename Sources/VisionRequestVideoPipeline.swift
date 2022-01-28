//
//  VisionHandler.swift
//  GiftAMeal
//
//  Created by Brian Strobach on 1/27/22.
//  Copyright © 2022 GiftAMeal. All rights reserved.
//

import Foundation
import Vision
import AVFoundation
import UIKit

public protocol VideoDataOutputPipelineDelegate: AVCaptureVideoDataOutputSampleBufferDelegate {
    func visionRequest(from pipeline: VideoDataOutputPipeline, didFailWith error: Error)
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
}

public extension VideoDataOutputPipelineDelegate {
    func visionRequest(from pipeline: VideoDataOutputPipeline, didFailWith error: Error) {}    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {}
}

open class VideoDataOutputPipeline: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var queueName: String
    public var requests: [VNRequest]
    weak var delegate: VideoDataOutputPipelineDelegate?

    public lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: queueName))
        return dataOutput
    }()

    public init(queueName: String = "visionQueue", delegate: VideoDataOutputPipelineDelegate? = nil, requests: [VNRequest] = []) {
        self.queueName = queueName
        self.delegate = delegate
        self.requests = requests
    }

    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput?(output, didDrop: sampleBuffer, from: connection)
    }
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Received sample buffer of size \(sampleBuffer.totalSampleSize).")
        delegate?.captureOutput?(output, didOutput: sampleBuffer, from: connection)
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let exifOrientation = exifOrientationFromDeviceOrientation()

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])

        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            dump(error)
            delegate?.visionRequest(from: self, didFailWith: error)
        }
    }

    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:
            exifOrientation = .down
        case UIDeviceOrientation.portrait:
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }

}
