//
//  Model.swift
//  NutriMe Project
//
//  Created by Randy Noel on 06/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import Foundation

struct Food {
  var name: String
  var calorie: Float
  var perEach: Float?
}

struct DiaryList{
  let diaries: [Diary]
}

struct Diary {
  var category: EatCategory
  var foods: [FoodInDiary]
  var date: Date?
  
 func sumCalories()->Float{
  var cal:Float = 0
    for food in foods{
      cal += food.food.calorie
    }
  return cal
  }
}

struct FoodInDiary {
  var category: EatCategory
  var food: Food
  var date: Date?
  var portion: Float?
}
