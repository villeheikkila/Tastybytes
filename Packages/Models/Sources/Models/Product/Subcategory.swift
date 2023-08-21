import Extensions

public protocol SubcategoryProtocol {
    var id: Int { get }
    var name: String { get }
    var isVerified: Bool { get }
}

public struct Subcategory: Identifiable, Codable, Hashable, Sendable, SubcategoryProtocol, Comparable {
    public init(id: Int, name: String, isVerified: Bool) {
        self.id = id
        self.name = name
        self.isVerified = isVerified
    }

    public let id: Int
    public let name: String
    public let isVerified: Bool

    public static func < (lhs: Subcategory, rhs: Subcategory) -> Bool {
        lhs.name < rhs.name
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isVerified = "is_verified"
    }
}

public extension Subcategory {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.subcategories.rawValue
        let saved = "id, name, is_verified"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedCategory(withTableName):
            return queryWithTableName(tableName, [saved, Category.getQuery(.saved(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joinedCategory(_ withTableName: Bool)
    }
}

public extension Subcategory {
    struct JoinedCategory: Identifiable, Hashable, Codable, Sendable, SubcategoryProtocol {
        public let id: Int
        public let name: String
        public let isVerified: Bool
        public let category: Category

        public func getSubcategory() -> Subcategory {
            Subcategory(id: id, name: name, isVerified: isVerified)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case category = "categories"
        }
    }
}

public extension Subcategory {
    struct NewRequest: Codable {
        public let name: String
        public let categoryId: Int

        enum CodingKeys: String, CodingKey {
            case name, categoryId = "category_id"
        }

        public init(name: String, category: Models.Category.JoinedSubcategoriesServingStyles) {
            self.name = name
            categoryId = category.id
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public init(id: Int, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Int
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_subcategory_id"
            case isVerified = "p_is_verified"
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let id: Int
        public let name: String

        enum CodingKeys: String, CodingKey {
            case id, name
        }

        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }
}
