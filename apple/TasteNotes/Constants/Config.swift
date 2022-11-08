import Foundation
import Supabase

public enum Config {
  enum Keys {
    enum Plist {
      static let supabaseUrl = "SUPABASE_URL"
      static let supabaseAnonKey = "SUPABASE_ANON_KEY"
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
    guard let url = URL(string: rootURLstring) else {
      fatalError("Supabase URL is invalid")
    }
    return url
  }()

  static let supabaseAnonKey: String = {
    guard let anonKey = Config.infoDictionary[Keys.Plist.supabaseAnonKey] as? String else {
      fatalError("Supabase Anon Key not set in plist for this environment")
    }
    return anonKey
  }()
}
