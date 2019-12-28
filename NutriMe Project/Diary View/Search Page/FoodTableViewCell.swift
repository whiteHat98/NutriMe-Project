//
//  FoodTableViewCell.swift
//  NutriMe Project
//
//  Created by Randy Noel on 30/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
  
  @IBOutlet weak var lblFoodName: UILabel!
  @IBOutlet weak var lblCalories: UILabel!
  @IBOutlet weak var lblNutrition: UILabel!
  var delegate: ButtonAddFood?
  var food: Food?
  var foodHits: Hits?
  
  @IBAction func btnAddToDiary(_ sender: Any) {
    food = Food(name: (foodHits?.fields.item_name)!, calorie: (foodHits?.fields.nf_calories)!, perEach: 0.2)
    delegate?.sendFoodData(food: food!)
    print("Masuk!")
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
