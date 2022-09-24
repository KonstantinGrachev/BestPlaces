import Foundation

extension Int {
    
    func convertSeconds() -> (min: Int, sec: Int) {
        let min = self / 60
        let sec = self % 60
        return (min, sec)
    }

   func setZeroForSeconds() -> String {
        Double(self) / 10 < 1 ? "0\(self)" : "\(self)"
    }
}
