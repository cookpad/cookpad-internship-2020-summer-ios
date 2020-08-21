import Foundation
import UIKit

class SignUpViewController: UIViewController, SignUpViewProtocol {
    private let emailTextFeild = UITextField()
    private let passwordTextFeild = UITextField()
    private var presenter: SignUpPresenterProtocol!

    func inject(presenter: SignUpPresenterProtocol) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(tapClose))

        let scrollView = UIScrollView()

        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false

        let stackView = UIStackView()
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.axis = .vertical
        stackView.spacing = 4

        let descriptionLabel = UILabel()
        stackView.addArrangedSubview(descriptionLabel)
        stackView.setCustomSpacing(32, after: descriptionLabel)
        descriptionLabel.text = "レシピを投稿するには、ユーザ登録が必要です。"
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        let emailTitleLabel = UILabel()
        stackView.addArrangedSubview(emailTitleLabel)
        emailTitleLabel.text = "メールアドレスを入力"

        stackView.addArrangedSubview(emailTextFeild)
        stackView.setCustomSpacing(16, after: emailTextFeild)
        emailTextFeild.borderStyle = .roundedRect
        emailTextFeild.placeholder = "hoge@example.com"

        let passwordLabel = UILabel()
        stackView.addArrangedSubview(passwordLabel)
        passwordLabel.text = "パスワードを入力"

        stackView.addArrangedSubview(passwordTextFeild)
        stackView.setCustomSpacing(16, after: passwordTextFeild)
        passwordTextFeild.borderStyle = .roundedRect
        passwordTextFeild.isSecureTextEntry = true
        passwordTextFeild.placeholder = "password"

        let signUpButton = UIButton(type: .system)
        stackView.addArrangedSubview(signUpButton)
        signUpButton.setTitle("新規登録", for: .normal)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)

        let bottomSpace = UIView()
        stackView.addArrangedSubview(bottomSpace)
        bottomSpace.translatesAutoresizingMaskIntoConstraints = false
        bottomSpace.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }

    @objc private func didTapSignUp() {
        presenter.createUser(email: emailTextFeild.text, password: passwordTextFeild.text)
    }

    @objc private func tapClose() {
        close()
    }

    func signUpComplete() {
        let alertController = UIAlertController(title: "会員登録完了", message: "会員登録が完了しました。", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default) { [weak self] _ in
            self?.close()
        }
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }

    private func close() {
        dismiss(animated: true, completion: nil)
    }

    func showError(signUpError: SignUpError) {
        let message: String
        switch signUpError {
        case .validationError:
            message = "入力されていない項目があります"
        case .emailAlreadyInUse:
            message = "このメールアドレスは既に使用されています"
        case .invalidEmail:
            message = "メールアドレスの形式が正しくありません"
        case .weakPassword:
            message = "パスワードの文字数を増やしてください"
        case .unknown:
            message = "不明なエラーが発生しました。再度お試しください"
        }

        let alertController = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }

    func showComplete() {
        let alertController = UIAlertController(title: "登録完了", message: "会員登録が完了しました。", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default) { [weak self] _ in
            self?.close()
        }
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
}
