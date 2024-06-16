import Foundation

func getPagination(page: Int, size: Int) -> (Int, Int) {
    let from = page * size
    let to = from + size - 1
    return (from, to)
}
