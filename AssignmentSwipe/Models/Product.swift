import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id = UUID()
    let image: String?
    let productName: String
    let productType: String
    let price: Double
    let tax: Double
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case image
        case productName = "product_name"
        case productType = "product_type"
        case price
        case tax
    }
}
