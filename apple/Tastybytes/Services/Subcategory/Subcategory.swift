protocol SubcategoryProtocol {
  var id: Int { get }
  var name: String { get }
  var label: String { get }
}

struct Subcategory: Identifiable, Decodable, Hashable, SubcategoryProtocol {
  let id: Int
  let name: String

  var label: String {
    name.capitalized
  }

  static func == (lhs: Subcategory, rhs: Subcategory) -> Bool {
    lhs.id == rhs.id
  }
}

extension Subcategory {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "subcategories"
    let saved = "id, name"

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
  struct JoinedCategory: Identifiable, Hashable, Decodable, SubcategoryProtocol {
    let id: Int
    let name: String
    let category: Category

    var label: String {
      name.capitalized
    }

    func getSubcategory() -> Subcategory {
      Subcategory(id: id, name: name)
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: JoinedCategory, rhs: JoinedCategory) -> Bool {
      lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
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
  }
}
