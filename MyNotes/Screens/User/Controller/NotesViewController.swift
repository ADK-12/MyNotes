//
//  ViewController.swift
//  Project31
//
//  Created by Aditya Khandelwal on 26/05/25.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet var notesTableView: UITableView!
    @IBOutlet var notesCollectionView: UICollectionView!
    
    private let manager = CoreDataManager()
    
    var notes = [NoteEntity]()
    
    var pinnedNotes = [Note]()
    
    var searchController = UISearchController()
    
    var totalLabel = UILabel()
    
    var totalNotes = 0 {
        didSet {
            if notes.count == 0 {
                totalLabel.text = "No Notes"
            }
            if notes.count > 1 {
                totalLabel.text = "\(notes.count) Notes"
            } else {
                totalLabel.text = "\(notes.count) Note"
            }
        }
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set Title
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Yellow Theme Color
        navigationController?.navigationBar.tintColor = UIColor(red: 214/255, green: 170/255, blue: 6/255, alpha: 1)
        
        //setup search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        
        
        
        
        
        // More options menu
        setupMenuForTableView()
        
        
        
        
        
        //Toolbar Design
        totalLabel = UILabel()
        totalLabel.text = "No Notes"
        totalLabel.font = UIFont.systemFont(ofSize: 10)
        totalLabel.textColor = .black
        totalLabel.sizeToFit()
        let totalNotesLabel = UIBarButtonItem(customView: totalLabel)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addTapped))
        addButton.tintColor = UIColor(red: 214/255, green: 170/255, blue: 6/255, alpha: 1)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [spacer, totalNotesLabel, spacer, addButton]
        navigationController?.isToolbarHidden = false
        
    
        notesCollectionView.isHidden = true
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesCollectionView.delegate = self
        notesCollectionView.dataSource = self
        
        notesTableView.allowsMultipleSelection = true
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        for (index,note) in notes.enumerated() {
//            if note.text.isEmpty {
//                notes.remove(at: index)
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesSearchBarWhenScrolling = false
        
        notes = manager.fetchNotes()
        
        notesTableView.reloadData()
        notesCollectionView.reloadData()
        
        totalNotes = notes.count
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let note = notes.last {
            if let text = note.text {
                if text.isEmpty{
                    manager.deleteNote(note)
                    notes.remove(at: notes.count - 1)
                    notesTableView.deleteRows(at: [IndexPath(row: notes.count, section: 0)], with: .top)
                    notesCollectionView.deleteItems(at: [IndexPath(row: notes.count, section: 0)])
                }
            }
        }
        
        totalNotes = notes.count
    }
    
    
    func setupMenuForTableView() {
        
        
        let sortSubmenu = UIMenu(title: "Sort By", image: UIImage(systemName: "arrow.up.arrow.down"), children: [
            UIAction(title: "Date Edited (Default)", state: .on, handler: sortByDateEdited),
            UIAction(title: "Date Created", handler: sortByDateCreated),
            UIAction(title: "Title", handler: sortByTitle)
            
        ])
        sortSubmenu.subtitle = "Date Edited (Default)"
        
        let menuItems1 = [
            UIAction(title: "View as Gallary",image: UIImage(systemName: "square.grid.2x2"), handler: galleryView)
            ]
        let menuItems2 = [
            UIAction(title: "Select Notes", image: UIImage(systemName: "checkmark.circle"), handler: selectNotes) ,
            sortSubmenu
            ]
        
        let menu1 = UIMenu(title: "", options: .displayInline, children: menuItems1)
        
        let menu2 = UIMenu(title: "", options: .displayInline, children: menuItems2)
        
        let menu = UIMenu(title: "", children: [menu1, menu2])
        
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem = moreButton
    }
    
    
    func setupmenuForCollectionView() {
        let sortSubmenu = UIMenu(title: "Sort By", image: UIImage(systemName: "arrow.up.arrow.down"), children: [
            UIAction(title: "Date Edited (Default)", state: .on, handler: sortByDateEdited),
            UIAction(title: "Date Created", handler: sortByDateCreated),
            UIAction(title: "Title", handler: sortByTitle)
            
        ])
        sortSubmenu.subtitle = "Date Edited (Default)"
        
        let menuItems1 = [
            UIAction(title: "View as List",image: UIImage(systemName: "square.grid.2x2"), handler: listView)
            ]
        let menuItems2 = [
            UIAction(title: "Select Notes", image: UIImage(systemName: "checkmark.circle"), handler: selectNotes) ,
            sortSubmenu
            ]
        
        let menu1 = UIMenu(title: "", options: .displayInline, children: menuItems1)
        
        let menu2 = UIMenu(title: "", options: .displayInline, children: menuItems2)
        
        let menu = UIMenu(title: "", children: [menu1, menu2])
        
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem = moreButton
    }
    
    
    func galleryView(action: UIAction) {
        setupmenuForCollectionView()
        notesTableView.isHidden = true
        notesCollectionView.isHidden = false
    }
    
    
    func listView(action: UIAction) {
        setupMenuForTableView()
        notesTableView.isHidden = false
        notesCollectionView.isHidden = true
    }
    
    
    
    func sortByDateCreated(action: UIAction) {
        
    }
    
    func sortByDateEdited(action: UIAction) {
        
    }
    
    func sortByTitle(action: UIAction) {
        
    }
    
    
    func selectNotes(action: UIAction) {
        
    }
    
    
    @objc func addTapped() {
        addUpdateNote()
    }
    
    func addUpdateNote(note: NoteEntity? = nil) {
        guard let detailNoteVC = storyboard?.instantiateViewController(withIdentifier: "DetailNoteViewController") as? DetailNoteViewController else { return }
        detailNoteVC.note = note
        navigationController?.pushViewController(detailNoteVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableCell") as! NoteTableCell
        
        
        let note = notes[indexPath.row]
        
        if let text = note.text {
            let title: String
            let body: String
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"

            let lines = text.components(separatedBy: .newlines)
            let nonEmptyLines = lines.filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            if nonEmptyLines.isEmpty {
                title = "New Note"
                body = "No additinal text"
            } else if nonEmptyLines.count == 1 {
                title = nonEmptyLines[0].trimmingCharacters(in: .whitespaces)
                body = "No additinal text"
            } else {
                title = nonEmptyLines[0].trimmingCharacters(in: .whitespaces)
                body = nonEmptyLines[1].trimmingCharacters(in: .whitespaces)
            }
            
            cell.title.text = title
            cell.subtitle.text = formatter.string(from: note.dateCreated ?? Date()) + "  " + body
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCollectionCell", for: indexPath) as! NoteCollectionCell
        
        let note = notes[indexPath.row]
        
        if let text = note.text {
            let title: String
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"

            let lines = text.components(separatedBy: .newlines)
            let nonEmptyLines = lines.filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            if nonEmptyLines.isEmpty {
                title = "New Note"
            } else {
                title = nonEmptyLines[0].trimmingCharacters(in: .whitespaces)
            }
            
            cell.title.text = title
            cell.subtitle.text = formatter.string(from: note.dateCreated ?? Date())
        }
        
        
        
        return cell
        
    }
        
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addUpdateNote(note: notes[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addUpdateNote(note: notes[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            self.manager.deleteNote(self.notes[indexPath.row])
            self.notes.remove(at: indexPath.row)
            self.notesTableView.deleteRows(at: [indexPath], with: .top)
            self.notesCollectionView.deleteItems(at: [indexPath])
            self.totalNotes = self.notes.count
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    

}

