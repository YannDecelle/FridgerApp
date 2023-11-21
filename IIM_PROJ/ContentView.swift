import SwiftUI
import CryptoKit

struct User: Identifiable {
    var id = UUID()
    var username: String
    var pincode: String
    var profileImage: Image?
}

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            UserView()
            .tabItem {
                Label("Users", systemImage: "person.fill")
            }

            NavigationView {
                ProductView()
            }
            .tabItem {
                Label("Products", systemImage: "bag.fill")
            }

            NavigationView {
                AdminView()
            }
            .tabItem {
                Label("Manage", systemImage: "gearshape.fill")
            }
        }
        .accentColor(Color(.systemMint))
        .background(Rectangle().fill(Color(.systemBackground)).shadow(radius: 2))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct UserView: View {
    @State private var isAddUserSheetPresented = false
    @State private var users: [User] = []

    var body: some View {
        NavigationView {
            VStack {
                Button("Add User") {
                    isAddUserSheetPresented.toggle()
                }
                List(users) { user in
                    UserCardView(user: user)
                }
            }
            .sheet(isPresented: $isAddUserSheetPresented) {
                AddUserView(users: $users, isPresented: $isAddUserSheetPresented)
            }
            .navigationBarTitle("Users")
        }
    }
}

struct AddUserView: View {
    @Binding var users: [User]
    @Binding var isPresented: Bool
    @State private var username = ""
    @State private var pincode = ""
    @State private var encryptedPincode = ""
    @State private var selectedImage: Image?
    @State private var isImagePickerPresented = false
    @State private var selectedUIImage: UIImage?
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Username", text: $username)
                    SecureField("Pincode", text: $pincode)
                }

                Section(header: Text("Profile Image")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedUIImage ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                isImagePickerPresented.toggle()
                            }
                    } else {
                        Button("Select Image") {
                            isImagePickerPresented.toggle()
                        }
                    }
                }

                Section {
                    Button("Save") {
                        if !username.isEmpty && !pincode.isEmpty {
                            // Encrypt the pincode before saving
                            encryptedPincode = encrypt(pincode)
                            let newUser = User(username: username, pincode: encryptedPincode, profileImage: selectedImage)
                            users.append(newUser)
                            username = ""
                            pincode = ""
                            encryptedPincode = ""
                            selectedImage = nil
                            isImagePickerPresented = false
                            isPresented.toggle()
                        } else {
                            showAlert = true
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Incomplete Fields"), message: Text("Please fill in all required fields."), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented, onDismiss: {
                if let selectedImage = selectedUIImage {
                    self.selectedImage = Image(uiImage: selectedImage)
                }
            }) {
                ImagePicker(selectedImage: $selectedUIImage)
            }
            .navigationTitle("Add User")
        }
    }

    // Encryption function using CryptoKit
    private func encrypt(_ plaintext: String) -> String {
        let data = Data(plaintext.utf8)
        do {
            let key = SymmetricKey(size: .bits256) // Example key size, choose an appropriate size for your use case
            let sealedBox = try AES.GCM.seal(data, using: key)
            return Data(sealedBox.ciphertext).base64EncodedString()
        } catch {
            print("Encryption error: \(error)")
            return ""
        }
    }
}

struct UserCardView: View {
    @State private var isEditUserSheetPresented = false

    var user: User

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
                // Hidden NavigationLink to trigger the sheet
                NavigationLink(
                    destination: EditUserView(user: user),
                    isActive: $isEditUserSheetPresented,
                    label: {
                    })
                    .hidden()

                // Edit Button
                Button(action: {
                    isEditUserSheetPresented.toggle()
                }) {
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 2))
        .padding(.horizontal)
    }
}



struct EditUserView: View {
    @State private var editedUsername: String
    @State private var editedPincode: String

    var user: User

    init(user: User) {
        self.user = user
        _editedUsername = State(initialValue: user.username)
        _editedPincode = State(initialValue: user.pincode)
    }

    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("Username", text: $editedUsername)
                SecureField("Pincode", text: $editedPincode)
            }

            // Additional sections for other user data if needed

            Section {
                Button("Save Changes") {
                    // Handle saving the edited user data
                    // Update the user in the main users array
                    // Dismiss the sheet
                }
            }
        }
        .navigationTitle("Edit User")
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct DashboardView: View {
    var body: some View {
        Text("Dashboard")
    }
}

struct ProductView: View {
    var body: some View {
        Text("Product")
    }
}

struct AdminView: View {
    var body: some View {
        Text("Admin")
    }
}
