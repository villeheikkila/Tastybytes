import Foundation

public struct InfoPlist: Codable {
    private struct CFBundleType: Codable {
        let CFBundleTypeRole: String
        let CFBundleURLName: String
        let CFBundleURLSchemes: [String]
    }

    public let supabaseUrl: URL
    public let supabaseAnonKey: String
    public let baseUrl: URL
    public let privacyPolicyUrl: String
    public let appName: String
    public let deepLinkBaseUrl: URL
    public let feedbackEmail: String
    public let bundleVersion: String
    public let appVersion: AppVersion
    private let cfBundleURLTypes: [CFBundleType]

    enum CodingKeys: String, CodingKey {
        case supabaseUrl = "SUPABASE_URL"
        case supabaseAnonKey = "SUPABASE_ANON_KEY"
        case baseUrl = "BASE_URL"
        case privacyPolicyUrl = "PRIVACY_POLICY_URL"
        case appName = "APP_NAME"
        case deepLinkBaseUrl = "DEEP_LINK_BASE_URL"
        case feedbackEmail = "FEEDBACK_EMAIL"
        case bundleVersion = "CFBundleVersion"
        case appVersion = "CFBundleShortVersionString"
        case cfBundleURLTypes = "CFBundleURLTypes"
    }

    public var deeplinkSchemes: [String] {
        cfBundleURLTypes.flatMap(\.CFBundleURLSchemes)
    }
}
