struct ProductVariant: Identifiable, Codable, Hashable {
  let id: Int
  let manufacturer: Company

  enum CodingKeys: String, CodingKey {
    case id
    case manufacturer = "companies"
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ProductVariant, rhs: ProductVariant) -> Bool {
    lhs.id == rhs.id
  }
}

extension ProductVariant {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "product_variants"
    let saved = "id"

    switch queryType {
    case let .joined(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, Company.getQuery(.saved(true))), withTableName)
    }
  }

  enum QueryType {
    case joined(_ withTableName: Bool)
  }
}
