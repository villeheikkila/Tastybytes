struct Category: Identifiable, Decodable, Hashable {
  enum Name: String, Identifiable, CaseIterable, Decodable, Equatable {
    var id: Self { self }
    case chips
    case candy
    case chewingGum = "chewing_gum"
    case fruit
    case popcorn
    case ingredient
    case beverage
    case convenienceFood = "convenience_food"
    case cheese
    case snacks
    case juice
    case chocolate
    case cocoa
    case iceCream = "ice_cream"
    case pizza
    case protein
    case milk
    case alcoholicBeverage = "alcoholic_beverage"
    case cereal
    case pastry
    case spice
    case noodles
    case tea
    case coffee

    var label: String {
      rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
  }

  let id: Int
  let name: Name

  enum CodingKeys: String, CodingKey {
    case id
    case name
  }

  static func == (lhs: Category, rhs: Category) -> Bool {
    lhs.id == rhs.id
  }
}

extension Category {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "categories"
    let saved = "id, name"

    switch queryType {
    case .tableName:
      return tableName
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    case let .joinedSubcategories(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, Subcategory.getQuery(.saved(true))), withTableName)
    case let .joinedServingStyles(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, ServingStyle.getQuery(.saved(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
    case joinedSubcategories(_ withTableName: Bool)
    case joinedServingStyles(_ withTableName: Bool)
  }
}

extension Category {
  struct JoinedSubcategories: Identifiable, Decodable, Hashable {
    let id: Int
    let name: Name
    let subcategories: [Subcategory]

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case subcategories
    }

    init(id: Int, name: Name, subcategories: [Subcategory]) {
      self.id = id
      self.name = name
      self.subcategories = subcategories
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: JoinedSubcategories, rhs: JoinedSubcategories) -> Bool {
      lhs.id == rhs.id
    }
  }

  struct JoinedServingStyles: Identifiable, Decodable, Hashable {
    let id: Int
    let name: Name
    let servingStyles: [ServingStyle]

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case servingStyles = "serving_styles"
    }

    static func == (lhs: JoinedServingStyles, rhs: JoinedServingStyles) -> Bool {
      lhs.id == rhs.id
    }
  }
}
