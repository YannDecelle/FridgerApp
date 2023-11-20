import SwiftUI

struct Product: Identifiable, Codable {
    var id = UUID()
    var name: String
    var price: String
    var quantity: String
    var imageURL: String
}

struct ContentView: View {
    @State private var products: [Product] = []

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            UserView()
                .tabItem {
                    Label("Add User", systemImage: "person.fill")
                }

            ProductListView(products: $products)
                .tabItem {
                    Label("Products", systemImage: "bag.fill")
                }

            AdminView()
                .tabItem {
                    Label("Manage", systemImage: "gearshape.fill")
                }
        }
        .accentColor(Color(.systemMint))
        .background(Rectangle().fill(Color(.systemBackground)).shadow(radius: 2))
    }
}

struct ProductListView: View {
    @Binding var products: [Product]

    var body: some View {
        NavigationView {
            List(products) { product in
                NavigationLink(destination: ProductDetail(product: product)) {
                    ProductCardView(product: product)
                }
            }
            .navigationBarTitle("Products")
        }
    }
}

struct ProductDetail: View {
    var product: Product

    var body: some View {
        VStack {
            Text(product.name)
            Text("Price: \(product.price)")
            Text("Quantity: \(product.quantity)")
            // Load the image from the URL asynchronously
            // For simplicity, I'm using a placeholder here
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 2))
        .padding()
        .navigationBarTitle("Product Detail")
    }
}

struct ProductCardView: View {
    var product: Product

    var body: some View {
        VStack {
            Text(product.name)
            Text("Price: \(product.price)")
            Text("Quantity: \(product.quantity)")
            // You may want to load the image from the URL asynchronously
            // For simplicity, I'm using a placeholder here
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 2))
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Dashboard")
        }
    }
}

struct UserView: View {
    var body: some View {
        VStack {
            Text("User")
        }
    }
}

struct AdminView: View {
    var body: some View {
        VStack {
            Text("Admin")
        }
    }
}
