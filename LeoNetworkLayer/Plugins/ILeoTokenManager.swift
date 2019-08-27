import RxSwift
import Moya

public protocol ILeoTokenManager {
    var refreshTokenTimeoutSeconds: Double {get}
    var numberRefreshTokenAttempts: Int {get}
    func getAccessToken() -> String
    func refreshToken() -> Single<String?>? //Have to return a new access token
    func clearTokensAndHandleLogout()
}


