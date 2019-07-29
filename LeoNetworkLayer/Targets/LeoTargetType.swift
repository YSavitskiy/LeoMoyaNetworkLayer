
import Foundation
import Moya

public protocol ILeoTargetType: TargetType, AccessTokenAuthorizable  {
}

public extension ILeoTargetType {
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var validationType: ValidationType {
        return .none
    }
    
    var sampleData: Data {
        return Data()
    }
}

