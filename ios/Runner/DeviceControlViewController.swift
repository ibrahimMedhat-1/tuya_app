import UIKit
import ThingSmartHomeKit

/// iOS equivalent of Android DeviceControlActivity
/// This view controller manages individual device control and monitoring
class DeviceControlViewController: UIViewController {
    
    // MARK: - Properties
    private let device: ThingSmartDevice
    private var deviceDataPoints: [String: Any] = [:]
    private var isDeviceOnline = false
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let deviceInfoView = UIView()
    private let deviceNameLabel = UILabel()
    private let deviceStatusLabel = UILabel()
    private let deviceIconImageView = UIImageView()
    private let controlStackView = UIStackView()
    private let refreshButton = UIBarButtonItem(
        barButtonSystemItem: .refresh,
        target: nil,
        action: #selector(refreshDeviceData)
    )
    
    // MARK: - Initialization
    init(device: ThingSmartDevice) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDeviceInfo()
        loadDeviceData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDeviceData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = device.name
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.rightBarButtonItem = refreshButton
        refreshButton.target = self
        
        setupScrollView()
        setupDeviceInfoView()
        setupControlStackView()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupDeviceInfoView() {
        deviceInfoView.backgroundColor = .secondarySystemBackground
        deviceInfoView.layer.cornerRadius = 12
        deviceInfoView.layer.masksToBounds = true
        
        contentView.addSubview(deviceInfoView)
        deviceInfoView.addSubview(deviceIconImageView)
        deviceInfoView.addSubview(deviceNameLabel)
        deviceInfoView.addSubview(deviceStatusLabel)
        
        deviceInfoView.translatesAutoresizingMaskIntoConstraints = false
        deviceIconImageView.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure labels
        deviceNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        deviceNameLabel.textAlignment = .center
        deviceStatusLabel.font = UIFont.systemFont(ofSize: 16)
        deviceStatusLabel.textAlignment = .center
        
        // Configure icon
        deviceIconImageView.contentMode = .scaleAspectFit
        deviceIconImageView.backgroundColor = .systemGray5
        deviceIconImageView.layer.cornerRadius = 30
        
        NSLayoutConstraint.activate([
            deviceInfoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            deviceInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deviceInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deviceInfoView.heightAnchor.constraint(equalToConstant: 120),
            
            deviceIconImageView.topAnchor.constraint(equalTo: deviceInfoView.topAnchor, constant: 16),
            deviceIconImageView.centerXAnchor.constraint(equalTo: deviceInfoView.centerXAnchor),
            deviceIconImageView.widthAnchor.constraint(equalToConstant: 60),
            deviceIconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            deviceNameLabel.topAnchor.constraint(equalTo: deviceIconImageView.bottomAnchor, constant: 8),
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceInfoView.leadingAnchor, constant: 16),
            deviceNameLabel.trailingAnchor.constraint(equalTo: deviceInfoView.trailingAnchor, constant: -16),
            
            deviceStatusLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 4),
            deviceStatusLabel.leadingAnchor.constraint(equalTo: deviceNameLabel.leadingAnchor),
            deviceStatusLabel.trailingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor),
            deviceStatusLabel.bottomAnchor.constraint(lessThanOrEqualTo: deviceInfoView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupControlStackView() {
        controlStackView.axis = .vertical
        controlStackView.spacing = 16
        controlStackView.alignment = .fill
        controlStackView.distribution = .fillEqually
        
        contentView.addSubview(controlStackView)
        controlStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            controlStackView.topAnchor.constraint(equalTo: deviceInfoView.bottomAnchor, constant: 24),
            controlStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            controlStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            controlStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupDeviceInfo() {
        deviceNameLabel.text = device.name
        deviceIconImageView.image = UIImage(systemName: "house")
        updateDeviceStatus()
    }
    
    private func updateDeviceStatus() {
        isDeviceOnline = device.isOnline
        deviceStatusLabel.text = isDeviceOnline ? "Online" : "Offline"
        deviceStatusLabel.textColor = isDeviceOnline ? .systemGreen : .systemRed
    }
    
    // MARK: - Data Loading
    private func loadDeviceData() {
        // Load device data points
        device.publishDps(deviceDataPoints) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.updateControlUI()
                } else {
                    self?.showAlert(title: "Error", message: "Failed to load device data")
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: "Failed to load device data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @objc private func refreshDeviceData() {
        loadDeviceData()
        updateDeviceStatus()
    }
    
    // MARK: - Control UI
    private func updateControlUI() {
        // Clear existing controls
        controlStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add controls based on device type and data points
        addPowerControl()
        addBrightnessControl()
        addColorControl()
        addTemperatureControl()
        addCustomControls()
    }
    
    private func addPowerControl() {
        let powerControlView = createControlView(title: "Power", icon: "power")
        let powerSwitch = UISwitch()
        powerSwitch.isOn = deviceDataPoints["1"] as? Bool ?? false
        powerSwitch.addTarget(self, action: #selector(powerSwitchChanged(_:)), for: .valueChanged)
        
        powerControlView.addSubview(powerSwitch)
        powerSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            powerSwitch.centerYAnchor.constraint(equalTo: powerControlView.centerYAnchor),
            powerSwitch.trailingAnchor.constraint(equalTo: powerControlView.trailingAnchor, constant: -16)
        ])
        
        controlStackView.addArrangedSubview(powerControlView)
    }
    
    private func addBrightnessControl() {
        let brightnessControlView = createControlView(title: "Brightness", icon: "sun.max")
        let brightnessSlider = UISlider()
        brightnessSlider.minimumValue = 0
        brightnessSlider.maximumValue = 100
        brightnessSlider.value = Float(deviceDataPoints["2"] as? Int ?? 50)
        brightnessSlider.addTarget(self, action: #selector(brightnessSliderChanged(_:)), for: .valueChanged)
        
        brightnessControlView.addSubview(brightnessSlider)
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            brightnessSlider.centerYAnchor.constraint(equalTo: brightnessControlView.centerYAnchor),
            brightnessSlider.leadingAnchor.constraint(equalTo: brightnessControlView.leadingAnchor, constant: 60),
            brightnessSlider.trailingAnchor.constraint(equalTo: brightnessControlView.trailingAnchor, constant: -16)
        ])
        
        controlStackView.addArrangedSubview(brightnessControlView)
    }
    
