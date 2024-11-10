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
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch products:", error.localizedDescription)
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                completion(products)
            } catch {
                print("Decoding error:", error.localizedDescription)
                completion(nil)
            }
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
            if let error = error {
                print("Request error:", error.localizedDescription)
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("No data received from server")
                completion(false)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(AddProductResponse.self, from: data)
                completion(response.success ?? false)
            } catch {
                print("Decoding error:", error.localizedDescription)
                print("Response data:", String(data: data, encoding: .utf8) ?? "N/A")
                completion(false)
            }
        }.resume()
    }
}

