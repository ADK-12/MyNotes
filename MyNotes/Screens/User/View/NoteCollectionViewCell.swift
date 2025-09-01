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
            
            let now = Date()
            let startOfToday = calendar.startOfDay(for: now)
            let startOfDate = calendar.startOfDay(for: date)
                
            let components = calendar.dateComponents([.day], from: startOfDate, to: startOfToday)
            
            if let dayDifference = components.day {
                if dayDifference == 0 {
                    formatter.dateFormat = "h:mm a"
                    formatter.amSymbol = "AM"
                    formatter.pmSymbol = "PM"
                    whenEdited = formatter.string(from: date)
                } else if dayDifference == 1 {
                    whenEdited = "Yesterday"
                } else if dayDifference < 7 {
                    formatter.dateFormat = "EEEE"
                    whenEdited = formatter.string(from: date)
                } else {
                    formatter.dateFormat = "dd/MM/yy"
                    whenEdited = formatter.string(from: date)
                }
            } else {
                whenEdited = ""
            }
            
            title.text = heading
            subtitle.text = whenEdited
            
            let textView = UITextView()
            textView.text = text
            textView.frame = CGRect(x: 0, y: 0, width: 200, height: 150)
            textView.font = UIFont.systemFont(ofSize: 13)
            textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
            
            let renderer = UIGraphicsImageRenderer(size: textView.bounds.size)
            let image = renderer.image { ctx in
                textView.layer.render(in: ctx.cgContext)
            }
            displayImage.image = image
        }
    }

}
