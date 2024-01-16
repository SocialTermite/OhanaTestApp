//
//  UsageAnalyticsViewController.swift
//  OhanaTestApp
//
//  Created by Konstantin Bondar on 16.01.2024.
//

import UIKit

enum UsagePeriod {
    case daily
    case weekly
}

enum AppType: String {
    case social
    case games
    case education
    case productivity
    case messaging
    case other
}

struct App {
    let name: String
    let type: AppType
}

struct TimeSpent {
    let seconds: Int
    
    func hoursNumbersString() -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        return String(format: "%02d:%02d", hours, minutes)
    }
    
    func hoursString() -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        return String(format: "%01dh %01dm", hours, minutes)
    }
}

struct UsageItem {
    let app: App
    let timeSpent: TimeSpent
    let device: Device
}

struct Device {
    let uuid: UUID = .init()
    let name: String
}

protocol UsageTracker {
    func snapshot(usagePeriod: UsagePeriod, device: Device) -> [UsageItem]
}

enum MockDevices {
    static let iPhoneX = Device(name: "iPhone X")
    static let iPhoneMini = Device(name: "iPhone Mini 12")
    
    static let devices = [iPhoneX, iPhoneMini]
}


class MockUsageTracker: UsageTracker {
  
    
    func snapshot(usagePeriod: UsagePeriod, device: Device) -> [UsageItem] {
        let iPhoneX = MockDevices.iPhoneX
        let iPhoneMini = MockDevices.iPhoneMini
        return [
            .init(app: .init(name: "Instagram", type: .social), timeSpent: .init(seconds: 30600), device: iPhoneX),
            .init(app: .init(name: "TikTok", type: .social), timeSpent: .init(seconds: 22000), device: iPhoneX),
            .init(app: .init(name: "Minecraft", type: .games), timeSpent: .init(seconds: 46000), device: iPhoneX),
            .init(app: .init(name: "Roblox", type: .games), timeSpent: .init(seconds: 12400), device: iPhoneX),
            .init(app: .init(name: "Youtube", type: .social), timeSpent: .init(seconds: 21900), device: iPhoneX),
            .init(app: .init(name: "Dictionary", type: .education), timeSpent: .init(seconds: 1600), device: iPhoneX),
            .init(app: .init(name: "WWDC", type: .education), timeSpent: .init(seconds: 10600), device: iPhoneX),
            .init(app: .init(name: "Messanger", type: .messaging), timeSpent: .init(seconds: 1600), device: iPhoneX),
            .init(app: .init(name: "Spark", type: .productivity), timeSpent: .init(seconds: 1500), device: iPhoneX),
//            
//                .init(app: .init(name: "Instagram", type: .social), timeSpent: .init(seconds: 20600), device: iPhoneMini),
//            .init(app: .init(name: "TikTok", type: .social), timeSpent: .init(seconds: 32000), device: iPhoneMini),
//            .init(app: .init(name: "Minecraft", type: .games), timeSpent: .init(seconds: 56000), device: iPhoneMini),
//            .init(app: .init(name: "Roblox", type: .games), timeSpent: .init(seconds: 12400), device: iPhoneMini),
//            .init(app: .init(name: "Youtube", type: .social), timeSpent: .init(seconds: 1900), device: iPhoneMini),
//            .init(app: .init(name: "Dictionary", type: .education), timeSpent: .init(seconds: 11600), device: iPhoneMini),
//            .init(app: .init(name: "WWDC", type: .education), timeSpent: .init(seconds: 1600), device: iPhoneMini),
//            .init(app: .init(name: "Messanger", type: .messaging), timeSpent: .init(seconds: 16300), device: iPhoneMini),
//            .init(app: .init(name: "Spark", type: .productivity), timeSpent: .init(seconds: 13500), device: iPhoneMini),
        ]
    }
}

class UsageAnalyticsViewModel {
    private var usageItems: [UsageItem] = []
    private var usageTracker: UsageTracker
    
