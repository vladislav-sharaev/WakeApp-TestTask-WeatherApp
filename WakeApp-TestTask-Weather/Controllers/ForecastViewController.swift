//
//  ForecastViewController.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/31/20.
//

import UIKit
import RealmSwift

protocol ForecastViewControllerDelegate: class {
    func realmErrorAppeared()
}

class ForecastViewController: UIViewController {
    
    //MARK: Outlets
    var weatherStorageCore: WeatherStorageCore?
    var timeOfDay: TimeOfDay = .day
    weak var delegate: ForecastViewControllerDelegate?
    var selectedCity: WeatherObject?
    let topInset: CGFloat = 120.0
    let sixtySeven: CGFloat = 67.0
    let seventyFive: CGFloat = 75
    let eight: CGFloat = 8
    let twenty: CGFloat = 20
    let three: CGFloat = 3
    let eightySix: CGFloat = 86
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cityLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var cityLabelTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appearing()
        config()
    }
    
    //MARK: Configs
    private func config() {
        getRealm()
        configSegmentedControl()
        addTableView()
        setUpUI()
    }
    
    private func getRealm() {
        do {
            let realm = try Realm()
            weatherStorageCore = WeatherStorageCore(realm: realm)
        } catch {
            delegate?.realmErrorAppeared()
            dismiss(animated: true, completion: nil)
        }
    }

    private func configSegmentedControl() {
        segmentedControl.removeAllSegments()
        
        var point = 0
        for element in CityEnum.allValues {
            let someCity = weatherStorageCore?.getWeatherObjectByID(cityID: element.rawValue)
            guard let realCity = someCity else { continue }
            if point == 0 {
                selectedCity = realCity
            }
            segmentedControl.insertSegment(withTitle: realCity.cityName, at: point, animated: false)
            point += 1
        }
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func addTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
    }
    
    private func setUpUI() {
        timeOfDay = TimeOfDay(rawValue: selectedCity!.pod) ?? .day
        backImage.image = timeOfDay.getPicture()
        setColors()
        tableView.reloadData()
        cityLabel.text = selectedCity?.cityName
        tempLabel.text = String(selectedCity?.temperature ?? 0) + R.string.localization.degreeCelsius()
        descriptionLabel.text = selectedCity?.descript
        
    }
    
    private func setColors() {
        switch timeOfDay {
        case .day:
            cityLabel.textColor = .black
            tempLabel.textColor = .black
            descriptionLabel.textColor = .black
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.normal)
        case .night:
            cityLabel.textColor = .white
            tempLabel.textColor = .white
            descriptionLabel.textColor = .white
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)
        }
    }
    
    //Beautiful view appearance
    private func appearing() {
        view.alpha = 0
        UIView.animate(withDuration: 1.0) {
            self.view.alpha = 1
        }
    }
    
    //MARK: Actions
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        let city = CityEnum.allValues[sender.selectedSegmentIndex]
        guard let cityObject = weatherStorageCore?.getWeatherObjectByID(cityID: city.rawValue) else {
            return
        }
        selectedCity = cityObject
        setUpUI()
    }
}

extension ForecastViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCity?.components.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.forecastTableViewCell, for: indexPath) else {
            let cell = UITableViewCell()
            return cell
        }
        cell.timeOfDay = timeOfDay
        cell.component = selectedCity?.components[indexPath.row]
        cell.config()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ForecastViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        if y > sixtySeven {
            cityLabelTopConstraint.constant = y - seventyFive
        } else {
            cityLabelTopConstraint.constant = -eight
        }
        descriptionLabel.alpha = (y - twenty) / 100
        tempLabel.alpha = (y - twenty) / 100
        segmentedControl.alpha = (y - eightySix)  * three / 100
    }
}

