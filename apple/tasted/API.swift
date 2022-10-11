import Foundation
import Supabase

class API {
    static var supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRta3Z1cW9vY3RvbHZoZHN1Ym90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjUzODg1MTQsImV4cCI6MTk4MDk2NDUxNH0.KmVr-_SLfU86G5CUfaR6plT4wdgab1DHpOpFmLtJlu8"
    static var supabaseURLString = "https://dmkvuqooctolvhdsubot.supabase.co"
    static var supabaseURL = URL(string: API.supabaseURLString)
    static var supabase = SupabaseClient(supabaseURL: API.supabaseURL.unsafelyUnwrapped, supabaseKey: API.supabaseKey)
}
    
