//
//  File.swift
//
//  Created by : Tomoaki Yagishita on 2022/06/29
//  © 2022  SmallDeskSoftware
//

import Foundation
import Vision
import SDSCGExtension
import SDSViewExtension
import SwiftUI

// Note: origin in Vision  is lower-left
//       origin in SwiftUI is upper-left

extension VNDetectedObjectObservation {
    func unNormalizeRect(in imageSize: CGSize) -> CGRect {
        let rectSize = rectSize(in: imageSize)
        let originX = imageSize.width * self.boundingBox.originX
        let originY = imageSize.height * (1.0 - self.boundingBox.originY) - rectSize.height
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

// Note: origin in Vision  is lower-left
//       origin in SwiftUI is upper-left
struct VNDetectedObjectObservationIndicator: ViewModifier {
    var detectResults: [VNDetectedObjectObservation]
    let color: Color
    let label: String
    
    init(_ results: [VNDetectedObjectObservation],_ color: Color, _ label: String) {
        self.detectResults = results
        self.color = color
        self.label = label
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geom in
                    ForEach(detectResults, id: \.uuid) { result in
                        Rectangle()
                            .strokeBorder(lineWidth: 3)
                            .foregroundColor(color)
                            .frame(result.rectSize(in: geom.size))
                            .position(result.rectCenter(in: geom.size))
                        if label != "" {
                            Text(label)
                                .position(result.unNormalizeRect(in: geom.size).LUpoint().move(30, -10))
//                                .overlay(
//                                    GeometryReader { geom2 in
//                                        Text("Hello")
//                                            .debugPrint(geom2.size)
//                                    }
//                                )
                        }
                    }
                }
            )
    }
}

extension View {
    public func detectRectangles(_ results: [VNDetectedObjectObservation],_ color: Color = Color.red, _ label: String = "") -> some View {
        self.modifier(VNDetectedObjectObservationIndicator(results, color, label))
    }
}
