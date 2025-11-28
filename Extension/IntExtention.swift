

import Foundation
import UIKit

extension Int {
    func toStringChoice(_ one: String, _ two: String, _ five: String) -> String {
        let variants: [String] = [one, two, five]
        let cases: [Int] = [2, 0, 1, 1, 1, 2]
        let index: Int = (self % 100 > 4 && self % 100 < 20) ? 2 : cases[ [self % 10, 5].min()! ]

        return "\(self) \(variants[index])"
    }
}
