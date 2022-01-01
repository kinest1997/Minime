//
//  CocktailListCellTableViewCell.swift
//  Cocktail
//
//  Created by 강희성 on 2021/11/03.
//

import UIKit
import SnapKit
import Kingfisher

class CocktailListCell: UITableViewCell {
    let cocktailImageView = UIImageView()
    let nameLabel = UILabel()
    let ingredientCountLabel = UILabel()
    let likeCount = UILabel()
    let disclosureMark = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .white
        nameLabel.textColor = .black
        ingredientCountLabel.textColor = .gray
        disclosureMark.tintColor = .black
        
        
        [nameLabel, ingredientCountLabel, cocktailImageView, likeCount, disclosureMark].forEach {
            contentView.addSubview($0)
        }
        cocktailImageView.contentMode = .scaleAspectFit
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        ingredientCountLabel.font = .systemFont(ofSize: 15, weight: .medium)
        ingredientCountLabel.alpha = 0.7
        likeCount.textColor = .white
        
        cocktailImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.top.bottom.equalToSuperview().inset(5)
            $0.width.equalTo(cocktailImageView.snp.height)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(cocktailImageView.snp.trailing).offset(20)
            $0.bottom.equalTo(cocktailImageView.snp.centerY)
        }
        ingredientCountLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        likeCount.snp.makeConstraints {
            $0.leading.equalTo(ingredientCountLabel.snp.trailing)
            $0.width.equalTo(50)
            $0.height.bottom.equalToSuperview()
        }
        disclosureMark.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(data: Cocktail) {
        nameLabel.text = data.name
        ingredientCountLabel.text = "Ingredients".localized + " \(data.ingredients.count)" + "EA".localized
        cocktailImageView.kf.setImage(with: URL(string: data.imageURL))
    }
}
