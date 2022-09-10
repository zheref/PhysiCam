import UIKit

protocol Alertable {
    func alert(withMessage message: String)
}

extension Alertable where Self: UIViewController {
    func alert(withMessage message: String) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertVC, animated: true)
    }
}
