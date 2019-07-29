//
//  BaseRequestParameters.swift
//  LeoExample
//
//  Created by Yuriy Savitskiy on 7/29/19.
//  Copyright © 2019 Yuriy Savitskiy. All rights reserved.
//

import Foundation

class BaseRequestParameters: Decodable {
    var platform: String?
    var deviceID: String?
    var versionApp: String?
    var pushDeviceId: String?
}
