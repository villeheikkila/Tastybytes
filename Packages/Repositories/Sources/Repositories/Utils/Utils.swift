import Foundation
import Models

func queryWithTableName(_ tableName: Database.Table, _ query: [String], _ withTableName: Bool) -> String {
    withTableName ? "\(tableName.rawValue) (\(query.joined(separator: ", ")))" : query.joined(separator: ", ")
}
