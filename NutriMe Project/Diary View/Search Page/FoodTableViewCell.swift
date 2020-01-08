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
    
    var userFood: UserFood?
    
    var isUserFood = false
    
    
    @IBAction func btnAddToDiary(_ sender: Any) {
        if !isUserFood{
            let convertedFood = UserFood(ID: foodHits!._id, name: (foodHits?.fields.item_name)!, calories: (foodHits?.fields.nf_calories)!, restrictions: nil, makros: FoodMakro(FoodID: foodHits!._id, protein: (foodHits?.fields.nf_protein)!, fat: (foodHits?.fields.nf_total_fat)!, carbohydrate: (foodHits?.fields.nf_total_carbohydrate)!))
//            food = Food(name: (foodHits?.fields.item_name)!, calorie: (foodHits?.fields.nf_calories)!, perEach: 0.2)
            delegate?.sendFoodData(food: convertedFood)
            print("Masuk!")
        }
        else{
            print(userFood?.name)
//            food = Food(name: userFood!.name, calorie: userFood!.calories, perEach: 1.0)
            delegate?.sendFoodData(food: userFood!)
        }
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
