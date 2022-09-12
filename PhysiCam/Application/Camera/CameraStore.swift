import UIKit
import ComposableArchitecture
import RxSwift

struct CameraState: Equatable {
    var isTaken = false
    var imageData = Data(count: 0)
    var image: UIImage?
    var previewLayer: CALayer?
}

enum CameraAction: Equatable {
    // MARK: From System:
    case ready
    case dismissing
    
    // MARK: From User:
    case userPressedCapture
    
    // MARK: From Env:
    case cameraService(CameraService.DelegateEvent)
}

struct CameraEnvironment {
    var mainQueue: SchedulerType
    var backgroundQueue: SchedulerType
    var service: CameraService
}

let cameraReducer = Reducer<CameraState, CameraAction, CameraEnvironment> { state, action, environment in
    switch action {
    case .ready:
        return Effect.concatenate(
            environment.service.prepare,
            environment.service.start
                .subscribeOn(environment.backgroundQueue)
                .eraseToEffect()
                .observeOn(environment.mainQueue)
                .eraseToEffect()
                .fireAndForget()
        ).map { .cameraService($0) }
    case .dismissing:
        return environment.service.quit.fireAndForget()
    case .userPressedCapture:
        return environment.service.capture.map { .cameraService($0) }
    case let .cameraService(.servePreview(layer)):
        state.previewLayer = layer
        return .none
    case let .cameraService(.photoTaken(imageData)):
        state.imageData = imageData
        state.isTaken.toggle()
        return .none
    default:
        return .none
    }
}
