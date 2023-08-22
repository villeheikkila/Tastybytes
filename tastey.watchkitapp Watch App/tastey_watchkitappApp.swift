//
//  tastey_watchkitappApp.swift
//  tastey.watchkitapp Watch App
//
//  Created by Ville Heikkilä on 22.8.2023.
//

import Models
import Supabase
import SwiftUI

@main
struct tastey_watchkitapp_Watch_AppApp: App {
    private let supabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://dmkvuqooctolvhdsubot.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRta3Z1cW9vY3RvbHZoZHN1Ym90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjUzODg1MTQsImV4cCI6MTk4MDk2NDUxNH0.KmVr-_SLfU86G5CUfaR6plT4wdgab1DHpOpFmLtJlu8"
    )

    var body: some Scene {
        WindowGroup {
            ContentView(supabaseClient: supabaseClient)
        }
    }
}
