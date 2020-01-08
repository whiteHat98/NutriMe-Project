//
//  AddFoodTableViewCell.swift
//  NutriMe Project
//
//  Created by Randy Noel on 29/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

protocol ButtonAddFood{
  func buttonClicked(section: EatCategory)
  func sendFoodData(food: UserFood)
}

extension ButtonAddFood{
  func sendFoodData(food: Food){}
}

class AddFoodTableViewCell: UITableViewCell {

  var delegate: ButtonAddFood?
  var section: EatCategory!
  
  @IBAction func btnAddFood(_ sender: Any) {
    delegate?.buttonClicked(section: section)
  }
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
