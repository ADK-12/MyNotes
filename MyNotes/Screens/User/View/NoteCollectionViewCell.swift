//
//  NoteCollectionViewCell.swift
//  MyNotes
//
//  Created by Aditya Khandelwal on 14/08/25.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var displayImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    
    var note: NoteEntity? {
        didSet {
            cellConfiguration()
        }
    }
    
    var inSelectionMode: Bool? {
        didSet {
            changeView()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                selectButton.tintColor = UIColor(red: 214/255, green: 170/255, blue: 6/255, alpha: 1)
                displayImage.layer.borderWidth = 2
                displayImage.layer.borderColor = UIColor(red: 214/255, green: 170/255, blue: 6/255, alpha: 1).cgColor
            } else {
                selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
                selectButton.tintColor = .lightGray
                displayImage.layer.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        displayImage.layer.cornerRadius = 8
        selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
        selectButton.tintColor = .lightGray
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
    
    func changeView() {
        guard let inSelectionMode else { return }
        
        selectButton.isHidden = !inSelectionMode
    }

}
