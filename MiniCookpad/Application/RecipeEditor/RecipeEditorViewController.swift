import Foundation
import UIKit
import Photos

class RecipeEditorViewController: UIViewController {
    private let recipeImageView = UIImageView()
    private let titleFieldView = UITextField()
    private let stepsView = StepsView()
    private var postImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "投稿する", style: .plain, target: self, action: #selector(tapPost))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(tapClose))

        let scrollView = UIScrollView()
        let recipeOverlayButton = UIButton()
        let titleLabel = UILabel()

        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false

        scrollView.addSubview(recipeImageView)
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        recipeImageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        recipeImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        recipeImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        recipeImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        recipeImageView.contentMode = .scaleAspectFit
        recipeImageView.clipsToBounds = true
        recipeImageView.image = UIImage(systemName: "camera")

        scrollView.addSubview(recipeOverlayButton)
        recipeOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        recipeOverlayButton.leadingAnchor.constraint(equalTo: recipeImageView.leadingAnchor).isActive = true
        recipeOverlayButton.topAnchor.constraint(equalTo: recipeImageView.topAnchor).isActive = true
        recipeOverlayButton.trailingAnchor.constraint(equalTo: recipeImageView.trailingAnchor).isActive = true
        recipeOverlayButton.bottomAnchor.constraint(equalTo: recipeImageView.bottomAnchor).isActive = true
        recipeOverlayButton.addTarget(self, action: #selector(didTapRecipeOverlay), for: .touchUpInside)
        recipeOverlayButton.setBackgroundImage(#imageLiteral(resourceName: "background"), for: .highlighted)

        scrollView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        titleLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
        titleLabel.text = "レシピのタイトル"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)

        scrollView.addSubview(titleFieldView)
        titleFieldView.translatesAutoresizingMaskIntoConstraints = false
        titleFieldView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        titleFieldView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        titleFieldView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
        titleFieldView.borderStyle = .roundedRect
        titleFieldView.placeholder = "とりの唐揚げ"

        scrollView.addSubview(stepsView)
        stepsView.translatesAutoresizingMaskIntoConstraints = false
        stepsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        stepsView.topAnchor.constraint(equalTo: titleFieldView.bottomAnchor, constant: 16).isActive = true
        stepsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true

        let bottomSpace = UIView()
        scrollView.addSubview(bottomSpace)
        bottomSpace.translatesAutoresizingMaskIntoConstraints = false
        bottomSpace.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        bottomSpace.topAnchor.constraint(equalTo: stepsView.bottomAnchor).isActive = true
        bottomSpace.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        bottomSpace.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        bottomSpace.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }

    @objc private func tapPost() {
//        let title = titleFieldView.text
//        let steps = stepsView.getSteps()
//        let image = postImage
        // TODO: レシピ作成
    }

    @objc private func tapClose() {
        close()
    }

    // 入力に問題がある時に呼ぶ
    func showValidationError() {
        let message = "入力されていない項目があるか、絵文字が使用されています"
        let alertController = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }

    // データの登録などのエラーがあった際に呼ぶ
    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }

    // レシピの作成が完了した時に呼ぶ
    func showComplete() {
        let alertController = UIAlertController(title: "投稿完了", message: "レシピ投稿が完了しました。", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default) { [weak self] _ in
            self?.close()
        }
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }

    private func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapRecipeOverlay() {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            showCameraRoll()
            return
        }
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .authorized:
                    self?.showCameraRoll()
                case .denied, .restricted:
                    let noCameraAccessAlertController = UIAlertController(title: "アクセスを許可してください。",message: nil,preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel, handler: nil)
                    noCameraAccessAlertController.addAction(closeAction)
                    let settingsAction = UIAlertAction(title: NSLocalizedString("設定を開く", comment: ""), style: .default) { _ in
                        let url = URL(string: UIApplication.openSettingsURLString)!
                        UIApplication.shared.open(url)
                    }
                    noCameraAccessAlertController.addAction(settingsAction)
                    self?.present(noCameraAccessAlertController, animated: true, completion: nil)
                case .notDetermined:
                    assertionFailure()
                @unknown default:
                    assertionFailure()
                }
            }
        }

    }

    private func showCameraRoll() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension RecipeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.image = image
        postImage = image
    }
}

final class StepsView: UIStackView {
    private var stepTextViews: [UITextView] = []
    let button = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        axis = .vertical
        spacing = 6

        let stepLabel = UILabel()
        stepLabel.text = "手順"
        stepLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        addArrangedSubview(stepLabel)

        button.addTarget(self, action: #selector(addStep), for: .touchUpInside)
        button.setTitle("+手順を追加", for: .normal)
        addArrangedSubview(button)

        addTextField()
    }

    private func addTextField() {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textView.layer.cornerRadius = 6
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        stepTextViews.append(textView)
        insertArrangedSubview(textView, at: arrangedSubviews.count - 1)
    }

    @objc private func addStep() {
        addTextField()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getSteps() -> [String?] {
        return stepTextViews.map { $0.text }
    }
}

