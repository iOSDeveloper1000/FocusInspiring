//
//  DataController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation
import CoreData


class DataController {
    
    let persistentContainer: NSPersistentContainer!
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            completion?()
        }
    }
    
    func saveViewContext() {
        
        if viewContext.hasChanges {
            
            do {
                try viewContext.save()
            
                print("Succesfully saved")
            } catch {
                print("Could not save viewContext")
                
                // @todo
            }
        }
    }
}
