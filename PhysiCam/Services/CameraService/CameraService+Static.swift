import AVFoundation
import ComposableArchitecture
import RxSwift

extension CameraService {
    
    static var session: AVCaptureSession! = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()
    
    static var device: AVCaptureDevice! {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    static var input: AVCaptureDeviceInput!
    static var output: AVCapturePhotoOutput!
    
    static var photoSettings: AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings(format: [
            AVVideoCodecKey: AVVideoCodecType.jpeg
        ])
        settings.isHighResolutionPhotoEnabled = true
        settings.flashMode = .on
        return settings
    }
    
    static let shared = CameraService(
        prepare: .run({ observer in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                guard let previewLayer = setup() else {
                    Self.logger.error("Could not build preview layer.")
                    return Disposables.create()
                }
                observer.onNext(.servePreview(previewLayer))
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { accept in
                    if accept {
                        guard let previewLayer = setup() else {
                            Self.logger.error("Could not build preview layer")
                            return
                        }
                        observer.onNext(.servePreview(previewLayer))
                    } else {
                        Self.logger.error("")
                    }
                })
            case .restricted, .denied:
                break
            @unknown default:
                break
            }
        
            observer.onCompleted()
            return Disposables.create()
        }),
        quit: .run({ observer in
            Self.delegate = nil
            Self.output = nil
            Self.input = nil
            Self.session = nil
            
            observer.onCompleted()
            
            return Disposables.create()
        }),
        start: .run({ observer in
            session.startRunning()
            observer.onCompleted()
            return Disposables.create()
        }),
        stop: .run({ observer in
            session.stopRunning()
            observer.onCompleted()
            return Disposables.create()
        }),
        capture: .run({ observer in
            delegate = Delegate(observer: observer)
            output.capturePhoto(with: photoSettings, delegate: delegate!)
            observer.onCompleted()
            return Disposables.create()
        })
    )
    
    static func setup() -> CALayer? {
        do {
            session.beginConfiguration()
            
            input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }
            
            output = AVCapturePhotoOutput()
            output.isHighResolutionCaptureEnabled = true
            if session.canAddOutput(output) { session.addOutput(output) }
            
            session.commitConfiguration()
            
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            
            return layer
        } catch {
            // Trigger error to observer
            Self.logger.error("Error setting up camera session: \(error.localizedDescription)")
            return nil
        }
    }
    
}
