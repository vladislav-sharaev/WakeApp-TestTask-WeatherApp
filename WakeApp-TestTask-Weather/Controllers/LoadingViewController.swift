//
//  ViewController.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/30/20.
//

import UIKit
import RealmSwift

class LoadingViewController: UIViewController {
    
    //MARK: Outlets
    var cities = CityEnum.allValues
    var weatherStorageCore: WeatherStorageCore?
    var counter = 0
    var error: Bool = false
    
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var responseView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configLocalization()
        downloadFromNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.alpha = 1
    }
    
    //MARK: Configs
    private func configLocalization() {
        errorLabel.text = R.string.localization.errorLoadingFromNetworkLabel()
        tryAgainBtn.setTitle(R.string.localization.tryAgainBtn(), for: .normal)
    }
    
    private func getRealm() {
        do {
            let realm = try Realm()
            weatherStorageCore = WeatherStorageCore(realm: realm)
        } catch {
            showRealmError()
        }
    }
    
    //MARK: Update UI
    private func startUpdateUI() {
        DispatchQueue.main.async {
            self.responseView.isHidden = false
            self.errorLabel.isHidden = true
            self.tryAgainBtn.isHidden = true
            self.acitivityIndicator.isHidden = false
            self.acitivityIndicator.startAnimating()
        }
    }
    
    private func showError() {
        DispatchQueue.main.async {
            self.acitivityIndicator.stopAnimating()
            self.responseView.isHidden = true
            self.errorLabel.isHidden = false
            self.tryAgainBtn.isHidden = false
        }
    }
    
    //realm error
    private func showRealmError() {
        showError()
        DispatchQueue.main.async {
            self.errorLabel.text = R.string.localization.realmErrorMessage()
            self.tryAgainBtn.isHidden = true
        }
    }
    
    //MARK: Clear
    private func clearRealm() {
        getRealm()
        weatherStorageCore?.clearWeatherObjects()
    }
    
    private func clearLoadFields() {
        counter = 0
        error = false
    }
    
    //MARK: Download from network
    private func downloadFromNetwork() {
        startUpdateUI()
        clearRealm()
        clearLoadFields()
        let dispatchGroup = DispatchGroup()
        let networkLoader = NetworkLoader()
        
        for city in cities {
            let weather = WeatherObject()
            weather.cityID = city.rawValue
            
            let currentWeatherUrlString = createCurrentUrl(city: city)
            getCurrentWeather(
                networkLoader: networkLoader,
                city: weather,
                dispatchGroup: dispatchGroup,
                constantUrl: currentWeatherUrlString
            )
            
            let manyDaysWeatherUrlString = createManyDaysUrl(city: city)
            getManyDaysWeather(
                networkLoader: networkLoader,
                city: weather,
                dispatchGroup: dispatchGroup,
                constantUrl: manyDaysWeatherUrlString
            )
            
            finishDownload(dispatchGroup: dispatchGroup, city: weather)
        }
    }
    
    private func downloadImage(url: String, completion: @escaping (UIImage?) -> Void) {
        let fullUrl = URL(string: Constants.iconStartPoint + url + Constants.pngFormat)
        guard let finishedURL = fullUrl else { completion(nil) ; return }
        let networkLoader = NetworkLoader()
        networkLoader.downloadImage(url: finishedURL) { (result) in
            switch result {
            case .success(let data):
                completion(UIImage(data: data))
                break
            case .failure:
                completion(nil)
                break
            }
        }
    }
    
    private func getCurrentWeather(networkLoader: NetworkLoader, city: WeatherObject, dispatchGroup: DispatchGroup, constantUrl: String) {
        dispatchGroup.enter()
        networkLoader.loadData(jsonUrlString: constantUrl) { (result: (Result<CurrentWeather, NetworkError>)) in
            switch result {
            case .success(let currentWeather):
                city.cityName = currentWeather.data[0].city_name
                city.pod = currentWeather.data[0].pod
                city.temperature = currentWeather.data[0].temp
                city.descript = currentWeather.data[0].weather.description
            case .failure:
                self.error = true
                self.showError()
                break
            }
            dispatchGroup.leave()
        }
    }
    
    private func getManyDaysWeather(networkLoader: NetworkLoader, city: WeatherObject, dispatchGroup: DispatchGroup, constantUrl: String) {
        dispatchGroup.enter()
        networkLoader.loadData(jsonUrlString: constantUrl) { [weak self] (result: (Result<ManyDaysWeather, NetworkError>)) in
            guard let self = self else { return }
            switch result {
            case .success(let weathers):
                for element in weathers.data {
                    let component = Component()
                    component.dateTime = element.datetime
                    component.maxTemp = element.max_temp
                    component.minTemp = element.low_temp
                    component.descript = element.weather.description
                    dispatchGroup.enter()
                    self.downloadImage(url: element.weather.icon) { (image) in
                        component.icon = image?.pngData()
                        dispatchGroup.leave()
                    }
                    city.components.append(component)
                }
            case .failure:
                self.error = true
                self.showError()
                break
            }
            dispatchGroup.leave()
        }
    }
    
    private func finishDownload(dispatchGroup: DispatchGroup, city: WeatherObject) {
        dispatchGroup.notify(queue: .main) {
            self.weatherStorageCore?.saveWeatherObject(city)
            self.counter += 1
            if self.counter == self.weatherStorageCore?.weatherObjects.count {
                self.presentNewVC()
            }
        }
    }
    
    //creating url
    private func createCurrentUrl(city: CityEnum) -> String {
        var urlString = Constants.currentStartPoint
        urlString += city.rawValue
        urlString += Constants.startApiKey
        urlString += Constants.apiKey
        return urlString
    }
    
    private func createManyDaysUrl(city: CityEnum) -> String {
        var urlString = Constants.manyDaysStartPoint
        urlString += city.rawValue
        urlString += Constants.startApiKey
        urlString += Constants.apiKey
        return urlString
    }
    
    //MARK: Show new VC
    private func presentNewVC() {
        if !error {
            UIView.animate(withDuration: 1.0) {
                self.view.alpha = 0
            } completion: { (status) in
                if status {
                    guard let vc = R.storyboard.main.forecastViewController() else { return }
                    vc.modalPresentationStyle = .fullScreen
                    vc.delegate = self
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }
    }
    
    //MARK: Actions
    @IBAction func tryAgain(_ sender: UIButton) {
        downloadFromNetwork()
    }
}

extension LoadingViewController: ForecastViewControllerDelegate {
    func realmErrorAppeared() {
        showRealmError()
    }
}
