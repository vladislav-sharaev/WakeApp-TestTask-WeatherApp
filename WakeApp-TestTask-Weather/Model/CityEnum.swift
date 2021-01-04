//
//  Cities.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 1/2/21.
//

import Foundation

enum CityEnum: String {
    case minsk = "Minsk,be"
    case tokyo = "Tokyo"
    case washington = "Washington"
    
    static var allValues: [CityEnum] {
        return [.minsk, .tokyo, .washington]
    }
    
    static var allValuesString: [String] {
        return [CityEnum.minsk.rawValue, CityEnum.tokyo.rawValue, CityEnum.washington.rawValue]
    }
}
