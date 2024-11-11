//
//  AddProductViewModel.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI

import SwiftUI
import CoreData

class AddProductViewModel: ObservableObject {
    @Published var productName: String = ""
    @Published var productType: String = ""
    @Published var price: String = ""
    @Published var tax: String = ""
    @Published var selectedImage: UIImage?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isAddingProduct = false
    
    private let viewContext = PersistenceController.shared.container.viewContext
    @ObservedObject private var networkMonitor = NetworkMonitor()
    
    private func validateInputs() -> Bool {
        guard !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter a product name"
            showAlert = true
            return false
        }
        
        guard !productType.isEmpty else {
            alertMessage = "Please select a product type"
            showAlert = true
            return false
        }
        
        guard let priceValue = Double(price), priceValue > 0 else {
            alertMessage = "Please enter a valid price"
            showAlert = true
            return false
        }
        
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
        
        // Create CoreData entity
        let newProductEntity = ProductEntity(context: viewContext)
        newProductEntity.id = UUID()
        newProductEntity.productName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        newProductEntity.productType = productType
        newProductEntity.price = priceValue
        newProductEntity.tax = taxValue
        newProductEntity.createdAt = Date()
        newProductEntity.isFavorite = false
        newProductEntity.needsUpload = true
        
        if let image = selectedImage {
            newProductEntity.imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        do {
            try viewContext.save()
            
            if networkMonitor.isConnected {
                uploadProduct(newProductEntity) { [weak self] in
                    self?.isAddingProduct = false
                    completion()
                }
            } else {
                isAddingProduct = false
                alertMessage = "Product saved locally. Will sync when online."
                showAlert = true
                completion()
            }
        } catch {
            isAddingProduct = false
            alertMessage = "Failed to save product locally"
            showAlert = true
        }
    }
    
    private func uploadProduct(_ productEntity: ProductEntity, completion: @escaping () -> Void) {
        let product = Product(
            image: productEntity.imageUrl,
            productName: productEntity.productName ?? "",
            productType: productEntity.productType ?? "",
            price: productEntity.price,
            tax: productEntity.tax
        )
        
        var imageToUpload: UIImage?
        if let imageData = productEntity.imageData {
            imageToUpload = UIImage(data: imageData)
        }
        
        NetworkManager.shared.addProduct(product: product, image: imageToUpload) { success, imageUrl in
            DispatchQueue.main.async {
                if success {
                    productEntity.needsUpload = false
                    productEntity.imageUrl = imageUrl
                    try? self.viewContext.save()
                    self.alertMessage = "Product added successfully!"
                } else {
                    self.alertMessage = "Product saved locally. Will sync when online."
                }
                self.showAlert = true
                completion()
            }
        }
    }
}
