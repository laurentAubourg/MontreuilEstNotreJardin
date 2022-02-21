//
//  DataSetService.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 02/12/2021.
//
//
import Foundation
final class DataSetService:UrlBuildable{
    
    //MARK: - properties
    
    
    internal var lastUrl:URL = URL(string:"http://")!
    internal var  session : URLSession
    
    //MARK: - methods
    
    init(session:URLSession = URLSession(configuration: .default)){
        self.session = session
      
    }
    
    func getResources( callback: @escaping( Result<[Resource],NetworkError>)->Void) {
        let url:URL = URL(string: "https://parsoflex.info/oc/menj.json")!
        session.dataTask(with: url, callback: callback)
        return
    }
    
    // MARK: -  Recover all facets
    
    func getFacets( callback: @escaping( Result<FacetResponse,NetworkError>)->Void) {
        let url:URL = URL(string: "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/facets")!
        session.dataTask(with: url, callback: callback)
        return
    }
    
    // MARK: - Request to the API - Retrieve POIs for a category
    
    func getPoi(for categorie:String = "",nbRecords:Int, callback: @escaping( Result<PoiResponse,NetworkError>)->Void) {
        
        let baseUrl:String = "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/records/"
        let queryItem:[[String:String]] = [["name":"refine","value":"categorie:\(categorie)"],
                                            ["name":"rows","value":"100"]]
        guard let url = buildUrl(baseUrl:baseUrl, Items:queryItem)  else{return }
    
        session.dataTask(with: url, callback: callback)
        return
    }
}

// MARK: decodable struct

struct Facet: Decodable {
    let name: String
    let nbRecords:Int
    let state:String
    let value:String
    enum CodingKeys: String, CodingKey {
        case name
        case nbRecords = "count"
        case state
        case value
    }
}

struct Facets: Decodable {
    let name:String
    let facets :[Facet]
}
struct FacetResponse: Decodable {
    
    let facets :[Facets]
}
// MARK: - Records
struct Records: Decodable {
    
    let record :Record?
    enum CodingKeys: String, CodingKey {
        case record
    }
}
struct field:Decodable{
    let name:String?
    let categorie:String?
    let year:Int?
    let state:String?
    let address:String?
    let email:String?
    let pointgeo:Pointgeo?
    let telephon:String?
    
    enum CodingKeys: String, CodingKey {
        
        case name = "nom"
        case year = "annee"
        case state = "statut"
        case address = "adresse"
        case email
        case telephon = "telephone"
        case categorie
        case pointgeo
    }
}
struct Pointgeo:Decodable{
    let longitude:Double?
    let latitude:Double?
    enum CodingKeys: String, CodingKey {
        
        case longitude = "lon"
        case latitude = "lat"
        
    }
}
// MARK: decodable struct for Records list

struct Record: Decodable{
    let id: String?
    let fields:field?
}
// MARK: -PoiResponse Struct

struct PoiResponse: Decodable {
    let records :[Records]
    let count:Int?
    enum CodingKeys: String, CodingKey {
        case records
        case count = "total_count"
        
    }
}
    // MARK: decodable struct for Resource list

    struct Resource: Decodable{
        let title: String
        let type: String
        let icon:String
        let comment:String
        let segue:String
    }

    // MARK: - ResourcesResponse

    struct ResourcesResponse: Decodable {
        let ressources :Resource
    }




