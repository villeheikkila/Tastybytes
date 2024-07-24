import Foundation
public import Tagged

public enum Category {}

public extension Category {
    typealias Id = Tagged<Category, Int>
}

public protocol CategoryProtocol: Sendable {
    var id: Category.Id { get }
    var name: String { get }
    var icon: String? { get }
}

public extension CategoryProtocol {
    var label: String {
        if let icon {
            "\(icon) \(name)"
        } else {
            name
        }
    }
}
