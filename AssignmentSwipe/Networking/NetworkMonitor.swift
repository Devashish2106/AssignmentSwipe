//
//  NetworkMonitor.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 11/11/24.
//

import Foundation
import Network
import Combine
import CoreData
import UIKit

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if self?.isConnected == true {
                    self?.syncPendingProducts()
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func syncPendingProducts() {
//        Function to send request if any pending after device is connected to network
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "needsUpload == YES")
        
        do {
            let pendingProducts = try context.fetch(fetchRequest)
            for product in pendingProducts {
                uploadProduct(product)
            }
        } catch {
            print("Error fetching pending products: \(error)")
        }
    }
    
    private func uploadProduct(_ product: ProductEntity) {
        let uploadProduct = Product(
            image: product.imageUrl,
            productName: product.productName ?? "",
            productType: product.productType ?? "",
            price: product.price,
            tax: product.tax,
            isFavorite: product.isFavorite
        )
        
        var imageToUpload: UIImage?
        if let imageData = product.imageData {
            imageToUpload = UIImage(data: imageData)
        }
        
        NetworkManager.shared.addProduct(product: uploadProduct, image: imageToUpload) { success, imageUrl in
            if success {
                DispatchQueue.main.async {
                    let context = PersistenceController.shared.container.viewContext
                    product.needsUpload = false
                    product.imageUrl = imageUrl
                    
                    do {
                        try context.save()
                    } catch {
                        print("Error saving context: \(error)")
                    }
                }
            }
        }
    }
}
