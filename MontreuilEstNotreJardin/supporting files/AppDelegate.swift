//
//  AppDelegate.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 12/01/2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var coreDataStack = CoreDataStack(modelName: "MontreuilEstNotreJardin")
    private var coreDataManager: CoreDataManager? = nil
    private let dataSetService:DataSetService = .init()
    private var currentCategoryRank = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        coreDataManager = CoreDataManager(coreDataStack:coreDataStack)
       if coreDataManager?.categories.count == 0 {
            coreDataManager?.deleteAllcategories()
            loadCategories()
   }
        return true
    }
   
        
    //MARK: Load  facets JSON and maj coreData Category entity
    
    private func loadCategories(){
    
        dataSetService.getFacets(callback:{ result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success( let data):
                    //   self?.activityIndicator.isHidden = false
                    for facet in data.facets{
                        
                        if facet.name == "categorie" {
                            let categories = facet.facets
                            for categorie in categories{
                                self!.coreDataManager?.addCategorie(name: categorie.name, nbRecords: Int32(categorie.nbRecords),state:categorie.state)
                            }
                      
                                self!.loadPoi()
                     
                        }
                        continue
                    }
                    
                    break
                case .failure(let error):
                    print ("The facets download failed.:\(error)")
                   }}
        })
    }
    
    // MARK: -  Load  Poi JSON and maj coreData Poi entity for all categories
    
    func loadPoi(){
        
        let categories = coreDataManager?.categories as [Category]?
        guard categories != nil else{return}
        let categorie = coreDataManager?.categories[currentCategoryRank]
        guard categorie != nil else{return}
        guard categorie!.name != nil else{return}
        let nbRecords:Int32 = categorie!.nbRecords
        let nameCategory = categorie!.name
        dataSetService.getPoi(for: nameCategory! , nbRecords:Int(nbRecords),  callback:{ [weak self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success( let data):
                    self?.coreDataManager?.addPoi(categorie: categorie!, pois: data.records)
                    break
                case .failure(let error):
                    print("The Poi records download failed.:\(error)")
                }
            }
            if categories!.count >  self!.currentCategoryRank+1{
                
                self?.currentCategoryRank += 1
                self?.loadPoi()
            }
           })
    }
    //MARK: clean Category Entities and reLoad  facets JSON and maj coreData Category entity
   
   func reloadCategories(withPoi:Bool = false){
        
        coreDataManager?.deleteAllcategories()
    
        loadCategories()
    }
  
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MontreuilEstNotreJardin")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    
    }
}

