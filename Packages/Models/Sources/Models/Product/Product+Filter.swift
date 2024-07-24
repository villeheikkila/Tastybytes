public extension Product {
    struct Filter: Hashable, Codable, Sendable {
        public enum SortBy: String, CaseIterable, Identifiable, Sendable, Codable {
            public var id: Self { self }

            case highestRated = "highest_rated"
            case lowestRated = "lowest_rated"
        }

        public let category: Models.Category.JoinedSubcategoriesServingStyles?
        public let subcategory: Subcategory.Saved?
        public let onlyNonCheckedIn: Bool
        public let sortBy: SortBy?
        public let rating: Double?
        public let onlyUnrated: Bool?

        public init(category: Models.Category.JoinedSubcategoriesServingStyles? = nil,
                    subcategory: Subcategory.Saved? = nil,
                    onlyNonCheckedIn: Bool = false,
                    sortBy: SortBy? = nil,
                    rating: Double? = nil,
                    onlyUnrated: Bool? = nil)
        {
            self.category = category
            self.subcategory = subcategory
            self.onlyNonCheckedIn = onlyNonCheckedIn
            self.sortBy = sortBy
            self.rating = rating
            self.onlyUnrated = onlyUnrated
        }

        public init(rating: Double) {
            self.rating = rating
            onlyNonCheckedIn = false
            category = nil
            subcategory = nil
            sortBy = nil
            onlyUnrated = nil
        }

        public init(
            category: Models.Category.JoinedSubcategoriesServingStyles?,
            subcategory: Subcategory.Saved?,
            onlyNonCheckedIn: Bool,
            sortBy: SortBy?
        ) {
            self.category = category
            self.subcategory = subcategory
            self.onlyNonCheckedIn = onlyNonCheckedIn
            self.sortBy = sortBy
            rating = nil
            onlyUnrated = nil
        }

        public init(
            category: Category.Saved? = nil,
            subcategory: Subcategory.Saved? = nil,
            onlyNonCheckedIn: Bool = false,
            sortBy: SortBy? = nil
        ) {
            if let category {
                self.category = Models.Category.JoinedSubcategoriesServingStyles(
                    id: category.id,
                    name: category.name,
                    icon: category.icon,
                    subcategories: [],
                    servingStyles: []
                )
            } else {
                self.category = nil
            }
            self.subcategory = subcategory
            self.onlyNonCheckedIn = onlyNonCheckedIn
            self.sortBy = sortBy
            rating = nil
            onlyUnrated = nil
        }

        public func copyWith(category: Models.Category.JoinedSubcategoriesServingStyles?) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }

        public func copyWith(subcategory: Subcategory.Saved?) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }

        public func copyWith(onlyNonCheckedIn: Bool) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }

        public func copyWith(sortBy: SortBy?) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }
    }
}
