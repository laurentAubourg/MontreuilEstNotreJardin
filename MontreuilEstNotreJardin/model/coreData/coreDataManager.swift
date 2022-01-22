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
    
    var categories: [Genre] {
        let request: NSFetchRequest<Genre> = Genre.fetchRequest()
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
        let categorie = Genre(context: managedObjectContext)
        categorie.name = name
        categorie.nbRecords = nbRecords
        categorie.state = state
        
        coreDataStack.saveContext()
        
    }
    func deleteAllcategories() {
        categories.forEach { managedObjectContext.delete($0) }
        coreDataStack.saveContext()
        
    }
    func deletecategorie(elem:Genre) {
        managedObjectContext.delete(elem)
        coreDataStack.saveContext()
        
    }
    func selectCategory(_ category:Genre){
        category.selected = true
        coreDataStack.saveContext()
    }
    func unselectCategory(_ category:Genre){
        category.selected = false
        coreDataStack.saveContext()
        
    }
    //MARK: - Retrieves the selected categories
    
    func getSelectedCategories()->[Genre]?{
        
        let request: NSFetchRequest<Genre> = Genre.fetchRequest()
        request.predicate =  NSPredicate(format:"selected == %@",NSNumber(value: true))
       
      let  selectedCategories = try! managedObjectContext.fetch(request)
        return selectedCategories
    }
    // MARK: - Manage  Point of Interest
    
    func addPoi(categorie:Genre,pois:[records]) {
        for pointData:records in pois{
            guard pointData.record != nil else{continue}
            let record:record = pointData.record!
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
}


