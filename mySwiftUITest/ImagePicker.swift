//
//  ImagePicker.swift
//  mySwiftUITest
//
//  Created by Jeremy Wang on 4/21/25.
//

import Foundation
import SwiftUI
import UIKit

/// A SwiftUI-compatible wrapper for `UIImagePickerController`, allowing image selection or capture from the camera.
/// This struct enables integration with SwiftUI by conforming to `UIViewControllerRepresentable`.
///  In SwiftUI, UIViewControllerRepresentable is a protocol that lets you wrap a UIKit UIViewController (like UIImagePickerController, UIActivityViewController, or MFMailComposeViewController) so it can be used inside SwiftUI views.
///  Think of it as a bridge that allows UIKit components to work seamlessly within SwiftUI.

struct ImagePicker: UIViewControllerRepresentable {
    
    /// A coordinator class to bridge UIKit delegate methods to SwiftUI.
    /// Acts as the delegate for `UIImagePickerController`.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        /// Initializes the Coordinator with a reference to its parent `ImagePicker`.
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        /// Called when the user selects or captures an image.
        /// - Parameters:
        ///   - picker: The image picker controller.
        ///   - info: A dictionary containing the selected image and metadata.
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage                   // Update the binding with the selected image.
                parent.onImagePicked(uiImage)            // Trigger the callback with the image.
            }
            picker.dismiss(animated: true)               // Close the image picker.
        }
        
        /// Called when the user cancels the image picking process.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    /// A binding to the selected image, updated after the user picks or captures a photo.
    @Binding var image: UIImage?
    
    /// A closure that gets called when an image is successfully picked.
    var onImagePicked: (UIImage) -> Void
    
    /// Creates a Coordinator instance to serve as delegate for the image picker.
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    /// Creates and configures the `UIImagePickerController` instance.
    /// - Parameter context: A context provided by SwiftUI.
    /// - Returns: A configured instance of `UIImagePickerController`.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator       // Assign the coordinator as the delegate.
        picker.sourceType = .camera                 // Set to .camera to allow photo capture.
        //picker.sourceType = .photoLibrary         // Here, you can switch to .photoLibrary for the simulator
        picker.allowsEditing = true                 // Allow users to crop/edit photos before selection.
        return picker
    }
    
    /// Updates the image picker controller when SwiftUI state changes (not used here).
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
