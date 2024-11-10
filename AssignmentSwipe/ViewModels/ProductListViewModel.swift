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
    
    func toggleFavorite(for product: Product) {
        // Logic to toggle favorite and save locally (UserDefaults or Core Data)
    }
    
    func filteredProducts() -> [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.productName.contains(searchText) }
        }
    }
}

