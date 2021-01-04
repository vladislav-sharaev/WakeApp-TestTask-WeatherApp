//
//  WeatherStorageCore.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/30/20.
//

import Foundation
import RealmSwift

class WeatherStorageCore {
    var realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    lazy var weatherObjects: Results<WeatherObject> = realm.objects(WeatherObject.self)
    
    func getWeatherObjectByID(cityID: String) -> WeatherObject? {
        return weatherObjects.first { $0.cityID == cityID }
    }
    
    func getWeatherObjects() -> [WeatherObject] {
        return Array(weatherObjects)
    }
    
    func saveWeatherObject(_ weatherObject: WeatherObject) {
        if !checkAdded(weatherObject) {
            try? realm.write {
                realm.add(weatherObject)
            }
        }
    }
    
    private func checkAdded(_ weatherObject: WeatherObject) -> Bool {
        for element in weatherObjects {
            if element.cityName == weatherObject.cityName {
                return true
            }
        }
        return false
    }
    
    func deleteWeatherObject(_ weatherObject: WeatherObject) {
        try? realm.write {
            realm.delete(weatherObject)
        }
    }
    
    func clearWeatherObjects() {
        try? realm.write {
            realm.delete(weatherObjects)
        }
    }
}
