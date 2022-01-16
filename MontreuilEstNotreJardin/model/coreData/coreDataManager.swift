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
    
    func addCategorie(name: String,count:Int32,state:String) {
        if(name.isBlank){return}
        let categorie = Genre(context: managedObjectContext)
        categorie.name = name
        categorie.count = count
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
    // MARK: - Manage  Point of Interest
    
    func addPoi(categorie:Genre,pois:[records]) {
        for pointData:records in pois{
            guard pointData.record != nil else{continue}
            let record:record = pointData.record!
            var id:String
            
            var longitude:Double
            var latitude:Double
            var name:String
            var adress: String
            var telephon:String
           if record.id != nil{
                id = record.id!
            }else{
                id = ""
            }
            if record.fields != nil{
                let fields = record.fields!
                if fields.pointgeo != nil {
                    let point = fields.pointgeo
                    guard point?.longitude != nil else{

                        continue
                    }
                    longitude = (point?.longitude)!
                    guard point?.latitude != nil else{
                        continue
                      
                    }
                    latitude = (point?.latitude)!
                   }
                if (fields.telephon != nil){
                    telephon = fields.telephon!
                }
                let Poi = Poi(
            }else{
                continue
            }
        }
        
        
    }
  
}


