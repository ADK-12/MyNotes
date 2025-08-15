//
//  ViewController.swift
//  Project31
//
//  Created by Aditya Khandelwal on 26/05/25.
//

import UIKit

class NotesViewController: UIViewController {
    
    @IBOutlet var notesTableView: UITableView!
    @IBOutlet var notesCollectionView: UICollectionView!
    
    private let manager = CoreDataManager()
    
    var notes = [NoteEntity]()
    var pinnedNotes = [NoteEntity]()
    
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
    
    let userDefaults = UserDefaults.standard
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        notes = manager.fetchNotes()
        
        setupPinnedNotes()
        
        sortNotes()
        
        setupDataAndMoreOptionButton()
        
        totalNotes = notes.count + pinnedNotes.count
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConfiguration()
        
        notesTableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
        notesCollectionView.register(UINib(nibName: "NoteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoteCollectionViewCell")
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        for (index,note) in notes.enumerated() {
            if let text = note.text {
                if text.isEmpty{
                    manager.deleteNote(note)
                    notes.remove(at: index)
                    notesTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .top)
                    notesCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
            }
        }
        
        for (index,note) in pinnedNotes.enumerated() {
            if let text = note.text {
                if text.isEmpty{
                    manager.deleteNote(note)
                    notes.remove(at: index)
                    notesTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .top)
                    notesCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
            }
        }
        
        totalNotes = notes.count + pinnedNotes.count
    }
    
    
    func setupPinnedNotes() {
        pinnedNotes.removeAll()
        
        for (index,note) in notes.enumerated() {
            if note.isPinned {
                pinnedNotes.append(note)
                notes.remove(at: index)
            }
        }
    }
    
    
    func sortNotes() {
        if userDefaults.bool(forKey: "sortByDateCreated") {
            notes.sort { $0.dateCreated ?? Date() > $1.dateCreated ?? Date() }
            pinnedNotes.sort { $0.dateCreated ?? Date() > $1.dateCreated ?? Date() }
        } else if userDefaults.bool(forKey: "sortByTitle") {
            notes.sort { $0.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" < $1.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" }
            pinnedNotes.sort { $0.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" < $1.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" }
        } else {
            notes.sort { $0.dateEdited ?? Date() > $1.dateEdited ?? Date() }
            pinnedNotes.sort { $0.dateEdited ?? Date() > $1.dateEdited ?? Date() }
        }
    }
    
    
    func setupConfiguration() {
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(red: 214/255, green: 170/255, blue: 6/255, alpha: 1)
        
        setupSearchController()
        
        setupToolbar()
    }
    
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    func setupDataAndMoreOptionButton() {
        let viewAsListAction = UIAction(title: "View as List",image: UIImage(systemName: "square.grid.2x2"), handler: listView)
        let viewAsGalleryAction = UIAction(title: "View as Gallary",image: UIImage(systemName: "square.grid.2x2"), handler: galleryView)
        let selectNotesAction = UIAction(title: "Select Notes", image: UIImage(systemName: "checkmark.circle"), handler: selectNotes)
        let sortByDateEditedAction = UIAction(title: "Date Edited (Default)", handler: sortByDateEdited)
        let sortByDateCreatedAction = UIAction(title: "Date Created", handler: sortByDateCreated)
        let sortByTitleAction = UIAction(title: "Title", handler: sortByTitle)
        
        let sortBySubmenu = UIMenu(title: "Sort By", image: UIImage(systemName: "arrow.up.arrow.down"), children: [
            sortByDateEditedAction,
            sortByDateCreatedAction,
            sortByTitleAction,
        ])
        
        var menuSection1 = UIMenu()
        let menuSection2 = UIMenu(title: "", options: .displayInline, children: [selectNotesAction, sortBySubmenu])
        
        if userDefaults.bool(forKey: "isGalleryView") {
            notesCollectionView.reloadData()
            notesCollectionView.isHidden = false
            notesTableView.isHidden = true
            
            menuSection1 = UIMenu(title: "", options: .displayInline, children: [viewAsListAction])
        } else {
            notesTableView.reloadData()
            notesCollectionView.isHidden = true
            notesTableView.isHidden = false
            
            menuSection1 = UIMenu(title: "", options: .displayInline, children: [viewAsGalleryAction])
        }
        
        if userDefaults.bool(forKey: "sortByDateCreated") {
            sortByDateCreatedAction.state = .on
            sortBySubmenu.subtitle = sortByDateCreatedAction.title
        } else if userDefaults.bool(forKey: "sortByTitle") {
            sortByTitleAction.state = .on
            sortBySubmenu.subtitle = sortByTitleAction.title
        } else {
            sortByDateEditedAction.state = .on
            sortBySubmenu.subtitle = sortByDateEditedAction.title
        }
        
        let menu = UIMenu(title: "", children: [menuSection1, menuSection2])
        
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem = moreButton
        
    }
    
    
    func galleryView(action: UIAction) {
        userDefaults.set(true, forKey: "isGalleryView")
        setupDataAndMoreOptionButton()
    }
    
    
    func listView(action: UIAction) {
        userDefaults.set(false, forKey: "isGalleryView")
        setupDataAndMoreOptionButton()
    }
    
    
    func sortByDateEdited(action: UIAction) {
        userDefaults.set(false, forKey: "sortByDateCreated")
        userDefaults.set(false, forKey: "sortByTitle")
        notes.sort { $0.dateEdited ?? Date() > $1.dateEdited ?? Date() }
        pinnedNotes.sort { $0.dateEdited ?? Date() > $1.dateEdited ?? Date() }
        setupDataAndMoreOptionButton()
    }
    
    
    func sortByDateCreated(action: UIAction) {
        userDefaults.set(true, forKey: "sortByDateCreated")
        userDefaults.set(false, forKey: "sortByTitle")
        notes.sort { $0.dateCreated ?? Date() > $1.dateCreated ?? Date() }
        pinnedNotes.sort { $0.dateCreated ?? Date() > $1.dateCreated ?? Date() }
        setupDataAndMoreOptionButton()
    }
    
    
    func sortByTitle(action: UIAction) {
        userDefaults.set(false, forKey: "sortByDateCreated")
        userDefaults.set(true, forKey: "sortByTitle")
        notes.sort { $0.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" < $1.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" }
        pinnedNotes.sort { $0.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" < $1.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? "" }
        setupDataAndMoreOptionButton()
    }
    
    
    func selectNotes(action: UIAction) {
        
    }
    
    
    func setupToolbar() {
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
    }
    
    
    @objc func addTapped() {
        addUpdateNote()
    }
    
    
    func addUpdateNote(note: NoteEntity? = nil) {
        guard let detailNoteVC = storyboard?.instantiateViewController(withIdentifier: "DetailNoteViewController") as? DetailNoteViewController else { return }
        detailNoteVC.note = note
        navigationController?.pushViewController(detailNoteVC, animated: true)
    }
    
    
    @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: notesTableView)
            
