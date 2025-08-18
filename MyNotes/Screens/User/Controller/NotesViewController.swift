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
            }else if totalNotes == 1 {
                totalLabel.text = "1 Note"
            } else {
                totalLabel.text = "\(totalNotes) Notes"
            }
        }
    }
    
    let userDefaults = UserDefaults.standard
    
    var inSelectMode = false
    
    var deleteButton = UIBarButtonItem()
    
    var selectedPinnedNotes = Set<Int>() {
        didSet {
            if selectedPinnedNotes.isEmpty && selectedNotes.isEmpty {
                deleteButton.title = "Delete All"
            } else {
                deleteButton.title = "Delete"
            }
        }
    }
    var selectedNotes = Set<Int>() {
        didSet {
            if selectedPinnedNotes.isEmpty && selectedNotes.isEmpty {
                deleteButton.title = "Delete All"
            } else {
                deleteButton.title = "Delete"
            }
        }
    }
    
    
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
        
        notesTableView.allowsMultipleSelection = true
        notesCollectionView.allowsMultipleSelection = true
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
                    totalNotes = notes.count + pinnedNotes.count
                    if userDefaults.bool(forKey: "isGalleryView") {
                        if pinnedNotes.isEmpty {
                            notesCollectionView.reloadData()
                            return
                        }
                        notesCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                    } else {
                        if pinnedNotes.isEmpty {
                            notesTableView.reloadData()
                            return
                        }
                        notesTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
                    totalNotes = notes.count + pinnedNotes.count
                    if userDefaults.bool(forKey: "isGalleryView") {
                        if notes.isEmpty {
                            notesCollectionView.reloadData()
                            return
                        }
                        notesCollectionView.deleteItems(at: [IndexPath(row: index, section: pinnedNotes.isEmpty ? 0 : 1)])
                    } else {
                        if notes.isEmpty {
                            notesTableView.reloadData()
                            return
                        }
                        notesTableView.deleteRows(at: [IndexPath(row: index, section: pinnedNotes.isEmpty ? 0 : 1)], with: .automatic)
                    }
                    return
                }
            }
        }
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        deleteButton = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteTapped))
        deleteButton.tintColor = .red
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, deleteButton]
        
        inSelectMode = true
        
        if userDefaults.bool(forKey: "isGalleryView") {
            notesCollectionView.reloadData()
        } else {
            notesTableView.reloadData()
        }
    }
    
    
    func setupToolbar() {
        totalNotes = notes.count + pinnedNotes.count
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
    
    
    @objc func doneTapped() {
        inSelectMode = false
        setupDataAndMoreOptionButton()
        setupToolbar()
        selectedNotes.removeAll()
        selectedPinnedNotes.removeAll()
    }
    
    
    @objc func deleteTapped() {
        if selectedNotes.isEmpty && selectedPinnedNotes.isEmpty {
            for note in notes {
                manager.deleteNote(note)
            }
            for note in pinnedNotes {
                manager.deleteNote(note)
            }
            notes.removeAll()
            pinnedNotes.removeAll()
        } else {
            for index in selectedNotes {
                manager.deleteNote(notes[index])
                notes.remove(at: index)
            }
            for index in selectedPinnedNotes {
                manager.deleteNote(pinnedNotes[index])
                pinnedNotes.remove(at: index)
            }
        }
        
        inSelectMode = false
        setupDataAndMoreOptionButton()
        setupToolbar()
        selectedNotes.removeAll()
        selectedPinnedNotes.removeAll()
    }
    
}



extension NotesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
}



extension NotesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if notes.isEmpty && pinnedNotes.isEmpty {
            return 0
        }
        
        return (pinnedNotes.isEmpty || notes.isEmpty ? 1 : 2)
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                cell.inSelectionMode = inSelectMode
                return cell
            }
        }
        
        cell.note = notes[indexPath.row]
        cell.inSelectionMode = inSelectMode
        return cell
    }

}


extension NotesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if notes.isEmpty && pinnedNotes.isEmpty {
            return 0
        }
        
        return (pinnedNotes.isEmpty || notes.isEmpty ? 1 : 2)
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !pinnedNotes.isEmpty {
            if section == 0 {
                return pinnedNotes.count
            }
        }
        
        return notes.count
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



extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if inSelectMode {
            if !pinnedNotes.isEmpty {
                if indexPath.section == 0 {
                    selectedPinnedNotes.insert(indexPath.row)
                    return
                }
            }
            
            selectedNotes.insert(indexPath.row)
        } else {
            if !pinnedNotes.isEmpty {
                if indexPath.section == 0 {
                    addUpdateNote(note: pinnedNotes[indexPath.row])
                    return
                }
            }
            
            addUpdateNote(note: notes[indexPath.row])
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if inSelectMode {
            if !pinnedNotes.isEmpty {
                if indexPath.section == 0 {
                    selectedPinnedNotes.remove(indexPath.row)
                    return
                }
            }
            
            selectedNotes.remove(indexPath.row)
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            self.deleteNote(indexPath: indexPath)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (_, _, _) in
            let activityViewController = self.shareNote(indexPath: indexPath)
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                tableView.setEditing(false, animated: true)
            }
            self.present(activityViewController, animated: true)
        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up.fill")
        shareAction.backgroundColor = UIColor(red: 77/255, green: 24/255, blue: 237/255, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                let unpinAction = UIContextualAction(style: .normal, title: "Unpin") { (_, _, _) in
                    self.unpinNote(indexPath: indexPath)
                }
                unpinAction.image = UIImage(systemName: "pin.slash.fill")
                unpinAction.backgroundColor = UIColor(red: 230/255, green: 157/255, blue: 11/255, alpha: 1)
                
                return UISwipeActionsConfiguration(actions: [unpinAction])
            }
        }
        
        let pinAction = UIContextualAction(style: .normal, title: "Pin") { (_, _, _) in
            self.pinNote(indexPath: indexPath)
        }
        pinAction.image = UIImage(systemName: "pin.fill")
        pinAction.backgroundColor = UIColor(red: 230/255, green: 157/255, blue: 11/255, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [pinAction])
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let previewVC = NotePreviewViewController()
            if !self.pinnedNotes.isEmpty {
                if indexPath.section == 0 {
                    previewVC.noteText = self.pinnedNotes[indexPath.row].text
                    return previewVC
                }
            }
            previewVC.noteText = self.notes[indexPath.row].text
            return previewVC
        }, actionProvider: { _ in
            let pinAction = UIAction(title: "Pin", image: UIImage(systemName: "pin")) { _ in
                self.pinNote(indexPath: indexPath)
            }
            let unpinAction = UIAction(title: "Unpin", image: UIImage(systemName: "pin.slash")) { _ in
                self.unpinNote(indexPath: indexPath)
            }
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityViewController = self.shareNote(indexPath: indexPath)
                self.present(activityViewController, animated: true)
            }
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteNote(indexPath: indexPath)
            }
            
            if !self.pinnedNotes.isEmpty {
                if indexPath.section == 0 {
                    return UIMenu(title: "", children: [unpinAction, shareAction, deleteAction])
                }
            }
            return UIMenu(title: "", children: [pinAction, shareAction, deleteAction])
        })
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let indexPath = configuration.identifier as? IndexPath {
                if !self.pinnedNotes.isEmpty {
                    if indexPath.section == 0 {
                        self.addUpdateNote(note: self.pinnedNotes[indexPath.row])
                        return
                    }
                }
                
                self.addUpdateNote(note: self.notes[indexPath.row])
            }
        }
    }
    
    
    func shareNote(indexPath: IndexPath) -> UIActivityViewController {
        if !self.pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                if let text = self.pinnedNotes[indexPath.row].text {
                    let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    return activityViewController
                }
            }
        }
        
        if let text = self.notes[indexPath.row].text {
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            return activityViewController
        }
        
        return UIActivityViewController(activityItems: [], applicationActivities: nil)
    }
    
    
    func deleteNote(indexPath: IndexPath) {
        if !self.pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                self.manager.deleteNote(self.pinnedNotes[indexPath.row])
                self.pinnedNotes.remove(at: indexPath.row)
                self.totalNotes = self.notes.count + self.pinnedNotes.count
                if self.pinnedNotes.isEmpty {
                    self.notesTableView.reloadData()
                    return
                }
                self.notesTableView.deleteRows(at: [indexPath], with: .automatic)
                return
            }
        }
        
        self.manager.deleteNote(self.notes[indexPath.row])
        self.notes.remove(at: indexPath.row)
        self.totalNotes = self.notes.count + self.pinnedNotes.count
        if self.notes.isEmpty {
            self.notesTableView.reloadData()
            return
        }
        self.notesTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    func pinNote(indexPath: IndexPath) {
        self.notes[indexPath.row].isPinned = true
        self.manager.saveContext()
        
        self.pinnedNotes.append(self.notes[indexPath.row])
        self.notes.remove(at: indexPath.row)
        self.sortNotes()
        self.notesTableView.reloadData()
    }
    
    
    func unpinNote(indexPath: IndexPath) {
        self.pinnedNotes[indexPath.row].isPinned = false
        self.manager.saveContext()
        self.notes.append(self.pinnedNotes[indexPath.row])
        self.pinnedNotes.remove(at: indexPath.row)
        self.sortNotes()
        self.notesTableView.reloadData()
    }
  
}



