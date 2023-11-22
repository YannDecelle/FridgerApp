import SwiftUI

// Définition de la structure User conforme au protocole Identifiable
struct User: Identifiable {
    var id = UUID()
    var username: String
    var pincode: String
    var profileImage: Image?
}

// Classe UserManager conforme à ObservableObject pour gérer la liste des utilisateurs
class UserManager: ObservableObject {
    @Published var users: [User] = [] // Liste des utilisateurs

    // Fonction pour ajouter un utilisateur à la liste
    func addUser(username: String, pincode: String, profileImage: Image? = nil) {
        let newUser = User(username: username, pincode: pincode, profileImage: profileImage)
        users.append(newUser)
    }

    // Fonction pour éditer les détails d'un utilisateur
    func editUser(user: User, newUsername: String, newPincode: String, newProfileImage: Image?) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].username = newUsername
            users[index].pincode = newPincode
            users[index].profileImage = newProfileImage
        }
    }
}

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

// Vue pour ajouter un nouvel utilisateur
struct AddUserView: View {
    @ObservedObject var userManager: UserManager
    @Binding var isPresented: Bool
    @State private var username = ""
    @State private var pincode = ""
    @State private var selectedImage: Image?
    @State private var isImagePickerPresented = false
    @State private var showAlert = false

    // Corps de la vue
    var body: some View {
        NavigationView {
            Form {
                // Section pour les informations de l'utilisateur
                Section(header: Text("Informations de l'utilisateur")) {
                    TextField("Nom d'utilisateur", text: $username)
                    SecureField("Code PIN", text: $pincode)
                }

                // Section pour l'image de profil
                Section(header: Text("Image de profil")) {
                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                isImagePickerPresented.toggle()
                            }
                    } else {
                        Button("Sélectionner une image") {
                            isImagePickerPresented.toggle()
                        }
                    }
                }

                // Section pour le bouton de sauvegarde
                Section {
                    Button("Enregistrer") {
                        if username.isEmpty || pincode.isEmpty {
                            showAlert = true
                        } else {
                            userManager.addUser(username: username, pincode: pincode, profileImage: selectedImage)
                            username = ""
                            pincode = ""
                            selectedImage = nil
                            isImagePickerPresented = false
                            isPresented.toggle()
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Champs incomplets"), message: Text("Veuillez remplir tous les champs requis."), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .navigationTitle("Ajouter un utilisateur")
        }
    }
}

// Vue pour afficher les détails d'un utilisateur sous forme de carte
struct UserCardView: View {
    var user: User
    @State private var isEditUserSheetPresented = false
    var userManager: UserManager

    // Corps de la vue
    var body: some View {
        VStack {
            if let profileImage = user.profileImage {
                profileImage
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 100, height: 100)
            }

            Text(user.username)
            Text(user.pincode)

            HStack {
                NavigationLink(
                    destination: EditUserView(userManager: userManager, user: user, isPresented: $isEditUserSheetPresented),
                    isActive: $isEditUserSheetPresented
                ) {
                    EmptyView()
                }
                .hidden()

                Button(action: {
                    isEditUserSheetPresented.toggle()
                }) {
                    // Contenu du bouton d'édition ici
                }
                
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
        .padding(.horizontal)
    }
}

// Vue pour éditer les détails d'un utilisateur
// Vue pour éditer les détails d'un utilisateur
// Vue pour éditer les détails d'un utilisateur
struct EditUserView: View {
    @ObservedObject var userManager: UserManager
    @State private var editedUsername: String
    @State private var editedPincode: String
    @State private var selectedImage: Image?
    @State private var isImagePickerPresented = false
    @Binding var isPresented: Bool
    var user: User

    // Initialisateur avec des valeurs par défaut
    init(userManager: UserManager, user: User, isPresented: Binding<Bool>) {
        self.userManager = userManager
        self._editedUsername = State(initialValue: user.username)
        self._editedPincode = State(initialValue: user.pincode)
        self._isPresented = isPresented
        self.user = user

        // Set the selected image to the user's profile image
        self._selectedImage = State(initialValue: user.profileImage)
    }

    // Corps de la vue
    var body: some View {
        Form {
            // Section pour les informations de l'utilisateur
            Section(header: Text("Informations de l'utilisateur")) {
                TextField("Nom d'utilisateur", text: $editedUsername)
                SecureField("Code PIN", text: $editedPincode)
            }

            // Section pour l'image de profil
            Section(header: Text("Image de profil")) {
                if let selectedImage = selectedImage {
                    selectedImage
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                } else {
                    Button("Changer l'image") {
                        isImagePickerPresented.toggle()
                    }
                }
            }

            // Section pour les boutons d'action
            Section {
                VStack {
                    // Button to save modifications
                    Button("Enregistrer les modifications") {
                        let newUsername = editedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
                        let newPincode = editedPincode.trimmingCharacters(in: .whitespacesAndNewlines)

                        if !newUsername.isEmpty && !newPincode.isEmpty {
                            userManager.editUser(user: user, newUsername: newUsername, newPincode: newPincode, newProfileImage: selectedImage)
                            isPresented = false
                        }
                    }
                }
                
                Button(action: {
                    // Handle delete button action
                    userManager.users.removeAll { $0.id == user.id }
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        Text("Supprimer l'utilisateur")
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .navigationTitle("Modifier l'utilisateur")
    }
}




// Vue principale de l'application
struct ContentView: View {
    @StateObject var userManager = UserManager()
    @State private var isAddUserSheetPresented = false

    // Corps de la vue
    var body: some View {
        TabView {
            NavigationView {
                Text("Tableau de bord")
            }
            .tabItem {
                Label("Tableau de bord", systemImage: "chart.bar.fill")
            }

            NavigationView {
                List(userManager.users) { user in
                    UserCardView(user: user, userManager: userManager)
                }
                .navigationBarTitle("Utilisateurs")
                .navigationBarItems(trailing:
                    Button(action: {
                        isAddUserSheetPresented.toggle()
                    }) {
                        Label("Ajouter un utilisateur", systemImage: "person.badge.plus.fill")
                    }
                )
            }
            .tabItem {
                Label("Utilisateurs", systemImage: "person.fill")
            }

            NavigationView {
                Text("Produits")
            }
            .tabItem {
                Label("Produits", systemImage: "bag.fill")
            }

            NavigationView {
                Text("Gérer")
            }
            .tabItem {
                Label("Gérer", systemImage: "gearshape.fill")
            }
        }
        .accentColor(Color(.systemMint))
        .background(Rectangle().fill(Color(.systemBackground)).shadow(radius: 2))
        .sheet(isPresented: $isAddUserSheetPresented) {
            AddUserView(userManager: userManager, isPresented: $isAddUserSheetPresented)
        }
    }
}

// Structure de prévisualisation pour ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
