import Moya
import enum Result.Result

public protocol ILeoResponse {
    var isNotAuthorized: Bool {get}
    func parseSuccess() -> Result<Response, MoyaError>?
    func checkServerError() -> Result<Response, MoyaError>?
    func decodeData<T:Codable>(_ type: T.Type) -> T?
}


extension Response: ILeoResponse {
    
    public func decodeData<T:Codable>(_ type: T.Type) -> T? {
        return try? JSONDecoder().decode(T.self, from: self.data)
    }
    
    public var isNotAuthorized: Bool {
        return self.statusCode == 401
    }
    
    public func parseSuccess() -> Result<Response, MoyaError>? {
        print(self.statusCode)
        var result: Result<Response, MoyaError>? = nil
        
        if (self.statusCode >= 200) && (self.statusCode <= 299) {
            //print(String(data: self.data, encoding: .utf8))
            if let baseObject = self.decodeData(LeoBaseObject.self) {
                
                switch baseObject.code {
                case .success:
                    print("0")
                case .businessConflict:
                    print("1")
                case .unprocessableEntity:
                    print("2")
                case .badParameters:
                    print("3")
                case .internalError:
                    print("4")
                case .notFound:
                    print("5")
                case .securityError:
                    print("6")
                case .permissionError:
                    print("7")
                case .unknown:
                    print("8")
                @unknown default:
                    print("9")
                }
                
                print(baseObject.code)
            }
        //    result = .failure(MoyaError.underlying(LeoProviderError.notLeoObject, self))
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
