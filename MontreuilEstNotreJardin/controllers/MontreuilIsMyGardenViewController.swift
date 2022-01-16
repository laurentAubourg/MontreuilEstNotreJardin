//
//  WeatherViewController.swift
//  baluchon
//
//  Created by laurent aubourg on 25/08/2021.
//

import UIKit

final class MontreuilIsMyGardenViewController: UIViewController {
    
    // MARK: - @IBOUTLETS
    
    
    
    //MARK: - Properties
    
    private let service:MontreuilIsMyGardenService = .init()
    private var coreDataManager: CoreDataManager?
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        coreDataManager = CoreDataManager(coreDataStack:appdelegate.coreDataStack)
        coreDataManager?.deleteAllcategories()
        
    }
    
    // MARK: - Request the weather from the OpenWeather API when displaying the view
    
    override func viewWillAppear(_ animated: Bool) {
        getCategories()
    }
    private func getCategories(){
        service.getFacets(callback:{ result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success( let data):
                    
                    for facet in data.facets{
                        if facet.name == "categorie" {
                            let categories = facet.facets
                            for categorie in categories{
                                print ("CATEGORIES => \(categorie.name)")
                                self!.coreDataManager?.addCategorie(name: categorie.name, count: Int32(categorie.count),state:categorie.state)
                            }
                            
                        }
                        continue
                    }
                    
                    self!.addPoi()
                    break
                case .failure(let error):
                    self?.presentAlert("The facets download failed.:\(error)")
                }
            }
        })
    }
    func addPoi(){
        let categories = coreDataManager?.categories as [Genre]?
        for categorie in categories!{
            service.getPoi(for: categorie.name ?? "" ,  callback:{ result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success( let data):
                   //     print ("CATEGORIES => \(categorie)")
                   //     print ("RECORDS => \(data.records)")
                        self!.coreDataManager?.addPoi(categorie: categorie, pois: data.records)
                        break
                    case .failure(let error):
                        self?.presentAlert("The Poi records download failed.:\(error)")
                    }
                }
            })
            
        }
    }
    
    
}
