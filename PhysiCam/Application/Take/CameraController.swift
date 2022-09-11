import UIKit
import SnapKit
import AVFoundation

protocol CameraDelegate: AnyObject {
    func didGet(photoWithData data: Data)
}

class CameraController: UIViewController, Loggable, Alertable {
    
    static var logCategory: String { String(describing: Self.self) }
    
    // MARK: - Business
    
    weak var delegate: CameraDelegate?
    
    // MARK: - Operational
    
    var queue = DispatchQueue(label: "physiCamera")
    
    let captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()
    
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
    
    var photoSettings: AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings(format: [
            AVVideoCodecKey: AVVideoCodecType.jpeg
        ])
        settings.isHighResolutionPhotoEnabled = true
        settings.flashMode = .on
        return settings
    }
    
    // MARK: - UI
    
    lazy var previewLayer: CALayer? = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.layer.frame
        return layer
    }()
    
    let captureButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        button.tintColor = .white
        return button
    }()
    
    var stillImage: UIImage?
    
    // MARK: - Lifecycle
    
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
        captureButton.addTarget(self, action: #selector(userDidTapCapture), for: .touchUpInside)
    }
    
    private func setupSession() {
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
    
    @objc private func userDidTapCapture() {
        imageOutput.isHighResolutionCaptureEnabled = true
        imageOutput.capturePhoto(with: photoSettings, delegate: self)
    }

}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            Self.logger.error("Error while capturing photo: \(error.localizedDescription)")
            alert(withMessage: error.localizedDescription)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            Self.logger.error("Could not retrieve file data representation from taken photo.")
            alert(withMessage: "Error fetching photo 😞")
            return
        }
        
        delegate?.didGet(photoWithData: imageData)
//        stillImage = UIImage(data: imageData)
    }
}
