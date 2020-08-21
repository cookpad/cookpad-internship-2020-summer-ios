import Firebase

protocol UserDataStoreProtocol {
    var currentUserID: String? { get }
    func createAuthUser(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void)
}

struct UserDataStore: UserDataStoreProtocol {
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }

    func createAuthUser(email: String, password: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                switch AuthErrorCode(rawValue: error._code) {
                case .invalidEmail:
                    completion(.failure(.invalidEmail))
                case .emailAlreadyInUse:
                    completion(.failure(.emailAlreadyInUse))
                case .weakPassword:
                    completion(.failure(.weakPassword))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                completion(.success(()))
            }
        }
    }
}
