//
//  ContentView.swift
//  part-2
//
//  Created by Moulya on 4/11/25.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var predictions: [(String, Double)] = []

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)

                Button("MobileNetV2") {
                    classifyImage(modelName: "MobileNetV2")
                }

                Button("ResNet50") {
                    classifyImage(modelName: "Resnet50")
                }

                Button("FastViT") {
                    classifyImage(modelName: "FastViT")
                }

                List(predictions, id: \.0) { result in
                    Text("\(result.0): \(String(format: "%.2f", result.1 * 100))%")
                }
            } else {
                Text("Select an image")
                    .padding()
            }

            Button("Pick Image") {
                showImagePicker = true
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }

    func classifyImage(modelName: String) {
        guard let image = selectedImage,
              let ciImage = CIImage(image: image) else {
            return
        }

        predictions = []

        let config = MLModelConfiguration()
        let model: VNCoreMLModel

        do {
            switch modelName {
            case "MobileNetV2":
                model = try VNCoreMLModel(for: MobileNetV2(configuration: config).model)
            case "Resnet50":
                model = try VNCoreMLModel(for: Resnet50(configuration: config).model)
            case "FastViT":
                model = try VNCoreMLModel(for: FastViTMA36F16(configuration: config).model)
            default:
                return
            }

            let request = VNCoreMLRequest(model: model) { request, _ in
                if let results = request.results as? [VNClassificationObservation] {
                    self.predictions = results.prefix(5).map { ($0.identifier, Double($0.confidence)) }
                }
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])

        } catch {
            print("Failed to classify image: \(error)")
        }
    }
}
