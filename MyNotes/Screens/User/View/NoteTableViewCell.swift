//
//  NoteTableViewCell.swift
//  MyNotes
//
//  Created by Aditya Khandelwal on 14/08/25.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    
    var note: NoteEntity? {
        didSet {
            cellConfiguration()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfiguration() {
        guard let note else { return }
        
        if let text = note.text, let date = note.dateEdited {
            let heading: String
            let body: String
            let whenEdited: String
            
            let lines = text.components(separatedBy: .newlines)
            let nonEmptyLines = lines.filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            if nonEmptyLines.isEmpty {
                heading = "New Note"
                body = "No additinal text"
            } else if nonEmptyLines.count == 1 {
                heading = nonEmptyLines[0].trimmingCharacters(in: .whitespaces)
                body = "No additinal text"
            } else {
                heading = nonEmptyLines[0].trimmingCharacters(in: .whitespaces)
                body = nonEmptyLines[1].trimmingCharacters(in: .whitespaces)
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
            subtitle.text = whenEdited + "   " + body
        }
    }
    
}
