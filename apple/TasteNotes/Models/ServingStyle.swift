enum ServingStyleName: String, CaseIterable, Decodable, Identifiable, Equatable {
    var id: Self { self }
    case bottle
    case can
    case none
}


struct ServingStyle: Identifiable {
    let id: Int
    let name: ServingStyleName
}

extension ServingStyle: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(ServingStyleName.self, forKey: .name)
    }
}

extension ServingStyle: Hashable {
    static func == (lhs: ServingStyle, rhs: ServingStyle) -> Bool {
        return lhs.id == rhs.id
    }
}
