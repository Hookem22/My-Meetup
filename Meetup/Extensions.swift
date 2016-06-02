
import UIKit

extension UIColor {
    static func hex(hexString: String) -> UIColor {
        let red = base16to10(hexString.substringWithRange(hexString.startIndex..<hexString.startIndex.advancedBy(2)))
        let green = base16to10(hexString.substringWithRange(hexString.startIndex.advancedBy(2)..<hexString.startIndex.advancedBy(4)))
        let blue = base16to10(hexString.substringWithRange(hexString.startIndex.advancedBy(4)..<hexString.startIndex.advancedBy(6)))
        
        return UIColor(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: 1.0)
    }
    
    private static func base16to10(base16: String) -> Double {
        var base10 = 0
        for (idx, char) in base16.characters.reverse().enumerate() {
            var charVal = 0
            switch char {
            case "A", "a":
                charVal = 10
            case "B", "b":
                charVal = 11
            case "C", "c":
                charVal = 12
            case "D", "d":
                charVal = 13
            case "E", "e":
                charVal = 14
            case "F", "f":
                charVal = 15
            default:
                charVal = Int(String(char))!
            }
            base10 += powerOf16(idx) * charVal
        }
        return Double(base10)
    }
    
    private static func powerOf16(power:Int) -> Int {
        var returnVal = 1;
        for _ in 0 ..< power {
            returnVal *= 16
        }
        return returnVal
    }
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }
