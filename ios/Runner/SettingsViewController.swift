import UIKit
import ThingSmartHomeKit

/// iOS equivalent of Android SettingsActivity
/// This view controller manages app settings and user preferences
class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private var currentUser: ThingSmartUser?
    private var homeList: [ThingSmartHome] = []
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
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
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        currentUser = ThingSmartUser.sharedInstance()
        loadHomes()
    }
    
    private func loadHomes() {
        ThingSmartHomeManager.sharedInstance().getHomeList { [weak self] homes in
            DispatchQueue.main.async {
                self?.homeList = homes ?? []
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: "Failed to load homes: \(error?.localizedDescription ?? "Unknown error")")
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func refreshData() {
        loadHomes()
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // User Info, Homes, App Settings, Account
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // User Info
        case 1: return homeList.count // Homes
        case 2: return 3 // App Settings
        case 3: return 2 // Account Actions
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SettingsCell")
        
        switch indexPath.section {
        case 0: // User Info
            cell.textLabel?.text = "User Information"
            cell.detailTextLabel?.text = currentUser?.userName ?? "Not logged in"
            cell.accessoryType = .disclosureIndicator
            
        case 1: // Homes
            let home = homeList[indexPath.row]
            cell.textLabel?.text = home.name
            cell.detailTextLabel?.text = "ID: \(home.homeId)"
            cell.accessoryType = .disclosureIndicator
            
        case 2: // App Settings
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Notifications"
                cell.detailTextLabel?.text = "Manage push notifications"
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.textLabel?.text = "Privacy"
                cell.detailTextLabel?.text = "Privacy settings and permissions"
                cell.accessoryType = .disclosureIndicator
            case 2:
                cell.textLabel?.text = "About"
                cell.detailTextLabel?.text = "App version and information"
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
            
        case 3: // Account Actions
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Change Password"
                cell.textLabel?.textColor = .systemBlue
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.textLabel?.text = "Logout"
                cell.textLabel?.textColor = .systemRed
                cell.accessoryType = .none
            default:
                break
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "User Information"
        case 1: return "Homes"
        case 2: return "App Settings"
        case 3: return "Account"
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // User Info
            showUserInfo()
            
        case 1: // Homes
            let home = homeList[indexPath.row]
            showHomeDetails(home)
            
        case 2: // App Settings
            switch indexPath.row {
            case 0: showNotificationSettings()
            case 1: showPrivacySettings()
            case 2: showAbout()
            default: break
            }
            
        case 3: // Account Actions
            switch indexPath.row {
            case 0: showChangePassword()
            case 1: showLogoutConfirmation()
            default: break
            }
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Action Methods
extension SettingsViewController {
    private func showUserInfo() {
        let userInfoVC = UserInfoViewController()
        let navController = UINavigationController(rootViewController: userInfoVC)
        present(navController, animated: true)
    }
    
    private func showHomeDetails(_ home: ThingSmartHome) {
        let homeDetailsVC = HomeDetailsViewController(home: home)
        navigationController?.pushViewController(homeDetailsVC, animated: true)
    }
    
    private func showNotificationSettings() {
        let notificationVC = NotificationSettingsViewController()
        let navController = UINavigationController(rootViewController: notificationVC)
        present(navController, animated: true)
    }
    
    private func showPrivacySettings() {
        let privacyVC = PrivacySettingsViewController()
        let navController = UINavigationController(rootViewController: privacyVC)
        present(navController, animated: true)
    }
    
    private func showAbout() {
        let aboutVC = AboutViewController()
        let navController = UINavigationController(rootViewController: aboutVC)
        present(navController, animated: true)
    }
    
    private func showChangePassword() {
        let changePasswordVC = ChangePasswordViewController()
        let navController = UINavigationController(rootViewController: changePasswordVC)
        present(navController, animated: true)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        ThingSmartUser.sharedInstance().logout(success: { [weak self] in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: "Logged out successfully") {
                    self?.dismiss(animated: true)
                }
            }
        }, failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: "Logout failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        })
    }
}

// MARK: - Supporting View Controllers
class UserInfoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Information"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        let user = ThingSmartUser.sharedInstance()
        let label = UILabel()
        label.text = "Username: \(user.userName ?? "N/A")\nUser ID: \(user.uid ?? "N/A")"
        label.numberOfLines = 0
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

class HomeDetailsViewController: UIViewController {
    private let home: ThingSmartHome
    
    init(home: ThingSmartHome) {
        self.home = home
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = home.name
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Home ID: \(home.homeId)\nHome Name: \(home.name)"
        label.numberOfLines = 0
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

class NotificationSettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        let label = UILabel()
        label.text = "Notification settings will be implemented here"
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

class PrivacySettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privacy"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        let label = UILabel()
        label.text = "Privacy settings will be implemented here"
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

class AboutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        let label = UILabel()
        label.text = "Smart Home Tuya\nVersion 1.0.0\n\nBuilt with Flutter and Tuya SDK"
        label.numberOfLines = 0
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

class ChangePasswordViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Change Password"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        let label = UILabel()
        label.text = "Change password functionality will be implemented here"
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
