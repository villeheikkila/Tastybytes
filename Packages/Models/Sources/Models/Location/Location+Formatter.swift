import Foundation

public extension Location.Saved {
    struct Formatter<Output> {
        let format: (Location.Saved) -> Output
    }

    func formatted<Output>(_ formatter: Formatter<Output>) -> Output {
        formatter.format(self)
    }
}

public extension Location.Saved.Formatter where Output == String {
    static var withEmoji: Self {
        .init { value in
            "\(value.name) \(value.country?.emoji ?? "")"
        }
    }
}
