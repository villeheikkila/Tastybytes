import Foundation
import Models

func queryWithTableName(_ tableName: String, _ query: String, _ withTableName: Bool) -> String {
    withTableName ? "\(tableName) (\(query))" : query
}
