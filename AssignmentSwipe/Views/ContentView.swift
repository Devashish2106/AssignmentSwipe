import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ProductListViewModel()
    @State private var showAddProductScreen = false
    @State private var isFirstScreen = true  // Track whether to show the first screen

    var body: some View {
        NavigationView {
            VStack {
                if isFirstScreen {
                    // Show the first screen with demo image and label
                    FirstScreenView(isFirstScreen: $isFirstScreen)
                        .onAppear {
                            // Wait for 2 seconds before transitioning to the next screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isFirstScreen = false  // Transition to the main product list
                                }
                            }
                        }
                } else {
                    // Show the product list screen after the first screen
                    VStack {
                        TextField("Search products", text: $viewModel.searchText)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView("Loading...")
                        } else {
                            List(viewModel.filteredProducts()) { product in
                                HStack {
                                    // Product Image
                                    AsyncImage(url: URL(string: product.image ?? "")) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Image("demo") // Using "demo" as the default image
                                            .resizable()
                                    }
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                                    
                                    // Product Details
                                    VStack(alignment: .leading) {
                                        Text(product.productName).font(.headline)
                                        Text(product.productType).font(.subheadline)
                                        // Format price and tax with 2 decimal places and ₹ symbol
                                        Text("Price: ₹\(String(format: "%.2f", product.price))").font(.footnote)
                                        Text("Tax: ₹\(String(format: "%.2f", product.tax))").font(.footnote)
                                    }
                                    
                                    Spacer()
                                    
                                    // Heart Icon for Favorite
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            viewModel.toggleFavorite(for: product)
                                        }
                                    }) {
                                        Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(product.isFavorite ? .red : .gray)
                                    }
                                    .buttonStyle(BorderlessButtonStyle()) // Prevents button from affecting row selection
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: viewModel.products)
                        }

                        Button(action: { showAddProductScreen.toggle() }) {
                            Text("Add Product")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .navigationTitle("Product List")
                    .sheet(isPresented: $showAddProductScreen) {
                        AddProductView()
                    }
                }
            }
        }
    }
}

struct FirstScreenView: View {
    @Binding var isFirstScreen: Bool

    var body: some View {
        VStack {
            Spacer()

            // Demo Image
            Image("demo")  // Replace with the actual name of your demo image in the assets
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(Circle())  // Optional: To make it circular

            Spacer()

            Text("Devashish's iOS app")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 20)

            Spacer()
        }
        .padding()
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)  // Optional: To ignore the safe area and fill the screen
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
