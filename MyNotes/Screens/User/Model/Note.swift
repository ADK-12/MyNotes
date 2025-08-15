//
//  Note.swift
//  MyNotes
//
//  Created by Aditya Khandelwal on 13/08/25.
//

import Foundation

struct Note {
    var text: String
    var dateCreated: Date?
    var dateEdited: Date
    var isPinned = false
}
