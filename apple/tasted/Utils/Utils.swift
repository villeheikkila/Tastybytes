//
//  Utils.swift
//  tasted
//
//  Created by Ville Heikkilä on 10.10.2022.
//

import Foundation
import SwiftUI

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

func getPagination(page: Int, size: Int) -> (Int, Int) {
      let limit = size + 1
      let from = page * limit
      let to = from + size
      return (from, to)
}

func getConsistentColor(seed: String) -> Color {
    var total: Int = 0
    for u in seed.unicodeScalars {
        total += Int(UInt32(u))
    }
    srand48(total * 200)
    let r = CGFloat(drand48())
    srand48(total)
    let g = CGFloat(drand48())
    srand48(total / 200)
    let b = CGFloat(drand48())
    return Color(red: r, green: g, blue: b)
}