    private(set) var itemsByType: [ItemsByType] = []
    private(set) var itemsByApp: [ItemsByApp] = []
    
    
    private(set) var usagePeriod: UsagePeriod = .weekly {
        didSet {
            loadAnalytics()
        }
    }
    private(set) var device: Device = MockDevices.iPhoneX {
        didSet {
            loadAnalytics()
        }
    }
    
    struct ItemsByType {
        var type: AppType
        var apps: [App]
        var timeSpent: TimeSpent
        var percent: Int
    }
    
    struct ItemsByApp {
        var app: App
        var timeSpent: TimeSpent
    }
    
    var updateUI: (() -> Void)?
    
    init(usageTracker: UsageTracker = MockUsageTracker()) {
        self.usageTracker = usageTracker
    }
    
    func loadAnalytics() {
        self.usageItems = usageTracker.snapshot(usagePeriod: usagePeriod, device: device)
        
        itemsByType = createItemsByType(from: self.usageItems).sorted(by: { $0.timeSpent.seconds > $1.timeSpent.seconds })
        itemsByApp = createItemsByApp(from: self.usageItems).sorted(by: { $0.timeSpent.seconds > $1.timeSpent.seconds })
        updateUI?()
    }
    
    var devices: [Device] {
        MockDevices.devices
    }
    
    func deviceChange(to device: Device) {
        self.device = device
    }
    
    func periodChanged() {
        self.usagePeriod = usagePeriod == .daily ? .weekly : .daily
    }
    
    private func createItemsByType(from items: [UsageItem]) -> [ItemsByType] {
        let totalTime = items.map { $0.timeSpent.seconds }.reduce(0, +)
        var itemsByType: [AppType: [UsageItem]] = [:]
        for item in items {
            if itemsByType[item.app.type] == nil {
                itemsByType[item.app.type] = [item]
            } else {
                itemsByType[item.app.type]?.append(item)
            }
        }
        var result: [ItemsByType] = []
        for type in itemsByType.keys {
            guard let items = itemsByType[type] else { continue }
            let typeTotalTime = items.map { $0.timeSpent.seconds }.reduce(0, +)
            result.append(.init(type: type, apps: items.map { $0.app }, timeSpent: .init(seconds: typeTotalTime),
                                percent: Int(Double(typeTotalTime) / Double(totalTime) * 100.0)))
        }
        
        return result
    }
    
    private func createItemsByApp(from items: [UsageItem]) -> [ItemsByApp] {
        
        return items.map { .init(app: $0.app, timeSpent: $0.timeSpent) }
    }
}

class UsageAnalyticsViewController: UIViewController {
    var viewModel: UsageAnalyticsViewModel? = .init()
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var changePeriodButton: UIBarButtonItem!
    @IBOutlet weak var deviceDropdownButtonView: UIView!
    
    @IBOutlet weak var previousTimeItemButton: UIButton!
    @IBOutlet weak var nextTimeItemButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupTableView()
        viewModel?.loadAnalytics()
    }
    
    private func setupViews() {
        let makeBorder: ((UIView) -> Void) = {
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        makeBorder(deviceDropdownButtonView)
        makeBorder(previousTimeItemButton)
        makeBorder(nextTimeItemButton)
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    @IBAction func changeDevicePressed(_ sender: Any) {
        
    }
    @IBAction func changePeriodPressed(_ sender: Any) {
    }
}

extension UsageAnalyticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let typeCell = tableView.dequeueReusableCell(withIdentifier: "UsageTypeTVC", for: indexPath) as? UsageTypeTVC,
               let item = viewModel?.itemsByType[safe: indexPath.row] {
                typeCell.setupView(with: .init(type: item.type, name: item.type.rawValue.capitalized, appsCount: item.apps.count, timeSpent: item.timeSpent, percent: item.percent))
                return typeCell
            }
        } else {
            if let appCell = tableView.dequeueReusableCell(withIdentifier: "UsageAppTVC", for: indexPath) as? UsageAppTVC,
               let item = viewModel?.itemsByApp[safe: indexPath.row] {
                appCell.setupView(with: .init(appName: item.app.name, timeSpent: item.timeSpent))
                return appCell
            }
        }
        
        return .init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel?.itemsByType.count ?? 0
        }
        return viewModel?.itemsByApp.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
        
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
