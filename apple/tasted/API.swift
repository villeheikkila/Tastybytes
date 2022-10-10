import Foundation
import Supabase

class API {
    static var supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_API_KEY"].unsafelyUnwrapped
    static var supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"].unsafelyUnwrapped)
    static var supabase = SupabaseClient(supabaseURL: API.supabaseURL.unsafelyUnwrapped, supabaseKey: API.supabaseKey)
}
    