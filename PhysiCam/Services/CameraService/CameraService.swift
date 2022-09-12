import Foundation
import AVFoundation
import ComposableArchitecture
import RxSwift

enum CameraServiceError : Error {
    case unableToSetupCameraSession
    
    var localizedDescription: String {
        switch self {
        case .unableToSetupCameraSession:
            return "Unable to setup camera session."
        }
    }
}

struct CameraService {
    
    enum DelegateEvent: Equatable {
        case photoTaken(Data)
        case servePreview(CALayer)
        case throwError(CameraServiceError)
    }
    
    var prepare: Effect<DelegateEvent>
    var quit: Effect<Never>
    
    var start: Effect<Never>
    var stop: Effect<Never>
    
    var capture: Effect<DelegateEvent>
    
}
