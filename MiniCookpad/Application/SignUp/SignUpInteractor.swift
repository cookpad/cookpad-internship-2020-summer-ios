import Foundation
import UIKit

class SignUpInteractor: SignUpInteractorProtocol {
    let userDataStore: UserDataStoreProtocol
    init(userDataStore: UserDataStoreProtocol) {
        self.userDataStore = userDataStore
    }

    func createUser(email: String?, password: String?, completion: @escaping (Result<Void, SignUpError>) -> Void) {
        let result = validate(email: email, password: password)

        let email: String
        let password: String
        switch result {
        case let .success((resultEmail, resultPassword)):
            email = resultEmail
            password = resultPassword
        case let .failure(error):
            completion(.failure(error))
            return
        }

        userDataStore.createAuthUser(email: email, password: password) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                switch error {
                case .emailAlreadyInUse:
                    completion(.failure(.emailAlreadyInUse))
                case .invalidEmail:
                    completion(.failure(.invalidEmail))
                case .weakPassword:
                    completion(.failure(.weakPassword))
                case .unknown:
                    completion(.failure(.unknown))
                }
            }
        }
    }

    private func validate(email: String?, password: String?) -> Result<(email: String, password: String), SignUpError> {
        guard let email = email, let password = password else {
            return .failure(.validationError)
        }

        if email.isEmpty || password.isEmpty {
            return .failure(.validationError)
        }

        return .success((email: email, password: password))
    }
}
