//
//  NetworkManager.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchProducts(completion: @escaping ([Product]?) -> Void) {
        guard let url = URL(string: "https://app.getswipe.in/api/public/get") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Failed to fetch products:", error)
                completion(nil)
                return
            }
            guard let data = data else { return }
            let products = try? JSONDecoder().decode([Product].self, from: data)
            completion(products)
        }.resume()
    }
    
    func addProduct(product: Product, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://app.getswipe.in/api/public/add") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "product_name": product.productName,
            "product_type": product.productType,
            "price": "\(product.price)",
            "tax": "\(product.tax)"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            let response = try? JSONDecoder().decode(AddProductResponse.self, from: data)
            completion(response?.success ?? false)
        }.resume()
    }
}