extension NotesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !pinnedNotes.isEmpty {
            if indexPath.section == 0 {
                addUpdateNote(note: pinnedNotes[indexPath.row])
                return
            }
        }
        
        addUpdateNote(note: notes[indexPath.row])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPaths[0] as NSIndexPath, previewProvider: {
            let previewVC = NotePreviewViewController()
            if !self.pinnedNotes.isEmpty {
                if indexPaths[0].section == 0 {
                    previewVC.noteText = self.pinnedNotes[indexPaths[0].row].text
                    return previewVC
                }
            }
            previewVC.noteText = self.notes[indexPaths[0].row].text
            return previewVC
        }, actionProvider: { _ in
            let pinAction = UIAction(title: "Pin", image: UIImage(systemName: "pin")) { _ in
                self.notes[indexPaths[0].row].isPinned = true
                self.manager.saveContext()
                
                self.pinnedNotes.append(self.notes[indexPaths[0].row])
                self.notes.remove(at: indexPaths[0].row)
                self.sortNotes()
                self.notesCollectionView.reloadData()
            }
            let unpinAction = UIAction(title: "Unpin", image: UIImage(systemName: "pin.slash")) { _ in
                self.pinnedNotes[indexPaths[0].row].isPinned = false
                self.manager.saveContext()
                self.notes.append(self.pinnedNotes[indexPaths[0].row])
                self.pinnedNotes.remove(at: indexPaths[0].row)
                self.sortNotes()
                self.notesCollectionView.reloadData()
            }
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityViewController = self.shareNote(indexPath: indexPaths[0])
                self.present(activityViewController, animated: true)
            }
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                if !self.pinnedNotes.isEmpty {
                    if indexPaths[0].section == 0 {
                        self.manager.deleteNote(self.pinnedNotes[indexPaths[0].row])
                        self.pinnedNotes.remove(at: indexPaths[0].row)
                        self.totalNotes = self.notes.count + self.pinnedNotes.count
                        if self.pinnedNotes.isEmpty {
                            self.notesCollectionView.reloadData()
                            return
                        }
                        self.notesCollectionView.deleteItems(at: [indexPaths[0]])
                        return
                    }
                }
                
                self.manager.deleteNote(self.notes[indexPaths[0].row])
                self.notes.remove(at: indexPaths[0].row)
                self.totalNotes = self.notes.count + self.pinnedNotes.count
                if self.notes.isEmpty {
                    self.notesCollectionView.reloadData()
                    return
                }
                self.notesCollectionView.deleteItems(at: [indexPaths[0]])
            }
            
            if !self.pinnedNotes.isEmpty {
                if indexPaths[0].section == 0 {
                    return UIMenu(title: "", children: [unpinAction, shareAction, deleteAction])
                }
            }
            return UIMenu(title: "", children: [pinAction, shareAction, deleteAction])
        })
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let indexPath = configuration.identifier as? IndexPath {
                if !self.pinnedNotes.isEmpty {
                    if indexPath.section == 0 {
                        self.addUpdateNote(note: self.pinnedNotes[indexPath.row])
                        return
                    }
                }
                
                self.addUpdateNote(note: self.notes[indexPath.row])
            }
        }
    }
    
}


extension NotesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            
            notes = manager.fetchNotes()
            sortOutPinnedNotes()
            sortNotes()
            
            if !searchText.isEmpty {
                notes.removeAll { note in
                    if let text = note.text {
                        return !text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).contains(searchText)
                    } else {
                        return false
                    }
                }
                pinnedNotes.removeAll { note in
                    if let text = note.text {
                        return !text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).contains(searchText)
                    } else {
                        return false
                    }
                }
            }
            
            if userDefaults.bool(forKey: "isGalleryView") {
                notesCollectionView.reloadData()
            } else {
                notesTableView.reloadData()
            }
        }
    }
}
