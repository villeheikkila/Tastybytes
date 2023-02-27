import Foundation

func isValidEAN13(input: String) -> Bool {
  if input.count != 13 { return false }
  let parts = input.compactMap(\.wholeNumberValue)
  if parts.count != 13 { return false }
  // Sum all the digits in even positions and multiply by 3
  let evenSumMultiplied = (parts[0] + parts[2] + parts[4] + parts[6] + parts[8] + parts[10]) * 3
  //  Add all the the digits in odd positions except for the last one which is check digit to the previos number
  let oddSum = parts[1] + parts[3] + parts[5] + parts[7] + parts[9] + parts[11]
  // Sum the previous two values and divide by 10 and take the reminder
  let reminder = (evenSumMultiplied + oddSum) % 10
  // If the reminder is zero, the check-value is 0 else substarct the reminder from 10
  let checkValue = reminder == 0 ? reminder : 10 - reminder
  // The last digit of EAN13 code is the check digit
  let checkDigit = parts[12]
  // If check digit equals the calculated check value, the EAN13 code is valid
  return checkValue == checkDigit
}
