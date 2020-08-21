import UIKit

class RecipeDetailsWireframe: RecipeDetailsWireframeProtocol {
    private weak var viewController: UIViewController!
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func close() {
        viewController.navigationController?.popViewController(animated: true)
    }
}
