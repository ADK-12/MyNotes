//
//  CoreDataManager.swift
//  MyNotes
//
//  Created by Aditya Khandelwal on 13/08/25.
//

import UIKit
import CoreData

class CoreDataManager {
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    
    func fetchNotes() -> [NoteEntity] {
        var notes = [NoteEntity]()
        
        do {
            notes = try context.fetch(NoteEntity.fetchRequest())
        } catch {
            print("Fetch users error:", error)
        }
        
        return notes
    }
    
    
    func addNote(_ note: Note) {
        let noteEntity = NoteEntity(context: context)
        noteEntity.text = note.text
        noteEntity.dateCreated = note.dateCreated
        noteEntity.dateEdited = note.dateEdited
        noteEntity.isPinned = false

        saveContext()
    }
    
    
    func updateNote(updatedNote: Note, noteEntity: NoteEntity) {
        noteEntity.text = updatedNote.text
        noteEntity.dateEdited = updatedNote.dateEdited

        saveContext()
    }
    
    
    func deleteNote(_ noteEntity: NoteEntity) {
        context.delete(noteEntity)
        
        saveContext()
    }
    
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("User saving error:", error)
        }
    }
    
    
    
}
