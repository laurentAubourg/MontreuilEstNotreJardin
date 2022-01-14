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
                            var  idCategorie:Int32 = 0
                            for categorie in categories{
                                idCategorie += 1
                                self!.coreDataManager?.addCategorie(id:idCategorie,name: categorie.name, count: Int32(categorie.count))
                               //self!.addPoi()
                            }
                            
                        }
                        continue
                    }
                    
                    break
                case .failure(let error):
                    self?.presentAlert("The facets download failed.:\(error)")
                }
            }
        })
    }
    func addPoi(){
        let categories = coreDataManager?.categories as [Genre?]
        for categorie in categories{
            service.getPoi(for: categorie?.name ?? "" ,  callback:{ result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success( let data):
                        /*    for poi in data.facets{
                         let categories = facet.facets
                         var  idCategorie:Int32 = 0
                         for categorie in categories{
                         idCategorie += 1
                         self!.coreDataManager?.addCategorie(id:idCategorie,name: categorie.name, count: categorie.count)
                         }
                         self!.addPoi()
                         }
                         */
                        break
                    case .failure(let error):
                        self?.presentAlert("The facets download failed.:\(error)")
                    }
                }
            })
            
        }
    }

    
}
