import UIKit

struct RecipeDetailsViewBuilder {
    static func build(with recipeID: String) -> RecipeDetailsViewController {
        let viewController = RecipeDetailsViewController()
        let interactor = RecipeDetailsInteractor(recipeDataStore: RecipeDataStore())
        let wireframe = RecipeDetailsWireframe(viewController: viewController)
        let presenter = RecipeDetailsPresenter(view: viewController, interactor: interactor, wireframe: wireframe, recipeID: recipeID)
        viewController.inject(presenter: presenter)

        return viewController
    }
}
