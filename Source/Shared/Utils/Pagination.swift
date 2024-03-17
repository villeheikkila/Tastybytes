import Foundation

func getPagination(page: Int, size: Int) -> (Int, Int) {
    let limit = size + 1
    let from = page * limit
    let to = from + size
    return (from, to)
}
