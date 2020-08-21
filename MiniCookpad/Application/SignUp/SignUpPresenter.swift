import Foundation

final class SignUpPresenter: SignUpPresenterProtocol {
    private weak var view: SignUpViewProtocol!
    private let interactor: SignUpInteractorProtocol
    private let wireframe: SignUpWireframeProtocol

    init(view: SignUpViewProtocol, interactor: SignUpInteractorProtocol, wireframe: SignUpWireframeProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }

    func createUser(email: String?, password: String?) {
        interactor.createUser(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.view.showComplete()
            case let .failure(error):
                self?.view.showError(signUpError: error)
            }
        }
    }

    func close() {
        wireframe.close()
    }
}
