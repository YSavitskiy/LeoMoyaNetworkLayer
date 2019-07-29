import Foundation
import LEONetworkLayer
import Moya

enum AuthentificationTarget {
    case sendPhone(phone: String)
    case login(login: SignInParameters)
    case verify(login: SigninRequest)
    case register(userId: String, userData: UserDetailsRequest)
    case refreshToken(refreshToken: String)
}

extension AuthentificationTarget: ILeoTargetType {
    var path: String {
        switch self {
        case .readUsers, .createUser(_):
            return "/users"
        case .updateUser(let id, _), .deleteUser(let id):
            return "/users/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createUser(_):
            return .post
        case .readUsers:
            return .get
        case .updateUser(_, _):
            return .put
        case .deleteUser(_):
            return .delete
        }
    }
    
    var sampleData: Data {
        switch self {
        case .createUser(let name):
            let str = """
            {"name": "\(name)","id":3}
            """
            print(str)
            
            return str.data(using: .utf8)!
        case .readUsers:
            return """
                [{"id":3, "name":"testo2"}, {"id":2, "name":"testo3"}]
            """.data(using: .utf8)!
        case .updateUser(let id, let name):
            return """
                {"id":\(id),"name": "\(name)"}
                """.data(using: .utf8)!
        case .deleteUser(let id):
            return """
                {"id":\(id)}
                """.data(using: .utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .readUsers, .deleteUser(_):
            return .requestPlain
        case .createUser(let name), .updateUser(_, let name):
            return .requestParameters(parameters: ["name":name], encoding: JSONEncoding.default)
        }
    }    
}
