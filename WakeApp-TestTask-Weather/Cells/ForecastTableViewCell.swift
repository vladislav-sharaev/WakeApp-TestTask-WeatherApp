//
//  ForecastTableViewCell.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/31/20.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    var component: Component!
    var timeOfDay: TimeOfDay!

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config() {
        setTextColor()
        dateLabel.text = component.dateTime
        descriptLabel.text = component.descript
        tempLabel.text = R.string.localization.fromWord() + String(component.minTemp) + R.string.localization.toWord() + String(component.maxTemp) + R.string.localization.degreeCelsius()
        guard let data = component.icon else { return }
        iconView.image = UIImage(data: data)
    }
    
    private func setTextColor() {
        switch timeOfDay {
        case .day:
            dateLabel.textColor = .black
            tempLabel.textColor = .black
            descriptLabel.textColor = .black
        default:
            dateLabel.textColor = .white
            tempLabel.textColor = .white
            descriptLabel.textColor = .white
        }
    }
}
