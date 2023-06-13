extension String? {
    var isNilOrEmpty: Bool {
        // swiftlint:disable empty_string
        self == nil || self == ""
        // swiftlint:enable empty_string
    }
}
