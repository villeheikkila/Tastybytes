struct Permission: Identifiable {
    let id: Int
    let name: PermissionName
}

extension Permission: Hashable {
    static func == (lhs: Permission, rhs: Permission) -> Bool {
        return lhs.id == rhs.id
    }
}

enum PermissionName: String, Decodable, Equatable {
    case canDeleteProducts = "can_delete_products"
    case canDeleteCompanies = "can_delete_companies"
    case canDeleteBrands = "can_delete_brands"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        if let permission = PermissionName(rawValue: rawString) {
            self = permission
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot initialize PermissionName from invalid String value \(rawString)")
        }
    }
}

extension Permission: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(PermissionName.self, forKey: .name)
    }
}

