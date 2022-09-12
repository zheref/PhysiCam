import AVFoundation
import ComposableArchitecture
import RxSwift

extension CameraService {
    static var delegate: Delegate?
    
    class Delegate: NSObject, AVCapturePhotoCaptureDelegate, Loggable {
        
        static var logCategory: String { String(describing: Self.self) }
        
        let observer: AnyObserver<DelegateEvent>
        
        init(observer: AnyObserver<DelegateEvent>) {
            self.observer = observer
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                Self.logger.error("Error while taking photo: \(error.localizedDescription)")
                return
            }
            
            guard let imageData = photo.fileDataRepresentation() else {
                Self.logger.error("Could not retrieve file data representation from taken photo.")
                return
            }
            
            observer.onNext(.photoTaken(imageData))
            observer.onCompleted()
        }
        
    }
}
