import SwiftUI

// Structure to represent Pokemon data
struct PokemonData: Decodable {
    let name: String
    let height: Int
    let weight: Int
    // Add more properties as needed
}

// Vue principale de l'application
struct ContentView: View {
    @StateObject var userManager = UserManager()
    @State private var isAddUserSheetPresented = false
    @StateObject var productManager = ProductManager()
    @State private var isAddProductSheetPresented = false
    @State private var selectedTab = 0
    @State private var pokemonName: String = ""
    @State private var pokemonData: PokemonData?

    // Body of the view
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                List(userManager.users) { user in
                    UserCardView(user: user, userManager: userManager, selectedTab: $selectedTab)
                }
            }
            .onAppear {
                checkSelectedTab(tabSelection: $selectedTab)
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(0)

            NavigationView {
                List(userManager.users) { user in
                    UserCardView(user: user, userManager: userManager, selectedTab: $selectedTab)
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
            .onAppear {
                checkSelectedTab(tabSelection: $selectedTab)
            }
            .tabItem {
                Label("Utilisateurs", systemImage: "person.fill")
            }
            .tag(1)
            
            NavigationView {
                List(productManager.products) { product in
                    ProductCardView(product: product, productManager: productManager)
                }
                .navigationBarTitle("Produits")
                .navigationBarItems(trailing:
                    Button(action: {
                        isAddProductSheetPresented.toggle()
                    }) {
                        Label("Ajouter un produit", systemImage: "bag.fill.badge.plus")
                    }
                )
            }
            .onAppear {
                checkSelectedTab(tabSelection: $selectedTab)
            }
            .tabItem {
                Label("Produits", systemImage: "bag.fill")
            }
            .tag(2)

            NavigationView {
                VStack {
                    TextField("Enter Pokemon Name", text: $pokemonName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        fetchPokemonData()
                    }) {
                        Text("Fetch Pokemon Data")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemMint))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()

                    if let pokemonData = pokemonData {
                        // Display the fetched data here as needed
                        Text("Pokemon Name: \(pokemonData.name)")
                        Text("Height: \(pokemonData.height)")
                        Text("Weight: \(pokemonData.weight)")
                        // Add more details as needed
                    } else {
                        // Display a message when no data is fetched yet
                        Text("No data fetched")
                    }
                }
                .navigationBarTitle("Gérer")
            }
            .onAppear {
                checkSelectedTab(tabSelection: $selectedTab)
            }
            .tabItem {
                Label("Gérer", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .accentColor(Color(.systemMint))
        .background(Rectangle().fill(Color(.systemBackground)).shadow(radius: 2))
        .sheet(isPresented: $isAddUserSheetPresented) {
            AddUserView(userManager: userManager, isPresented: $isAddUserSheetPresented)
        }
        .sheet(isPresented: $isAddProductSheetPresented) {
            AddProductView(productManager: productManager, isPresented: $isAddProductSheetPresented)
        }
    }

    // Function to fetch Pokemon data
    func fetchPokemonData() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonName.lowercased())") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(PokemonData.self, from: data)
                    DispatchQueue.main.async {
                        self.pokemonData = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

// Structure de Prévisualisation pour ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
