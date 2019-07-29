import Moya
import enum Result.Result

public protocol ILeoResponse {
    var isNotAuthorized: Bool {get}
    func parseSuccess() -> Result<Response, MoyaError>?
    func checkServerError() -> Result<Response, MoyaError>?
}

extension Response: ILeoResponse {
    public var isNotAuthorized: Bool {
        return self.statusCode == 401
    }
    
    public func parseSuccess() -> Result<Response, MoyaError>? {
        var result: Result<Response, MoyaError>? = nil
        if (self.statusCode >= 200) && (self.statusCode <= 299) {
            result = .failure(MoyaError.underlying(LeoProviderError.simpleError, self))
        }
        return result
    }
    
    public func checkServerError() -> Result<Response, MoyaError>? {
        var result: Result<Response, MoyaError>? = nil
        if (self.statusCode >= 500) && (self.statusCode <= 599) {
            result = .failure(MoyaError.underlying(LeoProviderError.serverError, self))
        }
        return result
    }        
}
