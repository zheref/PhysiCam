import UIKit
import SnapKit

class TakeViewController: UIViewController {
    
    var cameraController: CameraController!
    
    static func make(withCameraController cameraController: CameraController) -> TakeViewController {
        let controller = TakeViewController()
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

}
