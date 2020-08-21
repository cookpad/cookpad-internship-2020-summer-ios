class RecipeDetailsPresenter: RecipeDetailsPresenterProtocol {
    private weak var view: RecipeDetailsViewProtocol!
    private let interactor: RecipeDetailsInteractorProtocol
    private let wireframe: RecipeDetailsWireframeProtocol
    private let recipeID: String
    init(view: RecipeDetailsViewProtocol, interactor: RecipeDetailsInteractorProtocol, wireframe: RecipeDetailsWireframeProtocol, recipeID: String) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.recipeID = recipeID
    }

    func refresh() {
        interactor.fetchRecipe(recipeID: recipeID) { [weak self] result in
            switch result {
            case let .success(recipe):
                self?.view.showRecipe(recipe)
            case let .failure(error):
                self?.view.showError(error)
            }
        }
    }

    func close() {
        wireframe.close()
    }
}
