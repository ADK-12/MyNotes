//
//  NotePreviewViewController.swift
//  MyNotes
//
//  Created by Aditya Khandelwal on 16/08/25.
//

import UIKit

class NotePreviewViewController: UIViewController {

    var noteText: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.text = noteText
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16)
        ])
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
