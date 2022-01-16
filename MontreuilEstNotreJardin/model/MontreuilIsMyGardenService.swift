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
    
    // MARK: -  Recover all facets
    
    func getFacets( callback: @escaping( Result<facetResponse,NetworkError>)->Void) {
        let url:URL = URL(string: "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/facets")!
        session.dataTask(with: url, callback: callback)
        return
    }
    
    // MARK: - Request to the API - Retrieve POIs for a category
    
    func getPoi(for categorie:String = "", callback: @escaping( Result<PoiResponse,NetworkError>)->Void) {
        
        /*    let urlString =  "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/records/?refine=categorie:\(categorie)"
         
         let url:URL = URL(string:urlString)!*/
        
        
        let baseUrl:String = "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/records/"
        let queryItem:[[String:String]] = [["name":"refine","value":"categorie:\(categorie)"]
        ]
        guard let url = buildUrl(baseUrl:baseUrl, Items:queryItem)  else{return }
        print(url)
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
// MARK: - Records
struct records: Decodable {
    
    let record :record?
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
    let pointgeo:pointgeo?
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
struct pointgeo:Decodable{
    let longitude:Double?
    let latitude:Double?
    enum CodingKeys: String, CodingKey {
        
        case longitude = "lon"
        case latitude = "lat"
        
    }
}
// MARK: decodable struct for Records list

struct record: Decodable {
    let id: String?
    let fields:field?
}
// MARK: -PoiResponse Struct

struct PoiResponse: Decodable {
    let records :[records]
    let count:Int?
    enum CodingKeys: String, CodingKey {
        case records
        case count = "total_count"
        
    }
}



