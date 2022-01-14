//
//  CurrencyConverterService.swift
//  baluchon
//
//  Created by laurent aubourg on 27/08/2021.
//
//
import Foundation
final class MontreuilIsMyGardenService:UrlSessionCancelable,UrlBuildable{
    
    //MARK: - properties
    
 
    internal var lastUrl:URL = URL(string:"http://")!
    internal var  session : URLSession
    
    //MARK: - methods
    
    init(session:URLSession = URLSession(configuration: .default)){
        self.session = session
        }

    // MARK: - Request to the API to ask for the available languages
   
/*
https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/records/?refine=categorie:Jardin%20partag%C3%A9
https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/facets
 */
    
    func getFacets( callback: @escaping( Result<facetResponse,NetworkError>)->Void) {
        let url:URL = URL(string: "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/facets")!
           session.dataTask(with: url, callback: callback)
           return
        }

    // MARK: - Request to the API to ask for the translation in the selected language of the words passed in parameter
    
    func getRecords(for categorie:String, callback: @escaping( Result<RecordResponse,NetworkError>)->Void) {
        let url:URL = URL(string:"https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/records/?refine=categorie:\(categorie)")!
        session.dataTask(with: url, callback: callback)
        return
    }
  }

// MARK: decodable struct

struct Facet: Decodable {
    let name: String
    let count:Int
    let state:String
    let value:String
}

struct facets: Decodable {
    let name:String
    let facets :[Facet]
}
struct facetResponse: Decodable {
    
    let facets :[facets]
}

// MARK: decodable struct for Records list

struct Record: Decodable {
    let language: String
    let name : String
      
    }
// MARK: -RecordResponse Struct

struct RecordResponse: Decodable {
    let Records :[Record]
}



