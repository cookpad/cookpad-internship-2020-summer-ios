enum SignUpError: Error {
    case validationError
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case unknown
}
