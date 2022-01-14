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
        guard let ingredients = try? managedObjectContext.fetch(request) else {return [] }
        return ingredients
    }
   
    
   
    
    // MARK: - Manage  Categories
    
    func addCategorie(id:Int32,name: String,count:Int32) {
        if(name.isBlank){return}
        let categorie = Genre(context: managedObjectContext)
        categorie.name = name
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
    
  
}


