import UIKit
import ThingSmartHomeKit

/// iOS equivalent of Android HomeActivity
/// This view controller manages the home screen with device list and navigation
class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var homeList: [ThingSmartHome] = []
    private var currentHome: ThingSmartHome?
    private var deviceList: [ThingSmartDevice] = []
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let addDeviceButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: nil,
        action: #selector(addDeviceTapped)
    )
    private let settingsButton = UIBarButtonItem(
        barButtonSystemItem: .compose,
        target: nil,
        action: #selector(settingsTapped)
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadHomesAndDevices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Smart Home"
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.rightBarButtonItems = [addDeviceButton, settingsButton]
        addDeviceButton.target = self
        settingsButton.target = self
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeCell")
    }
    
    // MARK: - Data Loading
    private func loadHomesAndDevices() {
        // Load homes
        ThingSmartHomeManager.sharedInstance().getHomeList { [weak self] homes in
            DispatchQueue.main.async {
                self?.homeList = homes ?? []
                if let firstHome = self?.homeList.first {
                    self?.currentHome = firstHome
                    self?.loadDevices(for: firstHome)
                }
                self?.tableView.reloadData()
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Failed to load homes: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func loadDevices(for home: ThingSmartHome) {
        home.getDeviceList { [weak self] devices in
            DispatchQueue.main.async {
                self?.deviceList = devices ?? []
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        } failure: { error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: "Failed to load devices: \(error?.localizedDescription ?? "Unknown error")")
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func refreshData() {
        if let home = currentHome {
            loadDevices(for: home)
        } else {
            loadHomesAndDevices()
        }
    }
    
    // MARK: - Actions
    @objc private func addDeviceTapped() {
        let addDeviceVC = AddDeviceViewController()
        let navController = UINavigationController(rootViewController: addDeviceVC)
        present(navController, animated: true)
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Homes section and Devices section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return homeList.count
        case 1: return deviceList.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
            let home = homeList[indexPath.row]
            cell.configure(with: home, isSelected: home == currentHome)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceTableViewCell
            let device = deviceList[indexPath.row]
            cell.configure(with: device)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Homes"
        case 1: return "Devices"
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let selectedHome = homeList[indexPath.row]
            currentHome = selectedHome
            loadDevices(for: selectedHome)
            tableView.reloadData()
        case 1:
            let device = deviceList[indexPath.row]
            let deviceControlVC = DeviceControlViewController(device: device)
            navigationController?.pushViewController(deviceControlVC, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Custom Table View Cells
class HomeTableViewCell: UITableViewCell {
    private let homeNameLabel = UILabel()
    private let homeIdLabel = UILabel()
    private let selectionIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        homeNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        homeIdLabel.font = UIFont.systemFont(ofSize: 12)
        homeIdLabel.textColor = .secondaryLabel
        
        selectionIndicator.backgroundColor = .systemBlue
        selectionIndicator.layer.cornerRadius = 4
        
        contentView.addSubview(homeNameLabel)
        contentView.addSubview(homeIdLabel)
        contentView.addSubview(selectionIndicator)
        
        homeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        homeIdLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            homeNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            homeNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            homeNameLabel.trailingAnchor.constraint(equalTo: selectionIndicator.leadingAnchor, constant: -8),
            
            homeIdLabel.topAnchor.constraint(equalTo: homeNameLabel.bottomAnchor, constant: 4),
            homeIdLabel.leadingAnchor.constraint(equalTo: homeNameLabel.leadingAnchor),
            homeIdLabel.trailingAnchor.constraint(equalTo: homeNameLabel.trailingAnchor),
            homeIdLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            selectionIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 8),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(with home: ThingSmartHome, isSelected: Bool) {
        homeNameLabel.text = home.name
        homeIdLabel.text = "ID: \(home.homeId)"
        selectionIndicator.isHidden = !isSelected
    }
}

class DeviceTableViewCell: UITableViewCell {
    private let deviceNameLabel = UILabel()
    private let deviceStatusLabel = UILabel()
    private let deviceIconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        deviceNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        deviceStatusLabel.font = UIFont.systemFont(ofSize: 12)
        deviceStatusLabel.textColor = .secondaryLabel
        
        deviceIconImageView.contentMode = .scaleAspectFit
        deviceIconImageView.backgroundColor = .systemGray5
        deviceIconImageView.layer.cornerRadius = 20
        
        contentView.addSubview(deviceIconImageView)
        contentView.addSubview(deviceNameLabel)
        contentView.addSubview(deviceStatusLabel)
        
        deviceIconImageView.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deviceIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deviceIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deviceIconImageView.widthAnchor.constraint(equalToConstant: 40),
            deviceIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            deviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            deviceStatusLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 4),
            deviceStatusLabel.leadingAnchor.constraint(equalTo: deviceNameLabel.leadingAnchor),
            deviceStatusLabel.trailingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor),
            deviceStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with device: ThingSmartDevice) {
        deviceNameLabel.text = device.name
        deviceStatusLabel.text = device.isOnline ? "Online" : "Offline"
        deviceStatusLabel.textColor = device.isOnline ? .systemGreen : .systemRed
        
        // Set device icon (you can customize this based on device type)
        deviceIconImageView.image = UIImage(systemName: "house")
    }
}
