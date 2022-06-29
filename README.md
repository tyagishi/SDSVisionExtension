# SDSVisionExtension

convenient extension for using Vision framework

## ViewModifiers

### show detected rectangles on SwiftUI view
```
extension View {
    public func detectRectangles(_ results: [VNDetectedObjectObservation],_ color: Color = Color.red, _ label: String = "") -> some View {
        self.modifier(VNDetectedObjectObservationIndicator(results, color, label))
    }
}
```

###  show detected face landmark (left-eye, right-eye) on SwiftUI view
```
extension View {
    public func detectedLeftRightEyes(_ faceObservations: [VNFaceObservation], _ color: Color = Color.green,
                               _ leftLabel: String = "",_ rightLabel: String = "") -> some View {
        self.modifier(VNFaceLandmarks(faceObservations, color, leftLabel, rightLabel))
    }
}
```
