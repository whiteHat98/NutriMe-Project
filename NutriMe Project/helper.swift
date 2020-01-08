//
//  helper.swift
//  NutriMe Project
//
//  Created by Randy Noel on 09/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import Foundation
import UIKit

//let headers = [
//  "x-rapidapi-host": "nutritionix-api.p.rapidapi.com",
//  "x-rapidapi-key": "6e65503708msh3ca3830f3c6c366p1a0789jsn0568763bd168"
//]
//
//let session = URLSession.shared
//let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//  if (error != nil) {
//    print(error)
//  } else {
//    let httpResponse = response as? HTTPURLResponse
//    print(httpResponse)
//  }
//})
//
//let request = NSMutableURLRequest(url: NSURL(string: "https://nutritionix-api.p.rapidapi.com/v1_1/search/plain%2520rice?fields=item_name%252Citem_id%252Cbrand_name%252Cnf_calories%252Cnf_total_fat%252Cnf_protein%252Cnf_total_carbohydrate")! as URL,
//                                        cachePolicy: .useProtocolCachePolicy,
//                                    timeoutInterval: 10.0)
//
//class ConnectAPI{
//  init() {
//    request.httpMethod = "GET"
//    request.allHTTPHeaderFields = headers
//    dataTask.resume()
//  }
//}

class RequestAPI{
  
  func requestAPI(food : String, completion : @escaping(Result<[Hits], APIError>) -> Void){
    
    let urlString = "https://api.nutritionix.com/v1_1/search"
    let url = NSURL(string: urlString)!
    let paramString : [String:Any] = [
      "appId":"d794304c",
      "appKey":"dcbaf04ac0d57d492fe779bc37201ec0",
      "fields":["brand_name","item_id","item_name","item_type","nf_calories","nf_protein","nf_total_fat","nf_total_carbohydrate"],
      "query":"\(food)",
      "filters":["item_type": 3]
      ]
    
    let request = NSMutableURLRequest(url: url as URL)
      request.httpMethod = "POST"
      request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
      let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, _) in
        guard let jsonData = data else{
          completion(.failure(.noDataAvailable))
          return
        }
        
        do{
          let decoder = JSONDecoder()
          let apiData = try decoder.decode(APIData.self, from: jsonData)
          completion(.success(apiData.hits))
        }catch{
          print(error)
          completion(.failure(.canNotAccessData))
        }
        
        }

        task.resume()
    }
}

enum APIError : Error{
  case canNotAccessData
  case noDataAvailable
}
struct APIResponse : Decodable {
  var response : APIData
}

struct APIData: Decodable{
  var max_score : Double?
  var total : Int?
  var hits : [Hits]
}

struct Hits: Decodable{
  var _id : String
  var _index : String
  var _score : Double?
  var _type : String
  var fields : Fields
}

struct Fields: Decodable{
  var brand_name : String
  var item_id : String
  var item_name : String
  var item_type: Int
  var nf_calories: Float
  var nf_protein: Float = 0.0
  var nf_total_fat: Float = 0.0
  var nf_total_carbohydrate: Float = 0.0
}

struct UserInfo{
    var userID: String
    var name: String
    var dob: Date
    var gender: String
    var height: Float
    var weight: Float
    var currCalories: Float
    var caloriesNeed: Float
    var activities: String?
    var foodRestriction: String?
    var reminder: String?
    var caloriesGoal: Float?
    var carbohydrateGoal: Float?
    var fatGoal: Float?
    var proteinGoal: Float?
    var mineralGoal: Float?
}

struct Activity{
  var level : ActivityLevel
  var caloriesMultiply : Float?
}

enum ActivityLevel: String{
  case low = "Low"
  case medium = "Medium"
  case high = "High"
}

protocol SaveToDisk: Codable {
  static var defaultEncoder: JSONEncoder{get}
  
  var storageKeyForObject: String {get}
  
  static var storageKeyForListofObjects: String{get}
  
  func save() throws
}

extension UserInfo: SaveToDisk{
  static var storageKeyForListofObjects: String {
    return "userInfoList"
  }
  
  static var defaultEncoder: JSONEncoder {
    let encoder = JSONEncoder()
    return encoder
  }
  
  var storageKeyForObject: String {
    return "userInfo"
  }
  
  func save() throws {
    let data = try UserInfo.defaultEncoder.encode(self)
    let storage = UserDefaults.standard
    storage.setValue(data, forKey: storageKeyForObject)
  }
}

//do{
//   if let jsonData = data{
//     if let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]{
//       NSLog("Received data: \(jsonDataDict)")
//
//
//
//     }
//   }
// } catch let err as NSError{
//   print(err.debugDescription)
//
// }
