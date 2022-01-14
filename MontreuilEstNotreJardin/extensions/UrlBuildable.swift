//
//  UrlBuildable.swift
//  reciplease
//
//  Created by laurent aubourg on 09/11/2021.
//
import Foundation
protocol UrlBuildable{
    
}
extension UrlBuildable{
    
    //MARK: - Builds an url with the parameters passed to it
    
    func buildUrl(baseUrl:String,Items:[[String:String]])->URL?{
        var components = URLComponents(string: baseUrl)
        var  queryItems: [URLQueryItem] = []
        for item:[String:String] in Items {
            guard item["name"] != nil  else{
                return nil
            }
            guard item["value"] != nil  else{return nil}
            let queryItem =  URLQueryItem(name: item["name"]!, value: item["value"]!)
            queryItems.append(queryItem)
        }
        components?.queryItems = queryItems
        guard let url :URL = components?.url,!baseUrl.isEmpty  else{
            return nil
        }
        return url
    }
}
