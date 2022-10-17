//
//  Utils.swift
//  tasted
//
//  Created by Ville Heikkilä on 10.10.2022.
//

import Foundation
import SwiftUI

func printData(data: Data) {
    print("DATA: ", String(data: data, encoding: String.Encoding.utf8) ?? "")
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

enum StrinLenghtType {
    case normal
    case long
}

func validateStringLenght(str: String, type: StrinLenghtType) -> Bool {
    switch type {
    case .normal:
        return str.count > 2 && str.count <= 24
    case .long:
        return str.count > 2 && str.count <= 48
    }
    
}
