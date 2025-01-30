# SDSVisionExtension

convenient extension for using Vision framework

## ViewModifiers

### .visionRectangles : show detected rectangles on SwiftUI View
pass FaceObservation or HumanObservation to view modifier .visionRectangles (iff necessary, pass Color as well)

```
struct ContentView: View {
    @State var imageName = "Child01"
    
    @State var faces: [FaceObservation] = []
    @State var humans: [HumanObservation] = []
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable().scaledToFit()
                .visionRectangles(faces)
                .visionRectangles(humans, color: .blue)
                .frame(height: 600)
            HStack {
                Button(action: {
                    Task { @MainActor in
                        try await detectFaces()
                    }
                    
                }, label: { Text("Detect Face") })
                Button(action: {
                    Task { @MainActor in
                        try await detectHumans()
                    }
                    
                }, label: { Text("Detect Humans") })
            }
        }
        .padding()
    }

    var imageCGImage: CGImage? {
        // prep CGImage for image analysis
        return NSUIImage(named: imageName)?.toCGImage
    }
    
    func detectFaces() async throws {
        let detectFaceRequest = DetectFaceRectanglesRequest()
        guard let cgImage = imageCGImage else { return }

        let handler = ImageRequestHandler(cgImage)
        
        let faceObservations = try await handler.perform(detectFaceRequest)
        
        faces = faceObservations
    }
    
    func detectHumans() async throws {
        var detectRequest = DetectHumanRectanglesRequest()
        detectRequest.upperBodyOnly = upperBodyOnly
        guard let cgImage = imageCGImage else { return }

        let handler = ImageRequestHandler(cgImage)
        
        let humanObservations = try await handler.perform(detectRequest)
        
        humans = humanObservations
    }
}

```

### landmarkShapes
view modifier for result from DetectFaceLandmarksRequest()


## for older Vision APIs which starts with VN
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
