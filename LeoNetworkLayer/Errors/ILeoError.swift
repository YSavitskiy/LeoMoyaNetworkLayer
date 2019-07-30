//
//  LeoError.swift
//  LeoExample
//
//  Created by Yuriy Savitskiy on 7/26/19.
//  Copyright © 2019 Yuriy Savitskiy. All rights reserved.
//

import Foundation
import Moya

public protocol ILeoError : Swift.Error {
}

public protocol LeoErrorConverter {
    static func toLeoError(_ error: Error) -> ILeoError?
    static func toLeoError(_ result: Result<Response, MoyaError>) -> ILeoError?
}

public enum LeoProviderError: ILeoError, LeoErrorConverter {
    case simpleError
    case notLeoObject
    case serverError
    case moyaError(MoyaError)
    
    public static func toLeoError(_ result: Result<Response, MoyaError>) -> ILeoError? {
        let result = result
        switch result {
        case .failure(let error):
            return toLeoError(error)
        case .success(_):
            return nil
        }
    }
    
    public static func toLeoError(_ error: Error) -> ILeoError? {
        if let leoError = error as? ILeoError {
            return leoError
        }
        
        if let moyaError = error as? MoyaError {
            if case .underlying(let underlyingError, _) = moyaError {
                if let leoError = underlyingError as? ILeoError {
                    return leoError
                }
            }
            return LeoProviderError.moyaError(moyaError)
        }
        return nil
    }
}



