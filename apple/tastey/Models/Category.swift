struct Category: Identifiable {
    let id: Int
    let name: CategoryName
}

enum CategoryName: String, CaseIterable, Decodable, Equatable {
    case chips
    case candy
    case chewing_gum
    case fruit
    case popcorn
    case ingredient
    case beverage
    case convenience_food
    case cheese
    case snacks
    case juice
    case chocolate
    case cocoa
    case ice_cream
    case pizza
    case protein
    case milk
    case alcoholic_beverage
    case cereal
    case pastry
    case spice
    case noodles
    case tea
    case coffee
}

extension CategoryName: Identifiable {
    var id: Self { self }
}

extension Category: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(CategoryName.self, forKey: .name)
    }
}

extension Category: Hashable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CategoryJoinedWithSubcategories: Identifiable {
    let id: Int
    let name: CategoryName
    let subcategories: [Subcategory]
}

extension CategoryJoinedWithSubcategories: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subcategories
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(CategoryName.self, forKey: .name)
        subcategories = try values.decode([Subcategory].self, forKey: .subcategories)
    }
}

extension CategoryJoinedWithSubcategories: Hashable {
    static func == (lhs: CategoryJoinedWithSubcategories, rhs: CategoryJoinedWithSubcategories) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CategoryJoinedWithServingStyles: Identifiable {
    let id: Int
    let name: CategoryName
    let servingStyles: [ServingStyle]
}

extension CategoryJoinedWithServingStyles: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case servingStyles = "serving_styles"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(CategoryName.self, forKey: .name)
        servingStyles = try values.decode([ServingStyle].self, forKey: .servingStyles)
    }
}

extension CategoryJoinedWithServingStyles: Hashable {
    static func == (lhs: CategoryJoinedWithServingStyles, rhs: CategoryJoinedWithServingStyles) -> Bool {
        return lhs.id == rhs.id
    }
}
