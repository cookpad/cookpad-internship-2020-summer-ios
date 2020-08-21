import Foundation
import UIKit

class SignUpViewController: UIViewController {
    private let emailTextFeild = UITextField()
    private let passwordTextFeild = UITextField()

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
        // TODO: ユーザ作成
    }

    @objc private func tapClose() {
        close()
    }

    private func close() {
        dismiss(animated: true, completion: nil)
    }
}
