import UIKit
import SnapKit
import RxSwift
import ComposableArchitecture

class CameraController: UIViewController, Loggable, Alertable {
    
    static var logCategory: String { String(describing: Self.self) }
    
    // MARK: - Business
    
    var viewStore: ViewStore<CameraState, CameraAction>
    let bag = DisposeBag()
    
    init(store: Store<CameraState, CameraAction>) {
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewStore.send(.ready)
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
        
        // Shouldn't this be reactive?
        captureButton.addTarget(self, action: #selector(userDidTapCapture), for: .touchUpInside)
        
        viewStore.publisher.previewLayer.subscribe(onNext: { [weak self] layer in
            guard let self = self else { return }
            if let layer = layer {
                layer.frame = self.view.frame
                self.view.layer.addSublayer(layer)
                self.view.bringSubviewToFront(self.captureButton)
            } else {
                Self.logger.error("No layer resolved :(")
            }
        }).disposed(by: bag)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewStore.send(.dismissing)
    }
    
    @objc private func userDidTapCapture() {
        viewStore.send(.userPressedCapture)
    }

}
