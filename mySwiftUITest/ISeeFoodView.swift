//
//  ISeeFoodView.swift
//  mySwiftUITest
//
//  Created by Jeremy Wang on 4/21/25.
//

import SwiftUI
import CoreML
import Vision

/// A SwiftUI View that uses CoreML and Vision to classify food images using the MobileNetV2 model.
struct ISeeFoodView: View {
    /// Tracks whether the image picker sheet is visible.
    @State private var showImagePicker = false
    
    /// Stores the selected image from the photo picker.
    @State private var inputImage: UIImage?
    
    /// Text label that shows the classification result.
    @State private var classificationLabel: String = "Tap camera to select image"
    
    /// Changes background color based on classification result.
    @State private var navBarColor: Color = .blue
    
    var body: some View {
        NavigationView {
            ZStack {
                navBarColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Display selected image
                    if let image = inputImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Display classification result
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
                // Camera button to trigger image picker
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
            // Present the image picker as a modal sheet
            // A modal sheet is a user interface element that slides up from the bottom of the screen and appears on top of the current view.
            .sheet(isPresented: $showImagePicker) {
                //This tells SwiftUI to present a sheet when the showImagePicker state variable is true. The sheet will disappear automatically when showImagePicker is set to false.
                ImagePicker(image: $inputImage, onImagePicked: { image in
                    classifyImage(image)
                })
            }
        }
    }
    
    /// Classifies the selected image using MobileNetV2 CoreML model and updates the UI accordingly.
    
    /* CIImage is Core Image’s native format — ideal for:
    Applying filters (e.g., grayscale, blur, contrast)
    Cropping, resizing, color space management
    Chain-processing multiple transformations efficiently
    This makes it more precise and GPU-friendly than using raw UIImage data.
     */
    
    
    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to convert UIImage to CIImage")
            return
        }
        
        
        
        /*
         /* Use the older InceptionV3 model */
         guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
         print("Failed to load CoreML model")
         return
         }
         */
        
        // Load Resnet50 model
        // https://github.com/ytakzk/CoreML-samples/blob/master/CoreML-samples/Resnet50.mlmodel
        /*
         guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
         print("Failed to load MobileNetV2 model")
         return
         }
         */
        
        
        // Load MobileNetV2
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            print("Failed to load MobileNetV2 model")
            return
        }
        
        
        // Create a request to classify the image
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                print("Unexpected results from CoreML request")
                return
            }
            
            DispatchQueue.main.async {
                // Example of hard-coded "Hotdog!" classification logic
                if topResult.identifier.contains("hotdog") {
                    classificationLabel = "Hotdog!"
                    navBarColor = .green
                } else {
                    classificationLabel = topResult.identifier
                    navBarColor = .red
                }
            }
        }
        
        // Perform the classification on a background thread
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
