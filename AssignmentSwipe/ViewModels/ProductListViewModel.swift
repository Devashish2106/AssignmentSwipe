//
//  ProductListViewModel.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        fetchProducts()
    }
    
    func fetchProducts() {
        isLoading = true
        NetworkManager.shared.fetchProducts { [weak self] products in
            DispatchQueue.main.async {
                self?.products = products ?? []
                self?.isLoading = false
            }
        }
    }
    
    // New async function for pull-to-refresh
    @MainActor
    func refreshProducts() async {
        isLoading = true
        await withCheckedContinuation { continuation in
            NetworkManager.shared.fetchProducts { [weak self] products in
                DispatchQueue.main.async {
                    self?.products = products ?? []
                    self?.isLoading = false
                    continuation.resume()
                }
            }
        }
    }
    
    func toggleFavorite(for product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].isFavorite.toggle()
            // Sort products to move favorites to the top
            products.sort { $0.isFavorite && !$1.isFavorite }
        }
    }
    
    func filteredProducts() -> [Product] {
        products.filter {
            searchText.isEmpty || $0.productName.localizedCaseInsensitiveContains(searchText)
        }
    }
}
