import Foundation
import Supabase

class Config {
    static var supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]!
    static var supabaseUrl = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"]!)!
}
