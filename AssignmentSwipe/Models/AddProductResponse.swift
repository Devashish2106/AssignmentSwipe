//
//  AddProductResponse.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import Foundation

struct AddProductResponse: Codable {
    let message: String?
    let productDetails: ProductDetails?
    let productId: Int?
    let success: Bool?
    
    enum CodingKeys: String, CodingKey {
        case message
        case productDetails = "product_details"
        case productId = "product_id"
        case success
    }
}

struct ProductDetails: Codable {
    let image: String?
    let price: Double
    let productName: String
    let productType: String
    let tax: Double
    
    enum CodingKeys: String, CodingKey {
        case image
        case price
        case productName = "product_name"
        case productType = "product_type"
        case tax
    }
}
