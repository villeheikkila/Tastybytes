public struct BlurHash: Hashable, Sendable, Codable {
    enum BlurHashError: Error {
        case genericError
    }

    public let hash: String
    public let height: Double
    public let width: Double

    public init(hash: String, height: Double, width: Double) {
        self.hash = hash
        self.height = height
        self.width = width
    }

    public init(str: String) throws {
        let components = str.components(separatedBy: ":::")
        guard let dimensions = components.first?.components(separatedBy: ":")
        else { throw BlurHashError.genericError }
        guard let width = Double(dimensions[0]) else { throw BlurHashError.genericError }
        guard let height = Double(dimensions[1]) else { throw BlurHashError.genericError }
        let hash = components[1]

        self.hash = hash
        self.width = width
        self.height = height
    }

    public var encoded: String {
        "\(width):\(height):::\(hash)"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(width):\(height):::\(hash)")
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        let components = str.components(separatedBy: ":::")

        guard let dimensions = components.first?.components(separatedBy: ":") else {
            throw BlurHashError.genericError
        }

        guard let width = Double(dimensions[0]) else {
            throw BlurHashError.genericError
        }

        guard let height = Double(dimensions[1]) else {
            throw BlurHashError.genericError
        }

        let hash = components[1]

        self.hash = hash
        self.width = width
        self.height = height
    }
}
