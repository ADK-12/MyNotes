//
//  NoteCollectionViewCell.swift
//  MyNotes
//
//  Created by Aditya Khandelwal on 14/08/25.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var displayImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    
    var note: NoteEntity? {
        didSet {
            cellConfiguration()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        displayImage.layer.cornerRadius = 8
        // Initialization code
    }
    
    
    func cellConfiguration() {
        guard let note else { return }
        
        if let text = note.text, let date = note.dateEdited {
            let heading: String
            let whenEdited: String
            
            let lines = text.components(separatedBy: .newlines)
            let nonEmptyLines = lines.filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            if nonEmptyLines.isEmpty {
                heading = "New Note"
            } else {
                heading = nonEmptyLines[0].trimmingCharacters(in: .whitespaces)
            }
            
            let formatter = DateFormatter()
            let calendar = Calendar.current
            let noteEditedDay = calendar.component(.day, from: date)
            let currentDay = calendar.component(.day, from: Date())
            
            if noteEditedDay == currentDay {
                formatter.dateFormat = "h:mm a"
                formatter.amSymbol = "AM"
                formatter.pmSymbol = "PM"
                whenEdited = formatter.string(from: date)
            } else if noteEditedDay + 1 == currentDay {
                whenEdited = "Yesterday"
            } else if noteEditedDay + 7 > currentDay {
                whenEdited = "\(calendar.component(.weekday, from: date))"
            } else {
                formatter.dateFormat = "dd/MM/yy"
                whenEdited = formatter.string(from: date)
            }
            
            title.text = heading
            subtitle.text = whenEdited
        }
    }

}
