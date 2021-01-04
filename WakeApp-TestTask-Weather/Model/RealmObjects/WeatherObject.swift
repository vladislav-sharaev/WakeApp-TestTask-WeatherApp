//
//  WeatherObject.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/30/20.
//

import Foundation
import RealmSwift

class WeatherObject: Object {
    @objc dynamic var cityName = ""
    @objc dynamic var temperature = 0.0
    @objc dynamic var pod = "d"
    @objc dynamic var descript = ""
    @objc dynamic var cityID = ""
    let components = List<Component>()
}

class Component: Object {
    @objc dynamic var maxTemp = 0.0
    @objc dynamic var minTemp = 0.0
    @objc dynamic var dateTime = ""
    @objc dynamic var descript = ""
    @objc dynamic var icon: Data? = nil
}
