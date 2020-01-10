//
//  CalendarVars.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 09/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import Foundation

let date = Date()
let calendar = Calendar.current

let calendarDay = calendar.component(.day, from: date)
var calendarWeekday = calendar.component(.weekday, from: date) - 1
var calendarMonth = calendar.component(.month, from: date) - 1
var calendarYear = calendar.component(.year, from: date)

var leapYearCounter = 2

let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

func getDayOfWeek(_ today:String) -> Int? {
    let formatter  = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    guard let todayDate = formatter.date(from: today) else { return nil }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate)
    return weekDay
}
