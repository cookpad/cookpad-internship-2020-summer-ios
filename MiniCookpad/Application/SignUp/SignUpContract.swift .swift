protocol SignUpViewProtocol: AnyObject {
    func showError(signUpError: SignUpError)
    func showComplete()
}

protocol SignUpPresenterProtocol: AnyObject {
    func createUser(email: String?, password: String?)
    func close()
}

protocol SignUpInteractorProtocol: AnyObject {
    func createUser(email: String?, password: String?, completion: @escaping (Result<Void, SignUpError>) -> Void)
}

protocol SignUpWireframeProtocol: AnyObject {
    func close()
}
