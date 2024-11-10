//
//  NetworkManager.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import Foundation
import UIKit

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
    
    func addProduct(product: Product, image: UIImage?, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://app.getswipe.in/api/public/add") else { return }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Helper function to append text field
        func appendFormField(named name: String, value: String) {
            let fieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n"
            body.append(fieldString.data(using: .utf8)!)
        }
            
        // Helper function to append image data
        func appendImageData(image: UIImage, fieldName: String) {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            let fieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(fieldName)[]\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
            body.append(fieldString.data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
            
        // Append all form fields
        appendFormField(named: "product_name", value: product.productName)
        appendFormField(named: "product_type", value: product.productType)
        appendFormField(named: "price", value: String(format: "%.2f", product.price))
        appendFormField(named: "tax", value: String(format: "%.2f", product.tax))
            
        // Append image if available
        if let image = image {
            appendImageData(image: image, fieldName: "files")
        }
            
        // Add final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
        // Set the request body
        request.httpBody = body
            
        // Print request details for debugging
        print("Request URL: \(url)")
        print("Request Headers: \(String(describing: request.allHTTPHeaderFields))")
        print("Request Body Length: \(body.count) bytes")
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload error:", error.localizedDescription)
                completion(false, nil)
                return
            }
                
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
                print("Response Headers:", httpResponse.allHeaderFields)
            }
                
            guard let data = data else {
                print("No response data")
                completion(false, nil)
                return
            }
                
            // Print response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response:", responseString)
            }
                
            do {
                let response = try JSONDecoder().decode(AddProductResponse.self, from: data)
                completion(response.success ?? false, response.productDetails?.image)
            } catch {
                print("Decoding error:", error)
                completion(false, nil)
            }
        }.resume()
    }
}
