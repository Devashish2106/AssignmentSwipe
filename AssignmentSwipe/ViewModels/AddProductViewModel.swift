//
//  AddProductViewModel.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI

class AddProductViewModel: ObservableObject {
    @Published var productName: String = ""
    @Published var productType: String = ""
    @Published var price: String = ""
    @Published var tax: String = ""
    @Published var image: UIImage?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isAddingProduct = false  // Track if the product is being added
    
    func addProduct(completion: @escaping () -> Void) {
        guard let price = Double(price), let tax = Double(tax) else {
            alertMessage = "Invalid price or tax format. Please enter a numeric value."
            showAlert = true
            return
        }
        
        isAddingProduct = true
        let newProduct = Product(image: nil, productName: productName, productType: productType, price: price, tax: tax)

        
        NetworkManager.shared.addProduct(product: newProduct) { success in
            DispatchQueue.main.async {
                self.isAddingProduct = false
                self.alertMessage = success ? "Product added successfully!" : "Failed to add product"
                self.showAlert = true
                if success {
                    completion()
                }
            }
        }
    }

}
