//
//  NetworkError.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/30/20.
//

import Foundation

enum NetworkError: Error {
    case badURL, requestFailed, mapping, unknown
}
