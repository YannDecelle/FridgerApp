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
    @State private var isInventorySheetPresented = false
    var userManager: UserManager
    var selectedTab: Binding<Int>

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
                    if selectedTab.wrappedValue == 1 {
                        isEditUserSheetPresented.toggle()
                    } else if selectedTab.wrappedValue == 0 {
                        isInventorySheetPresented.toggle()
                    }
                }) {
                    EmptyView()
                }
                .sheet(isPresented: $isInventorySheetPresented) {
                    // Add the content you want to show when isInventorySheetPresented is true
                    UserInventoryView(user: user)
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
