# 📝 MyNotes iOS Application  

An elegant iOS notes app that allows users to create, edit, organize, and manage notes with rich features like pinning, sorting, searching, and sharing along with dark mode support. Built with **UIKit**, **MVC architecture**, and **Core Data** for persistence.  

---

## 🚀 Features  

- **Note Creation & Editing**
  - Create new notes with a rich text editor.  
  - First line of each note is always bold.  
  - Undo & redo functionality while typing.  
  - "Last edited" date displayed above the editor.  

- **Toolbar**  
  - Toolbar shows **total number of notes** in real time.
  - A create note button which on pressing opens the text editor of a new note  

- **Search**
  - Integrated **UISearchController**.  
  - Live filtering of notes by title or text content.  

- **View Options**
  - Toggle between **List View (UITableView)** and **Grid View (UICollectionView)**.  
  - Both views use the same data source for consistency.
  - **List View** → Each row shows the **title of the note** and the **last edited date**.  
  - **Grid View** → Each cell shows the **title, last edited date, and a preview image of the note’s content**.    

- **Menu Options (UIMenu)**
  - **View Toggle** → List or Grid.  
  - **Select Notes** → Multi-select notes for deletion or delete all notes at once.
  - **Sort Notes** by Title, Date Created, or Date Edited.  

- **Gestures & Shortcuts**
  - **Long Press** → Preview note + menu with Share, Pin, Delete.  
  - **Swipe Gestures** → Pin, Share, or Delete directly from list view.
 
- **Features**
  - Share notes via **UIActivityViewController**.    
  - **Pin Notes** → Keep important notes at the top in a pinned section.  

- **Persistence & Settings**
  - Full **CRUD with Core Data** (Create, Read, Update, Delete).  
  - Notes store title, content, creation date, last edited date, and pin status.  
  - User preferences (sort method, view style) saved in **UserDefaults** and restored at launch.
  - User can continue editing existing note or create new one at any time with the same settings  

- **Keyboard Handling**
  - **NotificationCenter observers** adjust the view when the software keyboard toggles.  
  - Ensures smooth editing experience without UI overlap.  

---

## 🛠 Tech Stack  

- **Language:** Swift  
- **Framework:** UIKit  
- **Architecture:** MVC  
- **Database:** Core Data (CRUD for note persistence)  
- **Persistence:** UserDefaults (app settings)  
- **UI:** Auto Layout, UITableView, UICollectionView, UITextView, UISearchController, UILabel, UITextView, UIStackView, UIButton, UIBarButtonItem, UIImage 
- **Delegates Used:**  
  - `UITableViewDataSource`, `UITableViewDelegate`  
  - `UICollectionViewDataSource`, `UICollectionViewDelegate`  
  - `UITextViewDelegate`  
  - `UISearchResultsUpdating`  

---

## 📲 Installation & Setup  

1. Clone this repository:  
   ```bash
   git clone https://github.com/your-username/mynotes-ios-app.git
2. Open the project in Xcode.
3. Build & run the project on a simulator or physical device.

---

## 🎯 Usage

- Tap the ➕ button in the toolbar to create a new note.
- Type your note → the first line is bold automatically.
- Use Undo / Redo buttons to edit efficiently.
- Check last edited date displayed at the top of the editor.
- Switch between list view and grid view using the menu.
- Sort notes by title, creation date, or last edited date.
- Search notes using the search bar.
- Long press or swipe on a note to pin, share, or delete.
- Share notes using the system share sheet.
- All notes and settings persist across app launches.
- Dark Mode Support

---

## 📸 Screenshots

<p align="center"> <img src="screenshots/list.png" width="200"> <img src="screenshots/grid.png" width="200"> <img src="screenshots/editor.png" width="200"> </p>

---

## 🔮 Future Enhancements

- Add iCloud sync for notes backup across devices.
- Add note categories or tags for better organization.
- Support for rich text formatting (colors, lists, highlighting).
- Password/Face ID lock for private notes.

---

## 🤝 Contribution

Contributions are welcome! If you'd like to improve the app, please fork the repo and submit a pull request.

---

## 🙏 Acknowledgements

- UIKit + Core Data Framework
- Apple Documentation on UISearchController and UIMenu
- Made with ❤️ in Swift for iOS developers and note-takers everywhere.

