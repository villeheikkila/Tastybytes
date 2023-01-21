struct Subcategory: Identifiable, Decodable, Hashable {
  let id: Int
  let name: String

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
  struct JoinedCategory: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let category: Category

    func getSubcategory() -> Subcategory {
      Subcategory(id: id, name: name)
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: JoinedCategory, rhs: JoinedCategory) -> Bool {
      lhs.id == rhs.id
    }

    init(id: Int, name: String, category: Category) {
      self.id = id
      self.name = name
      self.category = category
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case category = "categories"
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(Int.self, forKey: .id)
      name = try values.decode(String.self, forKey: .name)
      category = try values.decode(Category.self, forKey: .category)
    }
  }
}

extension Subcategory {
  struct NewRequest: Encodable {
    let name: String
    let category_id: Int

    init(name: String, category: Category.JoinedSubcategories) {
      self.name = name
      category_id = category.id
    }
  }
}
