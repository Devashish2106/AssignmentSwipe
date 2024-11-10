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
    @Published var selectedImage: UIImage?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isAddingProduct = false
    
    private func validateInputs() -> Bool {
        // Check if product name is empty
        guard !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter a product name"
            showAlert = true
            return false
        }
        
        // Check if product type is empty
        guard !productType.isEmpty else {
            alertMessage = "Please select a product type"
            showAlert = true
            return false
        }
        
        // Validate price
        guard let priceValue = Double(price), priceValue > 0 else {
            alertMessage = "Please enter a valid price"
            showAlert = true
            return false
        }
        
        // Validate tax
        guard let taxValue = Double(tax), taxValue >= 0 else {
            alertMessage = "Please enter a valid tax rate"
            showAlert = true
            return false
        }
        
        return true
    }
    
    func addProduct(completion: @escaping () -> Void) {
        guard validateInputs() else { return }
        
        isAddingProduct = true
        
        let priceValue = Double(price) ?? 0
        let taxValue = Double(tax) ?? 0
        
        let newProduct = Product(
            image: nil,
            productName: productName.trimmingCharacters(in: .whitespacesAndNewlines),
            productType: productType,
            price: priceValue,
            tax: taxValue
        )
        
        // Pass the selected image to NetworkManager
        NetworkManager.shared.addProduct(product: newProduct, image: selectedImage) { [weak self] success, imageUrl in
            DispatchQueue.main.async {
                self?.isAddingProduct = false
                if success {
                    self?.alertMessage = "Product added successfully!"
                    completion()
                } else {
                    self?.alertMessage = "Failed to add product. Please try again."
                }
                self?.showAlert = true
            }
        }
    }
}
