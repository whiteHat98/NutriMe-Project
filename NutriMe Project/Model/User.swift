//
//  User.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 28/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import Foundation
import CloudKit

var userIDs = [CKRecord.ID]()
var names = [String]()
var dob = [String]()
var gender = [String]()
var weight = [Float]()
var height = [Float]()
var userRestrictionID = [String]()
var userReminderID = [String]()
var caloriesGoal = [Float]()
var carbohydrateGoal = [Float]()
var fatGoal = [Float]()
var proteinGoal = [Float]()
var mineralGoal = [Float]()

func stringToDate(_ stringDate: String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy"
    let dob = dateFormatter.date(from: stringDate)
    return dob!
}
