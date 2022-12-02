struct Permission: Identifiable {
    let id: Int
    let name: PermissionName
}

extension Permission: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Permission, rhs: Permission) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Permission {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "permissions"
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }
    
    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}


enum PermissionName: String, Decodable, Equatable {
    case canDeleteProducts = "can_delete_products"
    case canDeleteCompanies = "can_delete_companies"
    case canDeleteBrands = "can_delete_brands"
    case canAddSubcategories = "can_add_subcategories"
    case canEditCompanies = "can_edit_companies"
    case canMergeProducts = "can_merge_products"
    case canEditBrands = "can_edit_brands"
    case canUpdateSubBrands = "can_update_sub_brands"
    case canDeleteFlavors = "can_delete_flavors"
    case canUpdateFlavors = "can_update_flavors"
    case canInsertFlavors = "can_insert_flavors"

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

