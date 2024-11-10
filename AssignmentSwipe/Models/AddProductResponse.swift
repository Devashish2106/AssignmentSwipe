//
//  AddProductResponse.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import Foundation

struct AddProductResponse: Codable {
    let message: String
    let productDetails: Product
    let productId: Int
    let success: Bool
}

