//
//  DataController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import Foundation
import CoreData


// MARK: DataController

class DataController {

    // MARK: Properties

    let persistentContainer: NSPersistentContainer!
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var backgroundContext: NSManagedObjectContext!


    // MARK: Setup

    init(modelName: String) {

        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {

        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }

            self.backgroundContext = self.persistentContainer.newBackgroundContext()

            self.configureContexts()
            //self.autoSaveBackgroundContext()
            
            completion?()
        }
    }

    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true

        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }


    // MARK: Saving

    /// Normal saving of main managed object context
    func saveViewContext() {
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            
                print("Successfully saved")
            } catch {
                print("Could not save viewContext: \(error.localizedDescription)")
                
                // @todo
            }
        }
    }

    /// Save background managed object context (used for temporary user input)
    func saveBackgroundContext() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Could not save in background: \(error.localizedDescription)")
            }
        }
    }

    /// Autosave temporary user input before final save
    private func autoSaveBackgroundContext(interval: TimeInterval = 40) {
        print("Autosaving in background (Time: \(Date()))")

        guard interval > 0 else {
            print("Autosave interval must be positive")
            return
        }

        if backgroundContext.hasChanges {
            try? backgroundContext.save()
        }

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + interval) {
            self.autoSaveBackgroundContext()
        }
    }
}
