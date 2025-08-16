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
            if totalNotes == 0 {
                totalLabel.text = "No Notes"
            }
            if totalNotes == 1 {
                totalLabel.text = "1 Note"
            } else {
                totalLabel.text = "\(totalNotes) Notes"
            }
        }
    }
    
    let userDefaults = UserDefaults.standard
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        notes = manager.fetchNotes()
        
        sortOutPinnedNotes()
        
        sortNotes()
        
        setupDataAndMoreOptionButton()
        
        totalNotes = notes.count + pinnedNotes.count
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConfiguration()
        
        notesTableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
        notesCollectionView.register(UINib(nibName: "NoteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoteCollectionViewCell")
        notesCollectionView.register(CollectionSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionSectionHeaderView.reuseIdentifier)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        for (index,note) in pinnedNotes.enumerated() {
            if let text = note.text {
                if text.isEmpty{
                    manager.deleteNote(note)
                    pinnedNotes.remove(at: index)
                    if userDefaults.bool(forKey: "isGalleryView") {
                        notesCollectionView.reloadData()
                    } else {
                        notesTableView.reloadData()
                    }
                    return
                }
            }
        }
        
        for (index,note) in notes.enumerated() {
            if let text = note.text {
                if text.isEmpty{
                    manager.deleteNote(note)
                    notes.remove(at: index)
                    if userDefaults.bool(forKey: "isGalleryView") {
                        notesCollectionView.reloadData()
                    } else {
                        notesTableView.reloadData()
                    }
                    return
                }
            }
        }
        
        totalNotes = notes.count + pinnedNotes.count
    }
    
    
    func sortOutPinnedNotes() {
        pinnedNotes = notes.filter { $0.isPinned }
        notes.removeAll { $0.isPinned }
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
        title = "MyNotes"
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
}



extension NotesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
}



extension NotesViewController: UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if notes.isEmpty && pinnedNotes.isEmpty {
            return 0
        }
        
        return (pinnedNotes.isEmpty || notes.isEmpty ? 1 : 2)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if notes.isEmpty && pinnedNotes.isEmpty {
            return 0
        }
        
        return (pinnedNotes.isEmpty || notes.isEmpty ? 1 : 2)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textAlignment = .left
        if !pinnedNotes.isEmpty {
            if section == 0 {
                titleLabel.text = "Pinned"
            } else {
                titleLabel.text = "Notes"
            }
        } else {
            titleLabel.text = "Notes"
        }
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionSectionHeaderView.reuseIdentifier, for: indexPath) as? CollectionSectionHeaderView {
                if !pinnedNotes.isEmpty {
                    if indexPath.section == 0 {
                        header.titleLabel.text = "Pinned"
                        return header
                    }
                }
                header.titleLabel.text = "Notes"
                return header
            }
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
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
                    self.notesTableView.reloadData()
                    self.totalNotes = self.notes.count + self.pinnedNotes.count
                    return
                }
            }
            
            self.manager.deleteNote(self.notes[indexPath.row])
            self.notes.remove(at: indexPath.row)
            self.notesTableView.reloadData()
            self.totalNotes = self.notes.count + self.pinnedNotes.count
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
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                let unpinAction = UIContextualAction(style: .normal, title: "Unpin") { (_, _, _) in
                    self.pinnedNotes[indexPath.row].isPinned = false
                    self.manager.saveContext()
                    self.notes.append(self.pinnedNotes[indexPath.row])
                    self.pinnedNotes.remove(at: indexPath.row)
                    self.sortNotes()
                    self.notesTableView.reloadData()
                }
                unpinAction.image = UIImage(systemName: "pin.slash.fill")
                unpinAction.backgroundColor = UIColor(red: 230/255, green: 157/255, blue: 11/255, alpha: 1)
                
                return UISwipeActionsConfiguration(actions: [unpinAction])
            }
        }
        
        let pinAction = UIContextualAction(style: .normal, title: "Pin") { (_, _, _) in
            self.notes[indexPath.row].isPinned = true
            self.manager.saveContext()
            
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

