import Foundation
import Supabase

class Supabase {
    static var testing = false
    static var testingSupabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24ifQ.625_WdcF3KHqz5amU0x2X5WWHP-OEs_4qj0ssLNHzTs"
    static var testingUrlString = "http://localhost:54321"
    static var supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRta3Z1cW9vY3RvbHZoZHN1Ym90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjUzODg1MTQsImV4cCI6MTk4MDk2NDUxNH0.KmVr-_SLfU86G5CUfaR6plT4wdgab1DHpOpFmLtJlu8"
    
    static var urlString = "https://dmkvuqooctolvhdsubot.supabase.co"
    static var url = URL(string: Supabase.testing ? Supabase.testingUrlString:  Supabase.urlString)
    
    static var client = SupabaseClient(
        supabaseURL: Supabase.url.unsafelyUnwrapped,
        supabaseKey: Supabase.testing ? Supabase.testingSupabaseKey : Supabase.supabaseKey
    )
}

