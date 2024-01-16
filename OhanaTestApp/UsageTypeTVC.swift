//
//  UsageTypeTVC.swift
//  OhanaTestApp
//
//  Created by Konstantin Bondar on 16.01.2024.
//

import UIKit

struct UsageTypeCellData {
    let type: AppType
    let name: String
    let appsCount: Int
    let timeSpent: TimeSpent
    let percent: Int
}

class UsageTypeTVC: UITableViewCell {
    @IBOutlet weak var colorTypeView: UIView!
    @IBOutlet weak var typeNameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    @IBOutlet weak var appsNumberLabeel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    
    
    func setupView(with data: UsageTypeCellData) {
        colorTypeView.layer.cornerRadius = 3
        colorTypeView.backgroundColor = color(by: data.type)
        typeNameLabel.text = data.name
        timeSpentLabel.text = data.timeSpent.hoursNumbersString()
        
        appsNumberLabeel.text = "\(data.appsCount) Apps"
        percentLabel.text = "\(data.percent)%"
    }
    
    private func color(by type: AppType) -> UIColor {
        switch type {
        case .social:
            return .blue
        case .games:
            return .yellow
        case .education:
            return .brown
        case .productivity:
            return .green
        case .messaging:
            return .cyan
        case .other:
            return .gray
        }
    }
}