            if let indexPath = notesTableView.indexPathForRow(at: touchPoint) {
                
            }
            
        }
    }
    
}



extension NotesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
}



extension NotesViewController: UITableViewDataSource, UICollectionViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pinnedNotes.isEmpty ? 1 : 2
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pinnedNotes.isEmpty ? 1 : 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !pinnedNotes.isEmpty {
            if section == 0 {
                return pinnedNotes.count
            }
        }
        
        return notes.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !pinnedNotes.isEmpty {
            if section == 0 {
                return pinnedNotes.count
            }
        }
        
        return notes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as? NoteTableViewCell else {
            return UITableViewCell()
        }
        
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                cell.note = pinnedNotes[indexPath.row]
                return cell
            }
        }
        
        cell.note = notes[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCollectionViewCell", for: indexPath) as? NoteCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                cell.note = pinnedNotes[indexPath.row]
                return cell
            }
        }
        
        cell.note = notes[indexPath.row]
        return cell
    }

}



extension NotesViewController: UITableViewDelegate, UICollectionViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                addUpdateNote(note: pinnedNotes[indexPath.row])
                return
            }
        }
        
        addUpdateNote(note: notes[indexPath.row])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                addUpdateNote(note: pinnedNotes[indexPath.row])
                return
            }
        }
        
        addUpdateNote(note: notes[indexPath.row])
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in

            if !self.pinnedNotes.isEmpty {
                if indexPath.section == 0 {
                    self.manager.deleteNote(self.pinnedNotes[indexPath.row])
                    self.pinnedNotes.remove(at: indexPath.row)
                    self.notesTableView.deleteRows(at: [indexPath], with: .top)
                    self.totalNotes = self.notes.count
                    
                    if self.pinnedNotes.isEmpty {
//              solve this bug
                    }
                    return
                }
            }
            
            self.manager.deleteNote(self.notes[indexPath.row])
            self.notes.remove(at: indexPath.row)
            self.notesTableView.deleteRows(at: [indexPath], with: .top)
            self.totalNotes = self.notes.count
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (_, _, _) in
            if !self.pinnedNotes.isEmpty {
                if indexPath.section == 0 {
                    if let text = self.pinnedNotes[indexPath.row].text {
                        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                            tableView.setEditing(false, animated: true)
                        }
                        self.present(activityViewController, animated: true)
                    }
                    
                    return
                }
            }
            
            if let text = self.notes[indexPath.row].text {
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                    tableView.setEditing(false, animated: true)
                }
                self.present(activityViewController, animated: true)
            }
        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up.fill")
        shareAction.backgroundColor = UIColor(red: 77/255, green: 24/255, blue: 237/255, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var pinAction = UIContextualAction()
        
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                pinAction = UIContextualAction(style: .normal, title: "Unpin") { (_, _, _) in
                    self.pinnedNotes[indexPath.row].isPinned = false
                    self.notes.append(self.pinnedNotes[indexPath.row])
                    self.pinnedNotes.remove(at: indexPath.row)
                    self.sortNotes()
                    self.notesTableView.reloadData()
                }
                pinAction.image = UIImage(systemName: "pin.slash.fill")
                pinAction.backgroundColor = UIColor(red: 230/255, green: 157/255, blue: 11/255, alpha: 1)
                
                return UISwipeActionsConfiguration(actions: [pinAction])
            }
        }
        
        pinAction = UIContextualAction(style: .normal, title: "Pin") { (_, _, _) in
            self.notes[indexPath.row].isPinned = true
            self.pinnedNotes.append(self.notes[indexPath.row])
            self.notes.remove(at: indexPath.row)
            self.sortNotes()
            self.notesTableView.reloadData()
        }
        pinAction.image = UIImage(systemName: "pin.fill")
        pinAction.backgroundColor = UIColor(red: 230/255, green: 157/255, blue: 11/255, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [pinAction])
    }
    
    
    
  
          
}

