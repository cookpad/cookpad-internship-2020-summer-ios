struct RecipeListViewBuilder {
    static func build() -> RecipeListViewController {
        let viewController = RecipeListViewController()
        let recipeDataStore = RecipeDataStore()
        let interactor = RecipeListInteractor(recipeDataStore: recipeDataStore, userDataStore: UserDataStore())
        let wireframe = RecipeListWireframe(viewController: viewController)
        let presenter = RecipeListPresenter(view: viewController, interactor: interactor, wireframe: wireframe)
        viewController.inject(presenter: presenter)

        return viewController
    }
}
