//
//  LeoProvider.swift
//  LeoExample
//
//  Created by Yuriy Savitskiy on 7/25/19.
//  Copyright © 2019 Yuriy Savitskiy. All rights reserved.
//

import Foundation
import Moya

open class LeoProvider<T:TargetType>: MoyaProvider<T> {
    public init(tokenManager:ILeoTokenManager?, mockType: LeoMock = .none, plugins: [PluginType] = [] ) {
        var mockClosure: StubClosure
        switch mockType {
            case LeoMock.none:
                mockClosure = MoyaProvider<T>.neverStub
            case LeoMock.immediately:
                mockClosure = MoyaProvider<T>.immediatelyStub
            case LeoMock.delay(let seconds):
                mockClosure = MoyaProvider<T>.delayedStub(seconds)
        }
        
        var leoPlugins:[PluginType] = []
        
        if let tokenManager = tokenManager {
            let accessPlugin = AccessTokenPlugin(tokenClosure: tokenManager.getAccessToken)
            leoPlugins.append(accessPlugin)
        }
        
        let leoPlugin = LeoPlugin(tokenManager: tokenManager)
        leoPlugins.append(leoPlugin)
        
        super.init(stubClosure: mockClosure, plugins: leoPlugins + plugins)
    }
}
