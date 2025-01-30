//
//  BoundingBoxProvidingRectangles.swift
//  SDSVisionExtension
//
//  Created by Tomoaki Yagishita on 2025/01/25.
//

import Foundation
import Vision
import SwiftUI
import SDSCGExtension

@available(macOS 15.0, iOS 18.0, tvOS 18.0, visionOS 2.0, *)
extension BoundingBoxProviding {
    // Note: origin in Vision  is lower-left
    //       origin in SwiftUI is upper-left
    func unNormalizeRect(in imageSize: CGSize) -> CGRect {
        let rectSize = rectSize(in: imageSize)
        let originX = imageSize.width * self.boundingBox.origin.x
        let originY = imageSize.height * (1.0 - self.boundingBox.origin.y) - rectSize.height
        return CGRect(origin: CGPoint(x: originX, y: originY), size: rectSize)
    }
    func rectSize(in imageSize: CGSize) -> CGSize {
        return CGSize(width: imageSize.width * self.boundingBox.width, height: imageSize.height * self.boundingBox.height)
    }
    func rectCenter(in imageSize: CGSize) -> CGPoint {
        return unNormalizeRect(in: imageSize).center()
    }
    
    func pointInDetectRect(_ imageSize: CGSize,_ normalizedPoint: CGPoint) -> CGPoint {
        let rect = unNormalizeRect(in: imageSize)
        return rect.pointInRect(ratioX: normalizedPoint.x, ratioY: (1.0 - normalizedPoint.y))
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, visionOS 2.0, *)
struct BoundingBoxProvidingRectangles<T: VisionObservation & BoundingBoxProviding>: ViewModifier {
    var faceObservations: [T]
    let color: Color

    init(_ faceObservations: [T], color: Color) {
        self.faceObservations = faceObservations
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geom in
                    ForEach(faceObservations, id: \.uuid) { faceObservation in
                        Rectangle()
                            .strokeBorder(lineWidth: 3)
                            .foregroundColor(color)
                            .frame(faceObservation.rectSize(in: geom.size))
                            .position(faceObservation.rectCenter(in: geom.size))
                    }
                }
            )
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, visionOS 2.0, *)
public enum InteresetVisionFaceLandmark {
    case rightEye, leftEye, nose, innerLips, outerLips
    case medianLine
    
    func propRegion(_ faceObservation: FaceObservation) -> FaceObservation.Landmarks2D.Region? {
        switch self {
        case .rightEye:
            return faceObservation.landmarks?.rightEye
        case .leftEye:
            return faceObservation.landmarks?.leftEye
        case .nose:
            return faceObservation.landmarks?.nose
        case .innerLips:
            return faceObservation.landmarks?.innerLips
        case .outerLips:
            return faceObservation.landmarks?.outerLips
        case .medianLine:
            return faceObservation.landmarks?.medianLine
        }
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, visionOS 2.0, *)
struct LandmarkShapes: ViewModifier {
    var faceObservations: [FaceObservation]
    let interestTypes: [InteresetVisionFaceLandmark]
    let color: Color
    let lineWidth: CGFloat

    init(_ faceObservations: [FaceObservation], interestParts: [InteresetVisionFaceLandmark],
         color: Color, lineWidth: CGFloat) {
        self.faceObservations = faceObservations
        self.interestTypes = interestParts
        self.color = color
        self.lineWidth = lineWidth
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ForEach(faceObservations, id: \.uuid) { faceObservation in
                    ForEach(interestTypes, id: \.self) { type in
                        if let region = type.propRegion(faceObservation) {
                            FaceLandmark(region: region)
                                .stroke(lineWidth: lineWidth)
                                .foregroundStyle(color)
                        }
                    }
                }
            )
    }
}

extension View {
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, visionOS 2.0, *)
    public func visionRectangles<T: VisionObservation & BoundingBoxProviding>(_ faceObservations: [T], color: Color = .red) -> some View {
        self.modifier(BoundingBoxProvidingRectangles(faceObservations, color: color))
    }
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, visionOS 2.0, *)
    public func landmarkShapes(_ faceObservations: [FaceObservation], parts: [InteresetVisionFaceLandmark], color: Color = .red, lineWidth: CGFloat = 2) -> some View {
        self.modifier(LandmarkShapes(faceObservations, interestParts: parts, color: color, lineWidth: lineWidth))
    }

}

// from Apple
@available(macOS 15.0, iOS 18.0, tvOS 18.0, visionOS 2.0, *)
struct FaceLandmark: Shape {
    let region: FaceObservation.Landmarks2D.Region
    
    func path(in rect: CGRect) -> Path {
        let points = region.pointsInImageCoordinates(rect.size, origin: .upperLeft)
        let path = CGMutablePath()
        
        path.move(to: points[0])
        
        for index in 1..<points.count {
            path.addLine(to: points[index])
        }
        
        if region.pointsClassification == .closedPath {
            path.closeSubpath()
        }
        
        return Path(path)
    }
}
