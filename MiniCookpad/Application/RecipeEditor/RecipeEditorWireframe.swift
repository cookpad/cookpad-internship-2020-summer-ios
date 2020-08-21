import UIKit

final class RecipeEditorWireframe: RecipeEditorWireframeProtocol {
    private weak var viewController: UIViewController!
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func close() {
        viewController.dismiss(animated: true)
    }
}
