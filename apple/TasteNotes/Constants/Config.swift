import Foundation
import Supabase

public enum Config {
  enum Keys {
    enum Plist {
      static let supabaseUrl = "SUPABASE_URL"
      static let supabaseAnonKey = "SUPABASE_ANON_KEY"
      static let baseUrl = "BASE_URL"
    }
  }

  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    return dict
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

  static let appName = "TasteNotes"
}
