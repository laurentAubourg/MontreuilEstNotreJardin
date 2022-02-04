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
    //MARK: - Retrieves the selected categories
    
    func getSelectedCategories()->[Category]?{
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate =  NSPredicate(format:"selected == %@",NSNumber(value: true))
       
      let  selectedCategories = try! managedObjectContext.fetch(request)
        return selectedCategories
    }
    
  
    // MARK: - Manage  Point of Interest
    
    func addPoi(categorie:Category,pois:[Records]) {
        for pointData:Records in pois{
            guard pointData.record != nil else{continue}
            let record:Record = pointData.record!
            var id:String
            var longitude:Double
            var latitude:Double
            var name:String
            var address: String
            let email:String
            var telephon:String
            if record.id != nil{
                id = record.id!
            }else{
                id = ""
            }
            if record.fields != nil{
                let fields = record.fields!
                guard fields.name != nil else{
                    continue
                }
                name = fields.name!
                if fields.address != nil {
                    address = fields.address!
                }else{
                    continue
                }
                if fields.telephon != nil {
                    telephon = fields.telephon!
                }else{
                    telephon = "NC"
                }
                if fields.email != nil {
                    email = fields.email!
                }else{
                    continue
                }
                guard fields.pointgeo != nil else{continue}
                let point = fields.pointgeo
                
                
                if (fields.telephon != nil){
                    telephon = fields.telephon!
                }
                
                
                longitude = (point?.longitude)!
                latitude = (point?.latitude)!
                
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
            }else{
                continue
            }
        }
    }
    func deleteAllpois() {
        pois.forEach { managedObjectContext.delete($0) }
        coreDataStack.saveContext()
        
    }
    func deletePoi(elem:Poi) {
        managedObjectContext.delete(elem)
        coreDataStack.saveContext()
        
    }
    func getPoiByLocation(longitude:Double,latitude:Double)->Poi{
        let request: NSFetchRequest<Poi> = Poi.fetchRequest()
        let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", NSNumber(value: longitude), NSNumber(value: latitude))
        request.predicate =  predicate
        let  selectedPoi = try! managedObjectContext.fetch(request)
        return selectedPoi[0]
    }
    func getFavoritesPoi()->[Poi]{
        let request: NSFetchRequest<Poi> = Poi.fetchRequest()
        let predicate = NSPredicate(format:"favorit == %@",NSNumber(value: true))
        request.predicate =  predicate
        let  selectedPoi = try! managedObjectContext.fetch(request)
        return selectedPoi
        
    }
    func addPoiToFavorit(_ poi:Poi?){
        guard poi != nil else{return}
        poi!.favorit = true
        coreDataStack.saveContext()
    }
    func removePoiToFavorit(_ poi:Poi?){
        guard poi != nil else{return}
        poi!.favorit = false
        coreDataStack.saveContext()
    }
    //MARK: - return rhe pin icon nome of a category
    
    func getCategoryPinIcon(_ poiCategory:String)-> String{
        var pinIcon = ""
        switch poiCategory{
        case "Arbre à fruits comestibles": pinIcon = "treePin"
        case "Espace adopté": pinIcon = "adoptedPin"
        case "Espace adopté (ophm)": pinIcon = "adoptedPin"
        case "Jardins familiaux": pinIcon = "familyGardenPin"
        case "Jardin partagé": pinIcon = "sharedGarden"
        case "Label Jardins Remarquables": pinIcon = "gardenPin"
        case "Micro ferme urbaine": pinIcon = "greenMapPin"
        case "Micro-espace on sème": pinIcon = "seedPin"
        case "Parc": pinIcon = "parkPin"
        case "Site en gestion différenciée": pinIcon = "greenMapPin"
        case "Square": pinIcon = "greenMapPin"
        case "abri pour la faune": pinIcon = "animalPin"
        case "arbre": pinIcon = "treePin"
        case "jardin associatif": pinIcon = "gardenPin"
        default: pinIcon = "greenMapPin"
        }
        return pinIcon
    }
}