    private func addColorControl() {
        let colorControlView = createControlView(title: "Color", icon: "paintpalette")
        let colorButton = UIButton(type: .system)
        colorButton.setTitle("Choose Color", for: .normal)
        colorButton.backgroundColor = .systemBlue
        colorButton.layer.cornerRadius = 8
        colorButton.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        
        colorControlView.addSubview(colorButton)
        colorButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorButton.centerYAnchor.constraint(equalTo: colorControlView.centerYAnchor),
            colorButton.trailingAnchor.constraint(equalTo: colorControlView.trailingAnchor, constant: -16),
            colorButton.widthAnchor.constraint(equalToConstant: 120),
            colorButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        controlStackView.addArrangedSubview(colorControlView)
    }
    
    private func addTemperatureControl() {
        let tempControlView = createControlView(title: "Temperature", icon: "thermometer")
        let tempLabel = UILabel()
        tempLabel.text = "\(deviceDataPoints["3"] as? Int ?? 20)°C"
        tempLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        tempControlView.addSubview(tempLabel)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tempLabel.centerYAnchor.constraint(equalTo: tempControlView.centerYAnchor),
            tempLabel.trailingAnchor.constraint(equalTo: tempControlView.trailingAnchor, constant: -16)
        ])
        
        controlStackView.addArrangedSubview(tempControlView)
    }
    
    private func addCustomControls() {
        // Add custom controls based on device capabilities
        for (key, value) in deviceDataPoints {
            if !["1", "2", "3"].contains(key) {
                let customControlView = createControlView(title: "Control \(key)", icon: "slider.horizontal.3")
                let valueLabel = UILabel()
                valueLabel.text = "\(value)"
                valueLabel.font = UIFont.systemFont(ofSize: 14)
                valueLabel.textColor = .secondaryLabel
                
                customControlView.addSubview(valueLabel)
                valueLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    valueLabel.centerYAnchor.constraint(equalTo: customControlView.centerYAnchor),
                    valueLabel.trailingAnchor.constraint(equalTo: customControlView.trailingAnchor, constant: -16)
                ])
                
                controlStackView.addArrangedSubview(customControlView)
            }
        }
    }
    
    private func createControlView(title: String, icon: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    // MARK: - Actions
    @objc private func powerSwitchChanged(_ sender: UISwitch) {
        let dps = ["1": sender.isOn]
        device.publishDps(dps) { success in
            DispatchQueue.main.async {
                if !success {
                    self.showAlert(title: "Error", message: "Failed to update power state")
                    sender.setOn(!sender.isOn, animated: true)
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Failed to update power state: \(error?.localizedDescription ?? "Unknown error")")
                sender.setOn(!sender.isOn, animated: true)
            }
        }
    }
    
    @objc private func brightnessSliderChanged(_ sender: UISlider) {
        let dps = ["2": Int(sender.value)]
        device.publishDps(dps) { success in
            if !success {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to update brightness")
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Failed to update brightness: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @objc private func colorButtonTapped() {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIColorPickerViewControllerDelegate
extension DeviceControlViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        // Convert color to HSV for Tuya devices
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let hsv = [
            "h": Int(hue * 360),
            "s": Int(saturation * 100),
            "v": Int(brightness * 100)
        ]
        
        device.publishDps(hsv) { success in
            if !success {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to update color")
                }
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Failed to update color: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
