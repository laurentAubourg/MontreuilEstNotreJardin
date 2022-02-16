//
//  CoreDataManager.swift
//  P10_laurent_aubourg
//
//  Created by laurent aubourg on 02/11/2021.
//

import Foundation
import CoreData


final class CoreDataManager {
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    private let managedObjectContext: NSManagedObjectContext
    
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        self.managedObjectContext = coreDataStack.mainContext
        
    }
    
    var categories: [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.returnsObjectsAsFaults = false
        guard let categories = try? managedObjectContext.fetch(request) else {return [] }
        return categories
    }
    var pois: [Poi] {
        let request: NSFetchRequest<Poi> = Poi.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.returnsObjectsAsFaults = false
        guard let pois = try? managedObjectContext.fetch(request) else {return [] }
        return pois
    }
    
    var selectedCategories:[Category]?{
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate =  NSPredicate(format:"selected == %@",NSNumber(value: true))
        
        let  selectedCategories = try! managedObjectContext.fetch(request)
        return selectedCategories
    }
    var favoritesPois:[Poi]{
        let request: NSFetchRequest<Poi> = Poi.fetchRequest()
        let predicate = NSPredicate(format:"favorit == %@",NSNumber(value: true))
        request.predicate =  predicate
        let  selectedPoi = try! managedObjectContext.fetch(request)
        return selectedPoi
        
    }
    // MARK: - Manage  Categories
    
    func addCategorie(name: String,nbRecords:Int32,state:String) {
        if(name.isBlank){return}
        let categorie = Category(context: managedObjectContext)
        categorie.name = name
        categorie.icon = getCategoryPinIcon(name)
        categorie.nbRecords = nbRecords
        categorie.state = state
        
        coreDataStack.saveContext()
        
    }
    func deleteAllcategories() {
        categories.forEach { managedObjectContext.delete($0) }
        coreDataStack.saveContext()
        
    }
    func deletecategorie(elem:Category) {
        managedObjectContext.delete(elem)
        coreDataStack.saveContext()
        
    }
    func selectCategory(_ category:Category){
        category.selected = true
        coreDataStack.saveContext()
    }
    func unselectCategory(_ category:Category){
        category.selected = false
        coreDataStack.saveContext()
        
    }
    func unselectAllCategory(){
        for category in categories{
            unselectCategory(category)
        }
        
        
    }
    
    // MARK: - Manage  Point of Interest
    
    func addPoi(categorie:Category,pois:[Records]) {
        for poiData:Records in pois{
            guard poiData.record != nil else{continue}
            guard let record:Record = poiData.record else {continue}
            let id = record.id
            guard  let fields = record.fields else{continue}
            let name = fields.name
            let address = fields.address
            let telephon = fields.telephon
            let email = fields.email
            let point = fields.pointgeo
            let longitude = (point?.longitude) ?? -1.0
            let latitude = (point?.latitude) ?? -1.0
            guard (latitude != -1.0 && longitude != -1.0) else{continue}
            let poi = Poi(context: managedObjectContext)
            poi.category = categorie
            poi.id = id
            poi.latitude = latitude
            poi.address = address
            poi.longitude = longitude
            poi.name = name
            poi.email = email
            poi.telephon = telephon
            coreDataStack.saveContext()
            
        }
    }
   
    func getPoiByLocation(longitude:Double,latitude:Double)->Poi?{
        let request: NSFetchRequest<Poi> = Poi.fetchRequest()
        let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", NSNumber(value: longitude), NSNumber(value: latitude))
        request.predicate =  predicate
        let  selectedPoi = try? managedObjectContext.fetch(request)
        guard (selectedPoi?.count)! > 0 else{return nil}
       
        return selectedPoi![0]
       
    }
   
    func addPoiToFavorit(poi:Poi?){
        guard poi != nil else{return}
        poi!.favorit = true
        coreDataStack.saveContext()
    }
    func removePoiToFavorit(poi:Poi?){
        guard poi != nil else{return}
        poi!.favorit = false
        coreDataStack.saveContext()
    }
    //MARK: - return rhe pin icon nome of a category
    
    func getCategoryPinIcon(_ poiCategory:String)-> String{
        var pinIcon = ""
        let dicIcon=["Arbre à fruits comestibles":  "fruitTree",
                     "Espace adopté":"adoptedPin",
                     "Espace adopté (ophm)":"adoptedPin",
                     "Jardins familiaux":"familyGardenPin",
                     "Jardin partagé": "sharedGarden",
                     "Label Jardins Remarquables": "remarkableGarden",
                     "Micro ferme urbaine": "microFarm",
                     "Micro-espace on sème":"seedPin",
                     "Parc": "parkPin",
                     "Site en gestion différenciée":"differentiatedManagement",
                     "Square":"square",
                     "abri pour la faune":"animalPin",
                     "arbre": "treePin",
                     "jardin associatif":"associatifGarden",
                     "jardin associatif des murs à pêches":"associatifGarden",
                     "default":  "default"
        ]
        guard let pinIcon =  dicIcon[poiCategory] else{
            return dicIcon["default"]! }
        return pinIcon
    
    }
}


