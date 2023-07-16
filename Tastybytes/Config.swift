import SwiftUI

enum Config {
    enum Keys {
        enum Plist {
            static let supabaseUrl = "SUPABASE_URL"
            static let supabaseAnonKey = "SUPABASE_ANON_KEY"
            static let baseUrl = "BASE_URL"
            static let privacyPolicyUrl = "PRIVACY_POLICY_URL"
            static let appName = "APP_NAME"
            static let deepLinkBaseUrl = "DEEP_LINK_BASE_URL"
            static let feedbackEmail = "FEEDBACK_EMAIL"
        }
    }

    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    static let appName: String = {
        guard let baseUrl = Config.infoDictionary[Keys.Plist.appName] as? String else {
            fatalError("App name is not set in plist for this environment")
        }
        return baseUrl
    }()

    static let supabaseUrl: URL = {
        guard let rootURLstring = Config.infoDictionary[Keys.Plist.supabaseUrl] as? String else {
            fatalError("Supabase URL not set in plist for this environment")
        }
        guard let supabaseUrl = URL(string: rootURLstring) else {
            fatalError("Supabase URL is invalid")
        }
        return supabaseUrl
    }()

    static let supabaseAnonKey: String = {
        guard let anonKey = Config.infoDictionary[Keys.Plist.supabaseAnonKey] as? String else {
            fatalError("Supabase Anon Key not set in plist for this environment")
        }
        return anonKey
    }()

    static let baseUrl: String = {
        guard let baseUrl = Config.infoDictionary[Keys.Plist.baseUrl] as? String else {
            fatalError("Base url is not set in plist for this environment")
        }
        return baseUrl
    }()

    static let privacyPolicyUrl: String = {
        guard let url = Config.infoDictionary[Keys.Plist.privacyPolicyUrl] as? String else {
            fatalError("Privacy policy url is not set in plist for this environment")
        }
        return url
    }()

    static let deeplinkBaseUrl: String = {
        guard let url = Config.infoDictionary[Keys.Plist.deepLinkBaseUrl] as? String else {
            fatalError("Deep link base url is not set in plist for this environment")
        }
        return url
    }()

    static let feedbackEmail: String = {
        guard let email = Config.infoDictionary[Keys.Plist.feedbackEmail] as? String else {
            fatalError("Deep link base url is not set in plist for this environment")
        }
        return email
    }()

    static let deeplinkSchema: String = {
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
    }()
}
