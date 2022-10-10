//
//  Utils.swift
//  tasted
//
//  Created by Ville Heikkilä on 10.10.2022.
//

import Foundation

func getCurrentUserId() -> String {
    guard let id = API.supabase.auth.session?.user.id else { fatalError("User session doesn't exists, yet the route is protected") }
    return id.uuidString.lowercased()
}
