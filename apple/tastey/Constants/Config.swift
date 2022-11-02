import Foundation
import Supabase

let environment = ProcessInfo.processInfo.environment

class Config {
    static var supabaseAnonKey: String = environment["SUPABASE_ANON_KEY"] ?? ""
    static var supabaseUrl: URL = URL(string: environment["SUPABASE_URL"] ?? "").unsafelyUnwrapped
}
