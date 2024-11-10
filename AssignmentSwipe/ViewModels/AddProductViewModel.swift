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
    
    func addProduct() {
        guard let price = Double(price), let tax = Double(tax) else {
            alertMessage = "Invalid price or tax"
            showAlert = true
            return
        }
        
        let newProduct = Product(image: nil, productName: productName, productType: productType, price: price, tax: tax)
        NetworkManager.shared.addProduct(product: newProduct) { success in
            DispatchQueue.main.async {
                self.alertMessage = success ? "Product added successfully!" : "Failed to add product"
                self.showAlert = true
            }
        }
    }
}

