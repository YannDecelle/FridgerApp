import SwiftUI

// Structure ImagePicker conforme à UIViewControllerRepresentable pour la sélection d'images
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: Image?

    // Classe Coordinator pour gérer les interactions avec le UIImagePickerController
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        // Fonction appelée lors de la sélection d'une image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = Image(uiImage: uiImage)
            }

            picker.dismiss(animated: true)
        }

        // Fonction appelée lors de l'annulation de la sélection d'image
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    // Fonction pour créer un coordinateur
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // Fonction pour créer et renvoyer le UIImagePickerController
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        return controller
    }

    // Fonction appelée lors de la mise à jour de l'interface utilisateur
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
