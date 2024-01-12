import Foundation

public struct InfoPlist: Codable {
    public let supabaseUrl: URL
    public let supabaseAnonKey: String
    public let baseUrl: URL
    public let privacyPolicyUrl: String
    public let appName: String
    public let deepLinkBaseUrl: URL
    public let feedbackEmail: String
    public let bundleVersion: String
    public let bundleShortVersion: String

    public init() throws {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            throw NSError(domain: "Configuration", code: 0, userInfo: [NSLocalizedDescriptionKey: "infoDictionary not found"])
        }
        let jsonData = try JSONSerialization.data(withJSONObject: infoDictionary, options: .prettyPrinted)
        self = try JSONDecoder().decode(InfoPlist.self, from: jsonData)
    }

    enum CodingKeys: String, CodingKey {
        case supabaseUrl = "SUPABASE_URL"
        case supabaseAnonKey = "SUPABASE_ANON_KEY"
        case baseUrl = "BASE_URL"
        case privacyPolicyUrl = "PRIVACY_POLICY_URL"
        case appName = "APP_NAME"
        case deepLinkBaseUrl = "DEEP_LINK_BASE_URL"
        case feedbackEmail = "FEEDBACK_EMAIL"
        case bundleVersion = "CFBundleVersion"
        case bundleShortVersion = "CFBundleShortVersionString"
    }

    public var deeplinkSchema: String {
        var schema: String?

        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
            for urlType in urlTypes {
                if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String] {
                    schema = urlSchemes.first
                }
            }
        }

        guard let schema else { fatalError("Deep link schema is not set in plist for this environment") }
        return schema
    }

    public var appVersion: AppVersion {
        do {
            return try AppVersion(with: bundleShortVersion, buildVersion: Int(bundleVersion) ?? 0)
        } catch {
            fatalError("failed to decode AV")
        }
    }

    public var bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "N/A"
}
