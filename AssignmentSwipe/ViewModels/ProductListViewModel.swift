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
    @Published var hasInitiallyLoaded: Bool = false
    
    private let viewContext = PersistenceController.shared.container.viewContext
    private var fetchedResultsController: NSFetchedResultsController<ProductEntity>
    @ObservedObject private var networkMonitor = NetworkMonitor()
    
    override init() {
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
        
        // Always fetch products on init, regardless of network status
        fetchProducts()
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
        
        DispatchQueue.main.async {
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
    }
    
    func fetchProducts() {
        isLoading = true
        NetworkManager.shared.fetchProducts { [weak self] products in
            DispatchQueue.main.async {
                if let products = products {
                    self?.updateLocalProducts(with: products)
                }
                self?.isLoading = false
                self?.hasInitiallyLoaded = true
            }
        }
    }
    
    private func updateLocalProducts(with products: [Product]) {
        viewContext.perform {
            // Create a map of existing products with their favorite status
            let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            var existingProductsMap: [String: Bool] = [:]
            
            do {
                let existingProducts = try self.viewContext.fetch(fetchRequest)
                for product in existingProducts {
                    if let name = product.productName, let type = product.productType {
                        let key = "\(name)_\(type)"
                        existingProductsMap[key] = product.isFavorite
                    }
                    
                    if !product.needsUpload {
                        self.viewContext.delete(product)
                    }
                }
                
                for product in products {
                    let key = "\(product.productName)_\(product.productType)"
                    let entity = ProductEntity(context: self.viewContext)
                    entity.id = UUID()
                    entity.productName = product.productName
                    entity.productType = product.productType
                    entity.price = product.price
                    entity.tax = product.tax
                    entity.imageUrl = product.image
                    entity.isFavorite = existingProductsMap[key] ?? false
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
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        entity.isFavorite.toggle()
                        
                        if entity.isFavorite {
                            entity.createdAt = Date()
                        }
                        
                        try? self.viewContext.save()
                        
//                        Refresh UI
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

extension ProductListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateProductsFromFetchedResults()
    }
}
