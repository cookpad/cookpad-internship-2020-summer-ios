protocol RecipeListViewProtocol: AnyObject {
    func showRecipes(_ recipes: [RecipeListRecipe])
    func showError(_ error: Error)
}

protocol RecipeListPresenterProtocol: AnyObject {
    func refresh()
    func openRecipeDetails(recipeID: String)
    func openRecipeEditor()
}

protocol RecipeListInteractorProtocol: AnyObject {
    func fetchAllRecipes(completion: @escaping ((Result<[RecipeListRecipe], Error>) -> Void))
    func hasUserID() -> Bool
}

protocol RecipeListWireframeProtocol: AnyObject {
    func openRecipeDetails(recipeID: String)
    func openRecipeEditor()
    func openSignUp()
}
