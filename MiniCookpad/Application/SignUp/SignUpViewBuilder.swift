struct SignUpViewBuilder {
    static func build() -> SignUpViewController {
        let viewController = SignUpViewController()
        let interactor = SignUpInteractor(userDataStore: UserDataStore())
        let wireframe = SignUpWireframe(viewController: viewController)
        let presenter = SignUpPresenter(view: viewController, interactor: interactor, wireframe: wireframe)
        viewController.inject(presenter: presenter)

        return viewController
    }
}
