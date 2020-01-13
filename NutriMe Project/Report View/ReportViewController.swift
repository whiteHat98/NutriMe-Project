//
//  ReportViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 18/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import Charts
import CloudKit

struct Report{
  var day: String
  var carbo: Double
  var fat: Double
  var protein: Double
}

class ReportViewController: UIViewController {

  let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

  @IBOutlet weak var chartReportView: BarChartView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setChartValue()
        // Do any additional setup after loading the view.
    }
  
    var randomV: Double{
      return Double(arc4random_uniform(UInt32(7) + 3))
    }
    
    func generateData() -> [Report]{
      
      var reports = [Report]()
      
      for day in days{
        let report = Report(day: day, carbo: randomV, fat: randomV, protein: randomV)
        reports.append(report)
      }
      return reports
    }
  
    
  func setChartValue(){
    
//    let reports = generateData()
//
//    var reportEntries = [BarChartDataEntry]()
//
//    var reportDays = [String]()
//
//    for (i,report) in reports.enumerated(){
//      let reportEntry = BarChartDataEntry(x: Double(i), yValues: [report.carbo, report.fat, report.protein])
//      reportEntries.append(reportEntry)
//      reportDays.append(report.day)
//    }
//
//
//    let chartDataSet = BarChartDataSet(entries: reportEntries, label: "Data")
//    let chartData = BarChartData(dataSets: [chartDataSet])
//
//    chartReportView.data = chartData
    let values = (0..<7).map { (i) -> BarChartDataEntry in
      let val = Double(arc4random_uniform(UInt32(7) + 3))
      return BarChartDataEntry(x: Double(i), y: val)
    }

    let values2 = (0..<7).map { (i) -> BarChartDataEntry in
      let val = Double(arc4random_uniform(UInt32(7) + 3))
      return BarChartDataEntry(x: Double(i), y: val)
    }

    let values3 = (0..<7).map { (i) -> BarChartDataEntry in

      let val = Double(arc4random_uniform(UInt32(7) + 3))
      return BarChartDataEntry(x: Double(i), y: val)
    }

    let set1 = BarChartDataSet(entries: values, label: "test")
    set1.setColor(.red)
    let set2 = BarChartDataSet(entries: values2, label: "test2")
    set2.setColor(.yellow)
    let set3 = BarChartDataSet(entries: values3, label: "test3")
    set3.setColor(.blue)

    let data = BarChartData(dataSets: [set1, set2, set3])

    data.barWidth = 0.3
    data.groupBars(fromX: 0, groupSpace: 0.1, barSpace: 0)

    self.chartReportView.rightAxis.enabled = false

    self.chartReportView.highlighter = nil
    self.chartReportView.animate(yAxisDuration: 1.5, easing: .none)
    
    //legend -> Label
    let legend = chartReportView.legend
    legend.enabled = false
    legend.horizontalAlignment = .right
    legend.orientation = .vertical
    legend.xOffset = 10.0
    legend.yOffset = 10.0
    legend.yEntrySpace = 0
    
    
    //xAxis
    let xAxis = self.chartReportView.xAxis
    xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
    xAxis.labelPosition = .bottom
    xAxis.centerAxisLabelsEnabled = true
    xAxis.drawGridLinesEnabled = true
    xAxis.gridLineWidth = 2
    xAxis.spaceMax = 1
    xAxis.axisMinimum = 0
    xAxis.granularity = 1
    
    //yAxis
    let yAxis = self.chartReportView.leftAxis
    yAxis.spaceTop = 0.35
    yAxis.axisMinimum = 0
    yAxis.drawGridLinesEnabled = true
    yAxis.gridLineWidth = 0.1
    

    self.chartReportView.data = data
    self.chartReportView.drawBordersEnabled = false
    self.chartReportView.isUserInteractionEnabled = false
  }
  
  func getDataFromReportDB(){
    
  }
}
