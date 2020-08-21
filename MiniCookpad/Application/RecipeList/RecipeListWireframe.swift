import UIKit

class RecipeListWireframe: RecipeListWireframeProtocol {
    private weak var viewController: UIViewController!
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func openRecipeDetails(recipeID: String) {
        let vc = RecipeDetailsViewController(recipeID: recipeID)
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
}
