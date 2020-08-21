import Foundation
import UIKit
import FirebaseUI
import Firebase

final class RecipeTableViewCell: UITableViewCell {
    private let thumbnailImageView = UIImageView()
    private let recipeTitleLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        stackView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true

        stackView.addArrangedSubview(recipeTitleLabel)
        recipeTitleLabel.numberOfLines = 2
        recipeTitleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        recipeTitleLabel.textColor = .systemGreen

        stackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
    }

    func configure(recipe: QueryDocumentSnapshot) {
        let placeholderImage = UIImage(systemName: "photo")
        // レシピ写真を Cloud Storage から取得して表示する
        if let path = recipe.data()["imagePath"] as? String {
            let ref = Storage.storage().reference(withPath: path)
            thumbnailImageView.sd_setImage(with: ref, placeholderImage: placeholderImage)
        } else {
            thumbnailImageView.image = placeholderImage
        }
        recipeTitleLabel.text = recipe.data()["title"] as? String
        descriptionLabel.text = (recipe.data()["steps"] as? [String])?.joined(separator: ", ")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
