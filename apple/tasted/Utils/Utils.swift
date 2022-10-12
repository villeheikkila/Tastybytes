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

func getCurrentUserIdUUID() -> UUID {
    guard let id = API.supabase.auth.session?.user.id else { fatalError("User session doesn't exists, yet the route is protected") }
    return id
}

func printData(data: Data) {
    print(String(data: data, encoding: String.Encoding.utf8) ?? "")
}

func getAvatarURL(avatarUrl: String) -> URL {
    let bucketId = "avatars"
    let urlString = "\(API.supabaseURLString)/storage/v1/object/public/\(bucketId)/\(avatarUrl)"
    guard let url = URL(string: urlString) else { fatalError("Invalid URL") }

    return url
}

func formatDate(isoDate: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter.date(from: isoDate)!
}
