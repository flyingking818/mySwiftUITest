//
//  ISeeFoodView.swift
//  mySwiftUITest
//
//  Created by Jeremy Wang on 4/21/25.
//

import SwiftUI
import CoreML
import Vision

struct ISeeFoodView: View {
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var classificationLabel: String = "Tap camera to select image"
    @State private var navBarColor: Color = .blue
    
    var body: some View {
        NavigationView {
            ZStack {
                navBarColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    if let image = inputImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Text(classificationLabel)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("I See Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "camera")
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $inputImage, onImagePicked: { image in
                    classifyImage(image)
                })
            }
        }
    }
    
    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to convert UIImage to CIImage")
            return
        }
        
        /*
         Inceptionv3
         
         Higher accuracy on some benchmarks.
         Slower, but better for server-side or high-end offline analysis.
         
         
         MobileNetV2
         Slightly lower accuracy (~71% vs. ~78% on ImageNet).
         Way more efficient for mobile and edge devices.
         Designed for live interaction & camera input
         
         */
        
        
        
        /* Use the older InceptionV3 model */
        /*
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            print("Failed to load CoreML model")
            return
        }
         */
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            print("Failed to load MobileNetV2 model")
            return
        }

        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                print("Unexpected results from CoreML request")
                return
            }
            
            print(results)
            
            DispatchQueue.main.async {
                if topResult.identifier.contains("hotdog") {
                    classificationLabel = "Hotdog!"
                    navBarColor = .green
                } else {
                    classificationLabel = topResult.identifier
                    navBarColor = .red
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Error performing classification: \(error)")
            }
        }
    }
}
