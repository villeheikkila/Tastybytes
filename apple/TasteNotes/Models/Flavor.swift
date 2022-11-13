struct Flavor: Identifiable, Decodable {
    let id: Int
    let name: String
}

extension Flavor: Hashable {
    static func == (lhs: Flavor, rhs: Flavor) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Flavor {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "flavors"
        let saved = "id, name"
        
        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }
    
    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
