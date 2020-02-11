//
//  Model.swift
//  NutriMe Project
//
//  Created by Randy Noel on 06/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import Foundation
import CloudKit

struct Food {
    var name: String
    var calorie: Float
    var perEach: Float?
}

struct UserFood {
    var ID: String
    var name: String
    var calories: Float
    var restrictions: [String]?
    var makros: FoodMakro?
}

struct FoodMakro {
    var FoodID: String
    var protein: Float
    var fat: Float
    var carbohydrate: Float
}

struct DiaryList{
    let diaries: [Diary]
}

struct Diary {
    var id: CKRecord.ID
    var category: String
    var foods: [FoodInDiary]?
    var date: String
    var foodName: String
    var foodCalories: Float
    var foodCarbohydrate: Float
    var foodFat: Float
    var foodProtein: Float
    var portion: Float
    
//    func sumCalories()->Float{
//        var cal:Float = 0
//        for food in foods{
//            cal += food.food.calorie
//        }
//        return cal
//    }
}

struct Recommendation {
    var name: String
    var category: String
    var desc: String
    var restriction: String?
    var userID : String?
    var totalInDiary : Int?
}

struct Reminder {
    var hour: Int
    var minute: Int
    var type: String
}

struct FoodInDiary {
    var category: EatCategory
    var food: Food
    var date: Date?
    var portion: Float?
}

struct Activity{
  var id : Int
  var level : ActivityLevel
  var desc : String
  var caloriesMultiply : Float?
}

enum ActivityLevel: String{
  case low = "Low"
  case medium = "Medium"
  case high = "High"
    case live = "Live"
}

enum EatCategory: String{
    case pagi = "Breakfast"
    case siang = "Lunch"
    case malam = "Dinner"
    
}
