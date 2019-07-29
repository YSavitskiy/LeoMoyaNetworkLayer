import Foundation

extension String
{
    func left(_ length: Int)->String {
        if (self.count <= length) {
            return self
        }
        return String( Array(self).prefix(upTo: length) )
    }
}
