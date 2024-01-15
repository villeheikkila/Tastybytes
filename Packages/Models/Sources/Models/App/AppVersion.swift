public struct AppVersion: Codable, Sendable, Hashable, Comparable {
    let major: Int
    let minor: Int
    let patch: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)
        let components = versionString.split(separator: ".").compactMap { Int($0) }

        guard components.count == 3 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid Version. Expected format: 'major.minor.patch'"))
        }

        major = components[0]
        minor = components[1]
        patch = components[2]
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(prettyString)
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            lhs.minor < rhs.minor
        } else {
            lhs.patch < rhs.patch
        }
    }

    public var prettyString: String {
        "\(major).\(minor).\(patch)"
    }

}
