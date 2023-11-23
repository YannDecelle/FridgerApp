import SwiftUI
import CryptoKit

class User: Identifiable {
    var id = UUID()
    var username: String
    var pincode: String
    var profileImage: Image?

    init(username: String, pincode: String, profileImage: Image? = nil) {
        self.username = username
        self.pincode = pincode
        self.profileImage = profileImage
    }
}

class UserManager: ObservableObject {
    @Published var users: [User] = []

    func addUser(username: String, pincode: String, profileImage: Image?) {
        let encryptedPincode = EncryptionManager.encrypt(pincode)
        let newUser = User(username: username, pincode: encryptedPincode, profileImage: profileImage)
        users.append(newUser)
    }

    func editUser(user: User, newUsername: String, newPincode: String) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].username = newUsername
            users[index].pincode = EncryptionManager.encrypt(newPincode)
        }
    }
}

class EncryptionManager {
    static func encrypt(_ plaintext: String) -> String {
        let data = Data(plaintext.utf8)
        do {
            let key = SymmetricKey(size: .bits256)
            let sealedBox = try AES.GCM.seal(data, using: key)
            return Data(sealedBox.ciphertext).base64EncodedString()
        } catch {
            print("Encryption error: \(error)")
            return ""
        }
    }
}

protocol ImagePickerCoordinatorProtocol {
    var parent: any ImagePicker { get }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
}

class ImagePickerCoordinator: NSObject, ImagePickerCoordinatorProtocol, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: any ImagePicker

    init(parent: any ImagePicker) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let uiImage = info[.originalImage] as? UIImage {
            parent.selectedImage = Image(uiImage: uiImage)
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

protocol ImagePicker: UIViewControllerRepresentable {
    var selectedImage: Image? { get set }
    func makeCoordinator() -> ImagePickerCoordinator
}

extension ImagePicker {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIImagePickerController()
        controller.delegate = (context.coordinator as! any UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

protocol UserViewProtocol: View {
    var userManager: UserManager { get }
}

struct AddUserView: UserViewProtocol {
    @ObservedObject var userManager: UserManager
    @Binding var isPresented: Bool
    @State private var username = ""
    @State private var pincode = ""
    @State private var selectedImage: Image?
    @State private var isImagePickerPresented = false
    @State private var selectedUIImage: UIImage?
    @State private var showAlert = false
    @State private var encryptedPincode = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Username", text: $username)
                    SecureField("Pincode", text: $pincode)
                }

                Section(header: Text("Profile Image")) {
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
                        Button("Select Image") {
                            isImagePickerPresented.toggle()
                        }
                    }
                }

                Section {
                    Button("Save") {
                        if !username.isEmpty && !pincode.isEmpty {
                            encryptedPincode = EncryptionManager.encrypt(pincode)
                            userManager.addUser(username: username, pincode: encryptedPincode, profileImage: selectedImage)
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
            }
            .navigationTitle("Add User")
        }
    }
}

struct UserCardView: View {
    var user: User
    @State private var isEditUserSheetPresented = false
    var userManager: UserManager

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
                    destination: EditUserView( userManager: userManager, user: user, isPresented: $isEditUserSheetPresented),
                    isActive: $isEditUserSheetPresented
                ) {
                    EmptyView()
                }
                .hidden()

                Button(action: {
                    isEditUserSheetPresented.toggle()
                }) {
                    // Your edit button content here
                }

            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
        .padding(.horizontal)
    }
}

struct EditUserView: View {
    @ObservedObject var userManager: UserManager
    @State private var editedUsername: String
    @State private var editedPincode: String
    @Binding var isPresented: Bool
    var user: User

    init(userManager: UserManager, user: User, isPresented: Binding<Bool>) {
        self.userManager = userManager
        self._editedUsername = State(initialValue: user.username)
        self._editedPincode = State(initialValue: user.pincode)
        self._isPresented = isPresented
        self.user = user
    }

    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("Username", text: $editedUsername)
                SecureField("Pincode", text: $editedPincode)
            }

            Section {
                Button("Save Changes") {
                    let newUsername = editedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
                    let newPincode = editedPincode.trimmingCharacters(in: .whitespacesAndNewlines)

                    if !newUsername.isEmpty && !newPincode.isEmpty {
                        userManager.editUser(user: user, newUsername: newUsername, newPincode: EncryptionManager.encrypt(newPincode))
                        // Dismiss the sheet
                        isPresented = false
                    }
                }
            }
        }
        .navigationTitle("Edit User")
    }
}


struct ContentView: View {
    @StateObject var userManager = UserManager()
    @State private var isAddUserSheetPresented = false

    var body: some View {
        TabView {
            NavigationView {
                Text("Dashboard")
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }

            NavigationView {
                List(userManager.users) { user in
                    UserCardView(user: user, userManager: userManager)
                }
                .navigationBarTitle("Users")
                .navigationBarItems(trailing:
                    Button(action: {
                        isAddUserSheetPresented.toggle()
                    }) {
                        Label("Add User", systemImage: "person.badge.plus.fill")
                    }
                )
            }
            .tabItem {
                Label("Users", systemImage: "person.fill")
            }

            NavigationView {
                Text("Products")
            }
            .tabItem {
                Label("Products", systemImage: "bag.fill")
            }

            NavigationView {
                Text("Manage")
            }
            .tabItem {
                Label("Manage", systemImage: "gearshape.fill")
            }
        }
        .accentColor(Color(.systemMint))
        .background(Rectangle().fill(Color(.systemBackground)).shadow(radius: 2))
        .sheet(isPresented: $isAddUserSheetPresented) {
            AddUserView(userManager: userManager, isPresented: $isAddUserSheetPresented)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
