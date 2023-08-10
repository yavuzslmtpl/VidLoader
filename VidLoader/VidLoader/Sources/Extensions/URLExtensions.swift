//
//  URLExtensions.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension URL {    
    func withScheme(scheme: SchemeType?, resolvingAgainstBaseURL: Bool = false) -> URL? {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: resolvingAgainstBaseURL)
        urlComponents?.scheme = scheme?.rawValue
        return urlComponents?.url
    }
}
