import Foundation

func isValidEAN13(input: String) -> Bool {
    guard input.count == 13 else {
        return false
    }
    let digits = input.compactMap { Int(String($0)) }
    guard digits.count == 13 else {
        return false
    }
    guard let checkDigit = digits.last else { return false }

    let sum = digits
        .dropLast()
        .enumerated()
        .reduce(0) { total, curr in
            total + (curr.element * (curr.offset.isMultiple(of: 2) ? 1 : 3))
        }
    let calculatedCheckDigit = (10 - (sum % 10)) % 10
    return checkDigit == calculatedCheckDigit
}
