//
//  DetailViewController.swift
//  Project31
//
//  Created by Aditya Khandelwal on 26/05/25.
//

import UIKit
import CoreData

class DetailNoteViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    private let manager = CoreDataManager()
    
    var note: NoteEntity?
    
    var doneButton: UIBarButtonItem?
    var undoButton: UIBarButtonItem?
    var redoButton: UIBarButtonItem?
    
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
        
        if let note {
            textView.text = note.text
        }
        
        setupTextViewStyle()
        
        updateFrameForKeyboard()
    }
    
    
    func navigationBarConfiguration() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undoTapped))
        redoButton = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redoTapped))
        
        navigationItem.rightBarButtonItem = shareButton
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
        
    }
    
    
    @objc func redoTapped() {
        
    }
    
    
    func updateFrameForKeyboard() {
        //        let notificationCenter = NotificationCenter.default
        //        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        //        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func adjustForKeyboard(notificatin: Notification){
        
        guard let keyboardValue = notificatin.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notificatin.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
        
    }
    
    
    func setupTextViewStyle() {
//        guard let fullText = textView.text else { return }
//
//        let attributedString = NSMutableAttributedString(string: fullText)
//
//        if let firstLineEndIndex = fullText.firstIndex(of: "\n") {
//            let firstLineRange = NSRange(fullText.startIndex..<firstLineEndIndex, in: fullText)
//            let restRange = NSRange(firstLineEndIndex..<fullText.endIndex, in: fullText)
//
//            // Fonts
//            let firstLineFont = UIFont.boldSystemFont(ofSize: 24)
//            let restFont = UIFont.systemFont(ofSize: 16)
//
//            // Apply styles
//            attributedString.addAttribute(.font, value: firstLineFont, range: firstLineRange)
//            attributedString.addAttribute(.font, value: restFont, range: restRange)
//
//        } else {
//            // No newline, style whole text as first line
//            let fullRange = NSRange(fullText.startIndex..<fullText.endIndex, in: fullText)
//            let firstLineFont = UIFont.boldSystemFont(ofSize: 24)
//            attributedString.addAttribute(.font, value: firstLineFont, range: fullRange)
//        }
//
//        textView.attributedText = attributedString
    }
}


extension DetailNoteViewController: UITextViewDelegate  {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItems?.insert(doneButton!, at: 0)
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItems?.remove(at: 0)
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
//
//        // Save current cursor position
//        let selectedRange = textView.selectedRange
//
//        // Update styles
//        updateTextViewStyle()
//
//        // Restore cursor position
//        textView.selectedRange = selectedRange
    }
    
}
