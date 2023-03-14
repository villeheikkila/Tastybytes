protocol SubcategoryProtocol {
  var id: Int { get }
  var name: String { get }
  var isVerified: Bool { get }
  var label: String { get }
}

struct Subcategory: Identifiable, Decodable, Hashable, Sendable, SubcategoryProtocol, Comparable {
  let id: Int
  let name: String
  let isVerified: Bool

  var label: String {
    name.capitalized
  }

  static func < (lhs: Subcategory, rhs: Subcategory) -> Bool {
    lhs.name < rhs.name
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case isVerified = "is_verified"
  }
}

extension Subcategory {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "subcategories"
    let saved = "id, name, is_verified"

    switch queryType {
    case .tableName:
      return tableName
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    case let .joinedCategory(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, Category.getQuery(.saved(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
    case joinedCategory(_ withTableName: Bool)
  }
}

extension Subcategory {
  struct JoinedCategory: Identifiable, Hashable, Decodable, Sendable, SubcategoryProtocol {
    let id: Int
    let name: String
    let isVerified: Bool
    let category: Category

    var label: String {
      name.capitalized
    }

    func getSubcategory() -> Subcategory {
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

extension Subcategory {
  struct NewRequest: Encodable {
    let name: String
    let categoryId: Int

    enum CodingKeys: String, CodingKey {
      case name, categoryId = "category_id"
    }

    init(name: String, category: Category.JoinedSubcategories) {
      self.name = name
      categoryId = category.id
    }

    init(name: String, category: Category.JoinedSubcategoriesServingStyles) {
      self.name = name
      categoryId = category.id
    }
  }

  struct VerifyRequest: Encodable, Sendable {
    let id: Int
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
      case id = "p_subcategory_id"
      case isVerified = "p_is_verified"
    }
  }

  struct UpdateRequest: Encodable, Sendable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
      case id, name
    }

    init(id: Int, name: String) {
      self.id = id
      self.name = name
    }
  }
}
