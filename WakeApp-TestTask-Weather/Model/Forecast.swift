//
//  Forecast.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/30/20.
//

import Foundation
import UIKit

//For current weather
struct CurrentWeather: Codable {    
    let data: [CurrentWeatherData]
}

struct CurrentWeatherData: Codable {
    let city_name: String
    let temp: Double
    let weather: WeatherComponent
    let pod: String
}

struct WeatherComponent: Codable {
    let description: String
    let icon: String
}

//For many days. 16
struct ManyDaysWeather: Codable {
    let data: [ManyDaysWeatherData]
}

struct ManyDaysWeatherData: Codable {
    let max_temp: Double
    let low_temp: Double
    let datetime: String
    let weather: WeatherComponent
}
