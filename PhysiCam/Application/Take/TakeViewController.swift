import UIKit
import SnapKit
import ComposableArchitecture
import RxSwift

class TakeViewController: UIViewController, Loggable {
    
    static var logCategory: String { String(describing: Self.self) }
    
    var cameraController: CameraController!
    
    static func make(withCameraService cameraService: CameraService) -> TakeViewController {
        let controller = TakeViewController()
        
        let cameraController = CameraController(store: Store(
            initialState: CameraState(),
            reducer: cameraReducer,
            environment: CameraEnvironment(mainQueue: MainScheduler.instance,
                                           backgroundQueue: ConcurrentDispatchQueueScheduler(queue: .global()),
                                           service: cameraService)
        ))
        
        controller.cameraController = cameraController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        addChild(cameraController)
        view.addSubview(cameraController.view)
        cameraController.view.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    private func promptForName() {
        let alert = UIAlertController(title: "Name of the file",
                                      message: "What name would you give to this file?",
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "File name"
            $0.isSecureTextEntry = false
        }
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            let tf = alert.textFields?.first as? UITextField
            Self.logger.log("Got file name: \(tf?.text ?? "<nothing>")")
        })
        
        present(alert, animated: true)
    }

}
