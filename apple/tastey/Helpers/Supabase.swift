import Foundation
import Supabase

class Supabase {
    static var supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRta3Z1cW9vY3RvbHZoZHN1Ym90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjUzODg1MTQsImV4cCI6MTk4MDk2NDUxNH0.KmVr-_SLfU86G5CUfaR6plT4wdgab1DHpOpFmLtJlu8"
    static var urlString = "https://dmkvuqooctolvhdsubot.supabase.co"
    static var url = URL(string: Supabase.urlString)
    
    static var client = SupabaseClient(
        supabaseURL: Supabase.url.unsafelyUnwrapped,
        supabaseKey: Supabase.supabaseKey
    )
}

