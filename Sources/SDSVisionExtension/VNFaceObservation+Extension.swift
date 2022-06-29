//
//  File.swift
//
//  Created by : Tomoaki Yagishita on 2022/06/29
//  © 2022  SmallDeskSoftware
//

import Foundation
import Vision
import SwiftUI
import SDSCGExtension

// Note: origin in Vision  is lower-left
//       origin in SwiftUI is upper-left
extension VNFaceObservation {
    public func averagePoint(_ landmarkRegion2D: VNFaceLandmarkRegion2D) -> CGPoint {
        let sumPoint = landmarkRegion2D.normalizedPoints.reduce(CGPoint.zero) { (result, new) -> CGPoint in
            return CGPoint(x: result.x + new.x, y: result.y + new.y)
        }
        return sumPoint.scale(1.0 / CGFloat(landmarkRegion2D.normalizedPoints.count))
    }
    
    public func leftRightEyes() -> (left: CGPoint?, right: CGPoint?) {
        var left:CGPoint? = nil
        if let leftEye = self.landmarks?.leftEye {
            left = self.averagePoint(leftEye)
        }
        var right:CGPoint? = nil
        if let rightEye = self.landmarks?.rightEye {
            right = self.averagePoint(rightEye)
        }
        return (left, right)
    }
}

struct VNFaceLandmarks: ViewModifier {
    var faceObservations: [VNFaceObservation]
    let color: Color
    let leftLabel: String
    let rightLabel: String

    init(_ faceObservations:[VNFaceObservation],_ color: Color, _ leftLabel: String, _ rightLabel: String) {
        self.faceObservations = faceObservations
        self.color = color
        self.leftLabel = leftLabel
        self.rightLabel = rightLabel
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geom in
                    ForEach(faceObservations, id: \.uuid) { faceObservation in
                        let (right, left) = faceObservation.leftRightEyes()
                        if let left = left {
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundColor(color)
                                .position(faceObservation.pointInDetectRect(geom.size, left))
                            if leftLabel != "" {
                                Text(leftLabel)
                                    .position(faceObservation.pointInDetectRect(geom.size, left).move(0, -10))
                            }
                        }
                        if let right = right {
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundColor(color)
                                .position(faceObservation.pointInDetectRect(geom.size, right))
                            if rightLabel != "" {
                                Text(rightLabel)
                                    .position(faceObservation.pointInDetectRect(geom.size, right).move(0, -10))
                            }
                        }

                    }
                }
            )
    }
}

extension View {
    public func detectedLeftRightEyes(_ faceObservations: [VNFaceObservation], _ color: Color = Color.green,
                               _ leftLabel: String = "",_ rightLabel: String = "") -> some View {
        self.modifier(VNFaceLandmarks(faceObservations, color, leftLabel, rightLabel))
    }
}
