//
//  AccountService.swift
//  Example
//
//  Created by Yuriy Savitskiy on 7/24/19.
//  Copyright © 2019 Yuriy Savitskiy. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import LEONetworkLayer


protocol IAccountService {
    var isAuthenticated: Bool { get }
    var logoutHandler: (() -> Void)? { get set }
    func login()
    func signOut()
}

class AccountService: IAccountService {
    private(set) var accountStorage: IAccountStorage
    lazy private var accountProvider = LeoProvider<AuthentificationTarget>(tokenManager: self)
    
    private let loginKey = "login"
    
    var isAuthenticated: Bool {
        return accountStorage.accessToken != nil
    }
        
    func login() {
        accountStorage.accessToken = "test"
    }
    
    var logoutHandler: (() -> Void)?
    
    func signOut() {
        invalidateTokens()
        logoutHandler?()
    }
    
    func invalidateTokens() {
        self.invalidateRefreshToken()
        self.invalidateAccessToken()
    }
    
    func invalidateAccessToken() {
        self.accountStorage.accessToken = nil
    }
    
    func invalidateRefreshToken() {
        self.accountStorage.refreshToken = nil
    }
    
    
    init(accountStorage: IAccountStorage) {
        self.accountStorage = accountStorage
    }
}


extension AccountService: ILeoTokenManager {
    func getAccessToken() -> String {
        return accountStorage.accessToken ?? ""
    }
    
    func getRefreshToken() -> String {
        return accountStorage.refreshToken ?? ""
    }
    
    func refreshToken() -> Single<String> {
        return Single.just("TODO")
    }
    
    func clearTokensAndHandleLogout() {
        signOut()
    }
}
