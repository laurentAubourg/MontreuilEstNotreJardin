//
//  FakeResponseData
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 03/02/2022
//

import Foundation

class FakeResponseData {
    
    static let urlFacet: URL = URL(string: "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/facets")!
    
    static let urlPoi: URL = URL(string: "https://data.montreuil.fr/api/v2/catalog/datasets/montreuil-est-notre-jardin/records/?refine=categorie:arbre&rows=100")!
    static let urlResource: URL = URL(string: "https://parsoflex.info/oc/menj.json")!
   
    static let responseOK = HTTPURLResponse(url: urlFacet , statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let responseKO = HTTPURLResponse(url:urlPoi , statusCode: 500, httpVersion: nil, headerFields: nil)!
    
    class NetworkError: Error {}
    static let error = NetworkError()
    
 
    static var facetCorrectData: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "facet", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }
    static var resourcesCorrectData: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "resources", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }
    static var poiCorrectData: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "Pois", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }
  
    static let incorrectData = "erreur".data(using: .utf8)!
}
