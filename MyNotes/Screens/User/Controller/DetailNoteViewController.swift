//
//  DetailViewController.swift
//  Project31
//
//  Created by Aditya Khandelwal on 26/05/25.
//

import UIKit
import CoreData

class DetailNoteViewController: UIViewController {
    
    @IBOutlet var dateEditedLabel: UILabel!
    @IBOutlet var textView: UITextView!
    
    private let manager = CoreDataManager()
    
    var note: NoteEntity?
    
    var shareButton = UIBarButtonItem()
    var doneButton = UIBarButtonItem()
    var undoButton = UIBarButtonItem()
    var redoButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConfiguration()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if note == nil {
            textView.becomeFirstResponder()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let text = textView.text {
            if let note {
                if let previousText = note.text {
                    if text != previousText {
                        let updatedNote = Note(text: text, dateCreated: nil, dateEdited: Date())
                        manager.updateNote(updatedNote: updatedNote, noteEntity: note)
                    }
                }
            } else {
                let newNote = Note(text: text, dateCreated: Date(), dateEdited: Date())
                manager.addNote(newNote)
            }
        }
    }
    
    
    func setupConfiguration() {
        navigationBarConfiguration()
        
        setupTextviewText()
        
        setupTextViewStyle()
        
        addKeyboardObserver()
    }
    
    
    func navigationBarConfiguration() {
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        undoButton = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward.circle"), style: .plain, target: self, action: #selector(undoTapped))
        redoButton = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.forward.circle"), style: .plain, target: self, action: #selector(redoTapped))
        redoButton.isEnabled = false
        
        navigationItem.rightBarButtonItems = [shareButton]
    }
    
    
    @objc func shareTapped() {
        if let text = textView.text {
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    
    @objc func doneTapped() {
        textView.resignFirstResponder()
    }
    
    
    @objc func undoTapped() {
        textView.undoManager?.undo()
        if let undoManager = textView.undoManager {
            undoButton.isEnabled = undoManager.canUndo
        }
    }
    
    
    @objc func redoTapped() {
        textView.undoManager?.redo()
        
        if let undoManager = textView.undoManager {
            redoButton.isEnabled = undoManager.canRedo
        }
    }
    
    
    func setupTextviewText() {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy 'at' h:mm a"
        
        if let note {
            textView.text = note.text
            dateEditedLabel.text = formatter.string(from: note.dateEdited ?? Date())
        } else {
            dateEditedLabel.text = formatter.string(from: Date())
        }
    }
    
    
    func setupTextViewStyle() {
        guard let fullText = textView.text else { return }
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        if let firstLineEndIndex = fullText.firstIndex(of: "\n") {
            let firstLineRange = NSRange(fullText.startIndex..<firstLineEndIndex, in: fullText)
            let restTextRange = NSRange(firstLineEndIndex..<fullText.endIndex, in: fullText)
            
            let firstLineFont = UIFont.boldSystemFont(ofSize: 24)
            let restTextFont = UIFont.systemFont(ofSize: 16)
            
            attributedString.addAttribute(.font, value: firstLineFont, range: firstLineRange)
            attributedString.addAttribute(.font, value: restTextFont, range: restTextRange)
            
        } else {
            let fullRange = NSRange(fullText.startIndex..<fullText.endIndex, in: fullText)
            let firstLineFont = UIFont.boldSystemFont(ofSize: 24)
            attributedString.addAttribute(.font, value: firstLineFont, range: fullRange)
        }
        
        textView.attributedText = attributedString
    }
    
    
    func addKeyboardObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
}



extension DetailNoteViewController: UITextViewDelegate  {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItems = [doneButton, shareButton]
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItems = [doneButton, shareButton, redoButton, undoButton]
        
        if let undoManager = textView.undoManager {
            undoButton.isEnabled = undoManager.canUndo
            redoButton.isEnabled = undoManager.canRedo
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy 'at' h:mm a"
        dateEditedLabel.text = formatter.string(from: Date())
        
        setupTextViewStyle()
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItems = [shareButton]
    }
    
}
