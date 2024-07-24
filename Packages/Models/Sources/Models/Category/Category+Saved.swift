import Foundation
public import Tagged

public extension Category {
    struct Saved: Identifiable, Codable, Hashable, Sendable, CategoryProtocol {
        public let id: Category.Id
        public let name: String
        public let icon: String?

        public init(id: Category.Id, name: String, icon: String?) {
            self.id = id
            self.name = name
            self.icon = icon
        }

        public init(category: JoinedSubcategoriesServingStyles) {
            id = category.id
            name = category.name
            icon = category.icon
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            icon = nil
        }
    }
}
