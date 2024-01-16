//
//  UsageAppTVC.swift
//  OhanaTestApp
//
//  Created by Konstantin Bondar on 16.01.2024.
//

import UIKit

struct UsageAppData {
    var appName: String
    var timeSpent: TimeSpent
}

class UsageAppTVC: UITableViewCell {
    
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var lineWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineContainerView: UIView!
    @IBOutlet weak var timeSpentLabel: UILabel!
    
    func setupView(with data: UsageAppData) {
        appNameLabel.text = data.appName
        timeSpentLabel.text = data.timeSpent.hoursString()
    }
}

