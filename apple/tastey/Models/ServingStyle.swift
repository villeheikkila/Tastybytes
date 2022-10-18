enum ServingStyleName: String, CaseIterable, Decodable, Identifiable, Equatable {
    var id: Self { self }
    case bottle
    case can
    case none
}


struct ServingStyle: Identifiable, Hashable, Decodable {
    let id: Int
    let name: ServingStyleName
    
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
