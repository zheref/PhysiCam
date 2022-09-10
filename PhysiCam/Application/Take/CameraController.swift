import UIKit
import SnapKit
import AVFoundation

class CameraController: UIViewController, Loggable, Alertable {
    
    static var logCategory: String { String(describing: Self.self) }
    
    var queue = DispatchQueue(label: "physiCamera")
    
    let captureSession = AVCaptureSession()
    
    lazy var captureDevice: AVCaptureDevice! = {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTelephotoCamera, .builtInUltraWideCamera, .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .back
        ).devices.first
    }()
    
    var deviceInput: AVCaptureDeviceInput!
    var imageOutput: AVCapturePhotoOutput!
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.layer.frame
        return layer
    }()
    
    var stillImage: UIImage?
    
    let captureButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        readyStart()
    }
    
    private func setup() {
        view.backgroundColor = .darkGray
        view.addSubview(captureButton)
        
        captureButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        setupSession()
    }
    
    private func setupSession() {
        captureSession.sessionPreset = .photo
        
        deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        imageOutput = AVCapturePhotoOutput()
        
        guard let deviceInput = deviceInput else {
            alert(withMessage: "Capture device could not be resolved.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(imageOutput)
        
        guard let previewLayer = previewLayer else {
            Self.logger.error("Could not resolve preview. Found nil at first attempt to use it")
            return
        }
        
        view.layer.addSublayer(previewLayer)
    }
    
    private func readyStart() {
        view.bringSubviewToFront(captureButton)
        
        queue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

}
