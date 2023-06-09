// AvatarService.swift
//
// Copyright © 2023 Stepstone. All rights reserved.

import Foundation
import Combine
import UIKit

enum AvatarServiceError: Error, LocalizedError {
    case urlError(URLError)
    case responseError(Int)
    case decodingError(DecodingError)
    case anyError
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .responseError(let error):
            return "Bad response code: \(error)"
        case .decodingError(let error):
            return error.localizedDescription
        case .anyError:
            return "unknown error has occured"
        }
    }
}

protocol AvatarService {
    func FetchData<T: Codable>(from endpoint: String) -> Future<T, AvatarServiceError>
}

