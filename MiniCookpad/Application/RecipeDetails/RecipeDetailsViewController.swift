import Foundation
import UIKit
import FirebaseStorage
import FirebaseUI
import Firebase

final class RecipeDetailsViewController: UIViewController, RecipeDetailsViewProtocol {
    private let storage = Storage.storage()
    private let recipeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let stepsStackView = UIStackView()
    private var presenter: RecipeDetailsPresenterProtocol!

    func inject(presenter: RecipeDetailsPresenterProtocol) {
        self.presenter = presenter
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            view.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView()

        view.backgroundColor = .systemBackground

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
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true

        scrollView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        titleLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 8).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = .systemGreen
        titleLabel.adjustsFontForContentSizeCategory = true

        scrollView.addSubview(stepsStackView)
        stepsStackView.translatesAutoresizingMaskIntoConstraints = false
        stepsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        stepsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        stepsStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        stepsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stepsStackView.axis = .vertical
        stepsStackView.spacing = 8

        let stepsTitleLabel = UILabel()
        stepsTitleLabel.text = "手順"
        stepsTitleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        stepsTitleLabel.adjustsFontForContentSizeCategory = true
        stepsStackView.addArrangedSubview(stepsTitleLabel)

        presenter.refresh()
    }

    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "エラー", message: "レシピの取得に失敗しました。もう一度お試しください。\n\(error.localizedDescription)", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }

    func showRecipe(_ recipe: RecipeDetailsRecipe) {
        title = recipe.title
        titleLabel.text = recipe.title

        let placeholderImage = UIImage(systemName: "photo")
        let ref = Storage.storage().reference(withPath: recipe.imagePath)
        recipeImageView.sd_setImage(with: ref, placeholderImage: placeholderImage)

        recipe.steps.enumerated().forEach { index, step in
            let label = UILabel()
            label.text = "\(index + 1): \(step)"
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.textColor = .secondaryLabel
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            stepsStackView.addArrangedSubview(label)
        }
    }
}
