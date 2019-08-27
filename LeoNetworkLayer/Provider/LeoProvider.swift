//
//  LeoProvider.swift
//  LeoExample
//
//  Created by Yuriy Savitskiy on 7/25/19.
//  Copyright © 2019 Yuriy Savitskiy. All rights reserved.
//

import Foundation
import Moya
import enum Result.Result
import Alamofire
import RxSwift


open class LeoProviderFactory<T:TargetType> {
    
    public func makeProvider(tokenManager:ILeoTokenManager? = nil, mockType: StubBehavior = .never, plugins: [PluginType] = [], customConfiguration: URLSessionConfiguration?) -> MoyaProvider<T> {
        
        let allPlugins = makeTokenPlugins(tokenManager: tokenManager) + makeLeoPlugins(tokenManager: tokenManager) + plugins
        
        let sessionManager = makeSessionManager(customConfiguration: customConfiguration)
        
        let provider = LeoProvider<T>(stubClosure:{ _ in return mockType }, callbackQueue: nil, manager: sessionManager, plugins: allPlugins)
        provider.tokenManager = tokenManager
        return provider
    }
    
    
    public func makeProvider(tokenManager:ILeoTokenManager? = nil, mockType: StubBehavior = .never, plugins: [PluginType] = [], timeoutForRequest:TimeInterval = 20.0, timeoutForResponse: TimeInterval = 40.0) -> MoyaProvider<T> {
        
        
        let configuration = makeConfiguration(timeoutForRequest: timeoutForRequest, timeoutForResponse: timeoutForResponse)
        
        return makeProvider(tokenManager: tokenManager, mockType: mockType, customConfiguration: configuration)
    }
    
    private func makeTokenPlugins(tokenManager:ILeoTokenManager?) -> [PluginType] {
        var result:[PluginType] = []
        if let tokenManager = tokenManager {
            let accessTokenPlugin = AccessTokenPlugin(tokenClosure: tokenManager.getAccessToken)
            let refreshTokenPlugin = RefreshTokenPlugin(tokenManager: tokenManager)
            result = [accessTokenPlugin, refreshTokenPlugin]
        }
        return result
    }
    
    private func makeLeoPlugins(tokenManager:ILeoTokenManager?) -> [PluginType] {
        let leoPlugin = LeoPlugin(tokenManager: tokenManager)
        return [leoPlugin]
    }
    
    private func makeConfiguration(timeoutForRequest:TimeInterval = 20.0, timeoutForResponse: TimeInterval = 40.0) ->  URLSessionConfiguration {
        let configuration: URLSessionConfiguration
        configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = timeoutForRequest
        configuration.timeoutIntervalForResource = timeoutForResponse
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return configuration
    }
    
    private func makeSessionManager(customConfiguration: URLSessionConfiguration?) -> SessionManager {
        var sessionManager: Manager
        
        if let configuration = customConfiguration {
            sessionManager = Manager(configuration: configuration)
            sessionManager.startRequestsImmediately = false
        } else {
            sessionManager = MoyaProvider<T>.defaultAlamofireManager()
        }
        
        return sessionManager
    }
    
    public init () {
    }
}


private class LeoProvider<Target>: MoyaProvider<Target> where Target: Moya.TargetType {
    
    var tokenManager:ILeoTokenManager?
    private var disposeBag = DisposeBag()
    
    override func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        
        var attempts: Int
        
        return super.request(target, callbackQueue: callbackQueue, progress: progress, completion:
            { (result) in
                
                let finalCompletion: Completion = completion
                
                switch result {
                case .success:
                     finalCompletion(result)
                case .failure(let error):
                    if let authorizable = target as? AccessTokenAuthorizable, let tokenManager = self.tokenManager {
                        var attempts = tokenManager.numberRefreshTokenAttempts
                        let requestAuthorizationType = authorizable.authorizationType
                        
                        if case .none = requestAuthorizationType {
                            finalCompletion(result)
                        } else {
                            if let error = error.baseLeoError {
                                if case .securityError = error.code {
                                    self.tokenManager?.refreshToken()?.subscribe {
                                        token in
                                            attempts -= 1
                                            let failedResult: Result<Response, MoyaError> = .failure(MoyaError.underlying(LeoProviderError.refreshTokenFailed, nil))
                                            if attempts < 0 {
                                                finalCompletion(failedResult)
                                                self.tokenManager?.clearTokensAndHandleLogout()
                                            } else {
                                                //TODO attempts
                                                super.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
                                                    finalCompletion(result)
                                                })
                                            }
                                        }.disposed(by: self.disposeBag)
                                }
                            } else {
                                completion(result)
                            }
                        }
                    } else {
                        completion(result)
                    }
                }
        })
    }
}

