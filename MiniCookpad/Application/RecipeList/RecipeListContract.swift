protocol RecipeListViewProtocol: AnyObject {
    func showRecipes(_ recipes: [RecipeListRecipe])
    func showError(_ error: Error)
}

protocol RecipeListPresenterProtocol: AnyObject {
    func refresh()
    func openRecipeDetails(recipeID: String)
}

protocol RecipeListInteractorProtocol: AnyObject {
    func fetchAllRecipes(completion: @escaping ((Result<[RecipeListRecipe], Error>) -> Void))
}

protocol RecipeListWireframeProtocol: AnyObject {
    func openRecipeDetails(recipeID: String)
}
