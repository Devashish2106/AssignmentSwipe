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
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Function to append form field
        func appendFormField(named name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add form fields
        appendFormField(named: "product_name", value: product.productName)
        appendFormField(named: "product_type", value: product.productType)
        appendFormField(named: "price", value: String(format: "%.2f", product.price))
        appendFormField(named: "tax", value: String(format: "%.2f", product.tax))
        
        // Add final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the request body
        request.httpBody = body
        
        // Print request for debugging
        print("Request URL: \(url)")
        print("Request Headers: \(String(describing: request.allHTTPHeaderFields))")
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        
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
            
            // Print response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
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
