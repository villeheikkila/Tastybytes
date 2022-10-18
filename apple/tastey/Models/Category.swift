enum CategoryName: String, CaseIterable, Decodable, Identifiable, Equatable {
    var id: Self { self }
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

struct Category: Identifiable, Decodable, Hashable {
    let id: Int
    let name: CategoryName

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(CategoryName.self, forKey: .name)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CategoryJoinedWithSubcategories: Identifiable, Decodable, Hashable {
    let id: Int
    let name: CategoryName
    let subcategories: [Subcategory]

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

    static func == (lhs: CategoryJoinedWithSubcategories, rhs: CategoryJoinedWithSubcategories) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CategoryJoinedWithServingStyles: Decodable, Identifiable, Equatable {
    let id: Int
    let name: CategoryName
    let servingStyles: [ServingStyle]
    
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
    
    static func == (lhs: CategoryJoinedWithServingStyles, rhs: CategoryJoinedWithServingStyles) -> Bool {
        return lhs.id == rhs.id
    }
    
}

