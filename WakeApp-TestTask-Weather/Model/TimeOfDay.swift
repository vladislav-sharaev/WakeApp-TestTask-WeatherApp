//
//  TimeOfDay.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/30/20.
//

import Foundation
import UIKit

enum TimeOfDay: String {
    case day = "d"
    case night = "n"
    
    func getPicture() -> UIImage {
        switch self {
        case .day:
            return R.image.day()!
        default:
            return R.image.night()!
        }
    }
}
