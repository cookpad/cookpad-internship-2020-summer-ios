import Foundation
import UIKit

protocol RecipeEditorViewProtocol: AnyObject {
    func showValidationError()
    func showError(_ error: Error)
    func showComplete()
}

protocol RecipeEditorPresenterProtocol: AnyObject {
    func createRecipe(title: String?, steps: [String?], image: UIImage?)
    func close()
}

protocol RecipeEditorInteractorProtocol: AnyObject {
    func createRecipe(title: String?, steps: [String?], image: UIImage?, completion: @escaping ((Result<Void, RecipeEditorError>) -> Void))
}

protocol RecipeEditorWireframeProtocol: AnyObject {
    func close()
}
