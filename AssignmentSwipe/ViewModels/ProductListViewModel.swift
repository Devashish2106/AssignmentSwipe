//
//  ProductListViewModel.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI
import CoreData
import Combine

class ProductListViewModel: NSObject, ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    private let viewContext = PersistenceController.shared.container.viewContext
    private var fetchedResultsController: NSFetchedResultsController<ProductEntity>
    @ObservedObject private var networkMonitor = NetworkMonitor()
    
    override init() {
        // Initialize FetchedResultsController with animation-friendly configuration
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ProductEntity.isFavorite, ascending: false),
            NSSortDescriptor(keyPath: \ProductEntity.createdAt, ascending: false)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        loadLocalProducts()
        
        if networkMonitor.isConnected {
            fetchProducts()
        }
    }
    
    private func loadLocalProducts() {
        do {
            try fetchedResultsController.performFetch()
            updateProductsFromFetchedResults()
        } catch {
            print("Error fetching local products: \(error)")
        }
    }
    
    private func updateProductsFromFetchedResults() {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return }
        
        // Update products with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            self.products = fetchedObjects.map { entity in
                Product(
                    image: entity.imageUrl,
                    productName: entity.productName ?? "",
                    productType: entity.productType ?? "",
                    price: entity.price,
                    tax: entity.tax,
                    isFavorite: entity.isFavorite
                )
            }
        }
    }
    
    func fetchProducts() {
        isLoading = true
        NetworkManager.shared.fetchProducts { [weak self] products in
            DispatchQueue.main.async {
                if let products = products {
                    self?.updateLocalProducts(with: products)
                }
                self?.isLoading = false
            }
        }
    }
    
    @MainActor
    func refreshProducts() async {
        fetchProducts()
    }
    
    private func updateLocalProducts(with products: [Product]) {
        viewContext.perform {
            // Only update products that aren't pending upload
            let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "needsUpload == NO")
            
            do {
                let existingProducts = try self.viewContext.fetch(fetchRequest)
                for product in existingProducts {
                    self.viewContext.delete(product)
                }
                
                for product in products {
                    let entity = ProductEntity(context: self.viewContext)
                    entity.id = UUID()
                    entity.productName = product.productName
                    entity.productType = product.productType
                    entity.price = product.price
                    entity.tax = product.tax
                    entity.imageUrl = product.image
                    entity.isFavorite = product.isFavorite
                    entity.needsUpload = false
                    entity.createdAt = Date()
                }
                
                try self.viewContext.save()
            } catch {
                print("Error updating local products: \(error)")
            }
        }
    }
    
    func toggleFavorite(for product: Product) {
        viewContext.perform {
            let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "productName == %@ AND productType == %@",
                                               product.productName, product.productType)
            
            do {
                if let entity = try self.viewContext.fetch(fetchRequest).first {
                    // Wrap the changes in a transaction for better animation handling
                    withAnimation(.easeInOut(duration: 0.3)) {
                        entity.isFavorite.toggle()
                        
                        // Ensure proper ordering by updating the timestamp
                        if entity.isFavorite {
                            entity.createdAt = Date()
                        }
                        
                        try? self.viewContext.save()
                        
                        // Force refresh the UI with animation
                        DispatchQueue.main.async {
                            self.updateProductsFromFetchedResults()
                        }
                    }
                }
            } catch {
                print("Error updating favorite status: \(error)")
            }
        }
    }
    
    func filteredProducts() -> [Product] {
        if searchText.isEmpty {
            return products
        }
        return products.filter { $0.productName.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ProductListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateProductsFromFetchedResults()
    }
}
