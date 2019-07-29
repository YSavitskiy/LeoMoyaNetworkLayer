import RxSwift

public protocol ILeoTokenManager {
    func getAccessToken() -> String
    func getRefreshToken() -> String
    func refreshToken() -> Single<String>
    func clearTokensAndHandleLogout()
}
