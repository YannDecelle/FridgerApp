import SwiftUI

struct Product: Identifiable {
    var id = UUID()
    var productName: String
    var productPrice: Int
    var productImage: Image?
}

// Classe ProductManager conforme à ObservableObject pour gérer la liste des produits
class ProductManager: ObservableObject {
    @Published var products: [Product] = [] // Liste des produits

    // Fonction pour ajouter un produit à la liste
    func addProduct(productName: String, productPrice: Int, productImage: Image? = nil) {
        let newProduct = Product(productName: productName, productPrice: productPrice, productImage: productImage)
        products.append(newProduct)
    }

    // Fonction pour éditer les détails d'un produit
    func editProduct(product: Product, newProductName: String, newProductPrice: Int, newProductImage: Image?) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].productName = newProductName
            products[index].productPrice = newProductPrice
            products[index].productImage = newProductImage
        }
    }
}

// Vue pour ajouter un nouveau produit
struct AddProductView: View {
    @ObservedObject var productManager: ProductManager
    @Binding var isPresented: Bool
    @State private var productName = ""
    @State private var productPrice = 0
    @State private var selectedImage: Image?
    @State private var isImagePickerPresented = false
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            Form {
                // Section pour les informations du produit
                Section(header: Text("Informations du produit")) {
                    TextField("Nom du produit", text: $productName)
                    TextField("Prix", value: $productPrice, formatter: NumberFormatter())
                        .keyboardType(.numberPad)

                }

                // Section pour l'image du produit
                Section(header: Text("Image du produit")) {
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
                        if productName.isEmpty {
                            showAlert = true
                        } else {
                            productManager.addProduct(productName: productName, productPrice: productPrice, productImage: selectedImage)
                            productName = ""
                            productPrice = 0
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
            .navigationTitle("Ajouter un produit")
        }
    }
}

// Vue pour afficher les détails d'un produit sous forme de carte
struct ProductCardView: View {
    var product: Product
    @State private var isEditProductSheetPresented = false
    var productManager: ProductManager

    var body: some View {
        VStack {
            if let productImage = product.productImage {
                productImage
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 100, height: 100)
            }

            Text(product.productName)
            Text("Prix: \(product.productPrice) €")

            HStack {
                NavigationLink(
                    destination: EditProductView(productManager: productManager, product: product, isPresented: $isEditProductSheetPresented),
                    isActive: $isEditProductSheetPresented
                ) {
                    EmptyView()
                }
                .hidden()

                Button(action: {
                    isEditProductSheetPresented.toggle()
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

// Vue pour éditer les détails d'un produit
struct EditProductView: View {
    @ObservedObject var productManager: ProductManager
    @State private var editedProductName: String
    @State private var editedProductPrice: Int
    @State private var selectedImage: Image?
    @State private var isImagePickerPresented = false
    @Binding var isPresented: Bool
    var product: Product

    init(productManager: ProductManager, product: Product, isPresented: Binding<Bool>) {
        self.productManager = productManager
        self._editedProductName = State(initialValue: product.productName)
        self._editedProductPrice = State(initialValue: product.productPrice)
        self._isPresented = isPresented
        self.product = product

        self._selectedImage = State(initialValue: product.productImage)
    }

    var body: some View {
        Form {
            // Section pour les informations du produit
            Section(header: Text("Informations du produit")) {
                TextField("Nom du produit", text: $editedProductName)
                TextField("Prix", value: $editedProductPrice, formatter: NumberFormatter())
                    .keyboardType(.numberPad)

            }

            // Section pour l'image du produit
            Section(header: Text("Image du produit")) {
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
                    // Bouton pour sauvegarder les modifications
                    Button("Enregistrer les modifications") {
                        let newProductName = editedProductName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !newProductName.isEmpty {
                            productManager.editProduct(product: product, newProductName: newProductName, newProductPrice: editedProductPrice, newProductImage: selectedImage)
                            isPresented = false
                        }
                    }
                }

                // Bouton pour supprimer le produit
                Button(action: {
                    productManager.products.removeAll { $0.id == product.id }
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        Text("Supprimer le produit")
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .navigationTitle("Modifier le produit")
    }
}

