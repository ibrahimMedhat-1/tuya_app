import UIKit
import ThingSmartHomeKit
import AVFoundation

/// iOS equivalent of Android AddDeviceActivity
/// This view controller handles device pairing and addition to the home
class AddDeviceViewController: UIViewController {
    
    // MARK: - Properties
    private var currentHome: ThingSmartHome?
    private var pairingDevices: [ThingSmartDevice] = []
    private var isScanning = false
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let scanButton = UIButton(type: .system)
    private let qrCodeButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let statusLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadCurrentHome()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Add Device"
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        setupStatusLabel()
        setupButtons()
        setupActivityIndicator()
    }
    
    private func setupStatusLabel() {
        statusLabel.text = "Tap 'Scan for Devices' to find nearby devices"
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.textColor = .secondaryLabel
        
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupButtons() {
        scanButton.setTitle("Scan for Devices", for: .normal)
        scanButton.backgroundColor = .systemBlue
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.layer.cornerRadius = 8
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        
        qrCodeButton.setTitle("Scan QR Code", for: .normal)
        qrCodeButton.backgroundColor = .systemGreen
        qrCodeButton.setTitleColor(.white, for: .normal)
        qrCodeButton.layer.cornerRadius = 8
        qrCodeButton.addTarget(self, action: #selector(qrCodeButtonTapped), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [scanButton, qrCodeButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DevicePairingTableViewCell.self, forCellReuseIdentifier: "DevicePairingCell")
        tableView.isHidden = true
    }
    
    // MARK: - Data Loading
    private func loadCurrentHome() {
        ThingSmartHomeManager.sharedInstance().getHomeList { [weak self] homes in
            DispatchQueue.main.async {
                self?.currentHome = homes?.first
                if self?.currentHome == nil {
                    self?.showAlert(title: "No Home", message: "Please create a home first before adding devices")
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: "Failed to load homes: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func scanButtonTapped() {
        guard let home = currentHome else {
            showAlert(title: "Error", message: "No home selected")
            return
        }
        
        startDeviceScanning()
    }
    
    @objc private func qrCodeButtonTapped() {
        checkCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.presentQRCodeScanner()
                } else {
                    self?.showAlert(title: "Camera Permission Required", message: "Please enable camera access to scan QR codes")
                }
            }
        }
    }
    
    // MARK: - Device Scanning
    private func startDeviceScanning() {
        guard let home = currentHome else { return }
        
        isScanning = true
        activityIndicator.startAnimating()
        statusLabel.text = "Scanning for devices..."
        scanButton.isEnabled = false
        
        // Start device discovery
        ThingSmartActivator.sharedInstance().startConfigWiFi(withToken: home.homeId) { [weak self] deviceList in
            DispatchQueue.main.async {
                self?.isScanning = false
                self?.activityIndicator.stopAnimating()
                self?.scanButton.isEnabled = true
                
                if let devices = deviceList, !devices.isEmpty {
                    self?.pairingDevices = devices
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                    self?.statusLabel.text = "Found \(devices.count) device(s). Tap to pair."
                } else {
                    self?.statusLabel.text = "No devices found. Make sure devices are in pairing mode."
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isScanning = false
                self?.activityIndicator.stopAnimating()
                self?.scanButton.isEnabled = true
                self?.statusLabel.text = "Scan failed. Please try again."
                self?.showAlert(title: "Scan Error", message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    private func pairDevice(_ device: ThingSmartDevice) {
        guard let home = currentHome else { return }
        
        activityIndicator.startAnimating()
        statusLabel.text = "Pairing device..."
        
        // Add device to home
        home.addHomeDevice(device.devId, name: device.name, success: { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.statusLabel.text = "Device paired successfully!"
                self?.showAlert(title: "Success", message: "Device '\(device.name)' has been added to your home") {
                    self?.dismiss(animated: true)
                }
            }
        }, failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.statusLabel.text = "Pairing failed. Please try again."
                self?.showAlert(title: "Pairing Error", message: error?.localizedDescription ?? "Unknown error")
            }
        })
    }
    
    // MARK: - QR Code Scanning
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func presentQRCodeScanner() {
        let scannerVC = QRCodeScannerViewController()
        scannerVC.delegate = self
        present(scannerVC, animated: true)
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension AddDeviceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pairingDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DevicePairingCell", for: indexPath) as! DevicePairingTableViewCell
        let device = pairingDevices[indexPath.row]
        cell.configure(with: device)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AddDeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = pairingDevices[indexPath.row]
        pairDevice(device)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - QRCodeScannerDelegate
extension AddDeviceViewController: QRCodeScannerDelegate {
    func qrCodeScanner(_ scanner: QRCodeScannerViewController, didScanCode code: String) {
        scanner.dismiss(animated: true) { [weak self] in
            // Process QR code and add device
            self?.processQRCode(code)
        }
    }
    
    func qrCodeScannerDidCancel(_ scanner: QRCodeScannerViewController) {
        scanner.dismiss(animated: true)
    }
    
    private func processQRCode(_ code: String) {
        // Parse QR code and extract device information
        // This would typically contain device ID, SSID, password, etc.
        statusLabel.text = "Processing QR code..."
        activityIndicator.startAnimating()
        
        // Parse QR code for device information
        if let deviceInfo = parseQRCode(code) {
            // Start device pairing with QR code information
            pairDeviceFromQRCode(deviceInfo)
        } else {
            // Fallback to manual device addition
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.statusLabel.text = "QR code processed. Please enter device details manually."
                self?.showManualDeviceEntry()
            }
        }
    }
    
    private func parseQRCode(_ code: String) -> [String: String]? {
        // Parse QR code format: "tuya://device?devId=xxx&productId=xxx&name=xxx"
        guard code.hasPrefix("tuya://") else { return nil }
        
        var deviceInfo: [String: String] = [:]
        let components = code.components(separatedBy: "?")
        guard components.count > 1 else { return nil }
        
        let params = components[1].components(separatedBy: "&")
        for param in params {
            let keyValue = param.components(separatedBy: "=")
            if keyValue.count == 2 {
                deviceInfo[keyValue[0]] = keyValue[1]
            }
        }
        
        return deviceInfo.isEmpty ? nil : deviceInfo
    }
    
    private func pairDeviceFromQRCode(_ deviceInfo: [String: String]) {
        guard let home = currentHome,
              let devId = deviceInfo["devId"],
              let productId = deviceInfo["productId"],
              let name = deviceInfo["name"] else {
            activityIndicator.stopAnimating()
            statusLabel.text = "Invalid QR code format"
            return
        }
        
        // Create a mock device for pairing
        let mockDevice = createMockDevice(devId: devId, productId: productId, name: name)
        
        // Add device to home
        home.addHomeDevice(devId, name: name, success: { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.statusLabel.text = "Device '\(name)' paired successfully from QR code!"
                self?.showAlert(title: "Success", message: "Device '\(name)' has been added to your home") {
                    self?.dismiss(animated: true)
                }
            }
        }, failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.statusLabel.text = "QR code pairing failed. Please try again."
                self?.showAlert(title: "Pairing Error", message: error?.localizedDescription ?? "Unknown error")
            }
        })
    }
    
    private func createMockDevice(devId: String, productId: String, name: String) -> ThingSmartDevice {
        // This is a simplified mock - in real implementation, you'd create a proper device object
        // For now, we'll just use the home.addHomeDevice method directly
        return ThingSmartDevice()
    }
    
    private func showManualDeviceEntry() {
        let alert = UIAlertController(title: "Manual Device Entry", message: "Enter device details manually", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Device Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Device ID"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add Device", style: .default) { [weak self] _ in
            guard let nameField = alert.textFields?[0],
                  let idField = alert.textFields?[1],
                  let name = nameField.text, !name.isEmpty,
                  let devId = idField.text, !devId.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter both device name and ID")
                return
            }
            
            self?.pairDeviceFromQRCode([
                "devId": devId,
                "productId": "unknown",
                "name": name
            ])
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Custom Table View Cell
class DevicePairingTableViewCell: UITableViewCell {
    private let deviceIconImageView = UIImageView()
    private let deviceNameLabel = UILabel()
    private let deviceTypeLabel = UILabel()
    private let pairButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        deviceNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        deviceTypeLabel.font = UIFont.systemFont(ofSize: 14)
        deviceTypeLabel.textColor = .secondaryLabel
        
        deviceIconImageView.contentMode = .scaleAspectFit
        deviceIconImageView.backgroundColor = .systemGray5
        deviceIconImageView.layer.cornerRadius = 20
        
        pairButton.setTitle("Pair", for: .normal)
        pairButton.backgroundColor = .systemBlue
        pairButton.setTitleColor(.white, for: .normal)
        pairButton.layer.cornerRadius = 6
        
        contentView.addSubview(deviceIconImageView)
        contentView.addSubview(deviceNameLabel)
        contentView.addSubview(deviceTypeLabel)
        contentView.addSubview(pairButton)
        
        deviceIconImageView.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        pairButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deviceIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deviceIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deviceIconImageView.widthAnchor.constraint(equalToConstant: 40),
            deviceIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            deviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceIconImageView.trailingAnchor, constant: 12),
            deviceNameLabel.trailingAnchor.constraint(equalTo: pairButton.leadingAnchor, constant: -8),
            
            deviceTypeLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 4),
            deviceTypeLabel.leadingAnchor.constraint(equalTo: deviceNameLabel.leadingAnchor),
            deviceTypeLabel.trailingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor),
            deviceTypeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            pairButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pairButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pairButton.widthAnchor.constraint(equalToConstant: 60),
            pairButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with device: ThingSmartDevice) {
        deviceNameLabel.text = device.name
        deviceTypeLabel.text = device.productId
        deviceIconImageView.image = UIImage(systemName: "house")
    }
}

// MARK: - QR Code Scanner Protocol
protocol QRCodeScannerDelegate: AnyObject {
    func qrCodeScanner(_ scanner: QRCodeScannerViewController, didScanCode code: String)
    func qrCodeScannerDidCancel(_ scanner: QRCodeScannerViewController)
}

// MARK: - QR Code Scanner View Controller
class QRCodeScannerViewController: UIViewController {
    weak var delegate: QRCodeScannerDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }
    
    private func setupUI() {
        title = "Scan QR Code"
        view.backgroundColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession?.startRunning()
    }
    
    @objc private func cancelTapped() {
        delegate?.qrCodeScannerDidCancel(self)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            captureSession?.stopRunning()
            delegate?.qrCodeScanner(self, didScanCode: stringValue)
        }
    }
}
