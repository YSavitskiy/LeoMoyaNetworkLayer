//
//  Error+Leo.swift
//  LeoExample
//
//  Created by Yuriy Savitskiy on 7/26/19.
//  Copyright © 2019 Yuriy Savitskiy. All rights reserved.
//

import Moya

public extension Error {
    static func toLeoError(_ error: Error ) -> ILeoError? {
        return LeoProviderError.toLeoError(error)
    }
    
    func toLeoError() -> ILeoError? {
        return LeoProviderError.toLeoError(self)
    }
}

