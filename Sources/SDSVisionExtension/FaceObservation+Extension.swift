//
//  File.swift
//  SDSVisionExtension
//
//  Created by Tomoaki Yagishita on 2025/01/25.
//

import Foundation
import Vision
import SwiftUI

@available(iOS 18, macOS 15, tvOS 18, *)
extension FaceObservation {
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

@available(iOS 18, macOS 15, tvOS 18, *)
struct FaceObservationRectangles: ViewModifier {
    var faceObservations: [FaceObservation]
    let color: Color

    init(_ faceObservations: [FaceObservation],_ color: Color = .red) {
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
extension View {
    @available(iOS 18, macOS 15, tvOS 18, *)
    public func faceRectangles(_ faceObservations: [FaceObservation]) -> some View {
        self.modifier(FaceObservationRectangles(faceObservations))
    }
}
