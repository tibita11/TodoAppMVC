//
//  TodoListViewController.swift
//  TodoApp
//
//  Created by 鈴木楓香 on 2023/01/30.
//

import UIKit
import RealmSwift

protocol TodoListViewControllerDelegate: AnyObject {
    /// DBのisCheckを更新する
    /// - Parameter id: 更新対象
    /// - Parameter isCheck: 更新後の値
    func update(id: String, isCheck: Bool) throws
    /// DBから対象を削除する
    /// - Parameter object: 削除対象
    func delete(object: TodoObject) throws
    /// DBから複数の対象を削除する
    /// - Parameter objects: 削除対象配列
    func deleteAll(objects: Results<TodoObject>) throws
    /// DBからTodoListを取得する
    /// - Returns: List型, Optional
    func getTodoList() throws -> List<TodoObject>?
    /// 新規リストを作成する
    /// - Parameter list: DBに登録するList
    func createTodoList(list: TodoList) throws
    /// 既存リストにObjectを追加する
    /// - Parameter onject: 追加するObject
    func addToList(object: TodoObject) throws
    /// TodoListを並び替える
    /// - Parameter object: 更新対象
    /// - Parameter from: 削除位置
    /// - Parameter to: 挿入位置
    func sort(from: Int, to: Int) throws
    /// DBのtitleを更新する
    /// - Parameter id: 更新対象
    /// - Parameter title: 更新後の値
    func update(id: String, title: String) throws
  
}

class TodoListViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var todoListTableView: UITableView!
    
    var filterdList: Results<TodoObject>?
    let delegate: TodoListViewControllerDelegate = RealmOperation()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        todoListTableView.register(UINib(nibName: "TodoListTableViewCell", bundle: nil), forCellReuseIdentifier: "todoListCell")
        todoListTableView.keyboardDismissMode = .onDrag
        addButton.layer.cornerRadius = 25
        
        setup(tabBarItem.title)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todoListTableView.reloadData()
    }
    
    // MARK: - Action
    
    private func setup(_ tabBarTitle: String?) {
        switch tabBarTitle {
        case "Todo":
            navigationItem.title = "Lets' enjoy now !:)"
            navigationItem.rightBarButtonItem = editButtonItem
            addButton.addTarget(self, action: #selector(addNewObject), for: .touchUpInside)
            setupFilterdList(filter: false)
            
        case "Done":
            navigationItem.title = "Good job !:⊃"
            addButton.setTitle("全て削除", for: .normal)
            addButton.backgroundColor = UIColor.red
            addButton.addTarget(self, action: #selector(deletAllObject), for: .touchUpInside)
            setupFilterdList(filter: true)
        default: break
        }
    }
    
    /// isCheckからfilterdListを更新する
    /// - Parameter filter: true/false
    private func setupFilterdList(filter: Bool) {
        var result: List<TodoObject>?
        do {
            try result = delegate.getTodoList()
        } catch {
            print("TodoListの取得に失敗しました")
            print(error.localizedDescription)
        }
        guard let todoList = result else { return }
        filterdList = todoList.filter("isCheck = \(filter)")
    }
    
    @objc func addNewObject() {
        let newObject = TodoObject()
        do {
            let todoList = try delegate.getTodoList()
            if todoList == nil {
                let list = TodoList()
                list.todoList.append(newObject)
                try delegate.createTodoList(list: list)
            } else {
                try delegate.addToList(object: newObject)
            }
        } catch {
            print("登録ができませんでした。")
            print(error.localizedDescription)
        }
        // 最終行に追加
        guard let filterdList = filterdList else { return }
        // 動きをつけるため個別でinsert
        todoListTableView.beginUpdates()
        let indexPath = IndexPath(row: filterdList.count - 1, section: 0)
        todoListTableView.insertRows(at: [indexPath], with: .top)
        todoListTableView.endUpdates()
        // 最終行にスクロール
        DispatchQueue.main.async { [weak self] in
            let indexPath = IndexPath(row: filterdList.count - 1, section: 0)
            self!.todoListTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        
    }
    
    @objc func deletAllObject() {
        guard let filterdList = filterdList else { return }
        
        do {
            try delegate.deleteAll(objects: filterdList)
        } catch {
            print("全て削除に失敗しました")
            print(error.localizedDescription)
        }
        todoListTableView.reloadData()
    }
    
    // 編集モード
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        todoListTableView.setEditing(editing, animated: animated)
        todoListTableView.isEditing = editing
    }
    
    // 削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let filterdList = filterdList else { return }
            
            do {
                try delegate.delete(object: filterdList[indexPath.row])
            } catch {
                print("削除に失敗しました")
                print(error.localizedDescription)
            }
            todoListTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // 並び替え
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        do {
            try delegate.sort(from: fromIndexPath.row, to: to.row)
        } catch {
            print("並び替えに失敗しました")
            print(error.localizedDescription)
        }
        
    }
    // 並び替えを可能にする
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filterdList = filterdList else { return 0}
        return filterdList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todoListTableView.dequeueReusableCell(withIdentifier: "todoListCell", for: indexPath) as! TodoListTableViewCell
        guard let filterdList = filterdList else { return cell}
        
        cell.todoText.text = filterdList[indexPath.row].title
        cell.todoText.isEnabled = !filterdList[indexPath.row].isCheck
        cell.checkButton.isHidden = !filterdList[indexPath.row].isCheck
        cell.id = filterdList[indexPath.row].id
        cell.delegate = self
        if indexPath.row == filterdList.count - 1, cell.todoText.text == "" {
            // 最終行かつ、中身が空欄の場合はフォーカスを当てる
            cell.todoText.becomeFirstResponder()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}


// MARK: - TodoListCellDelegate

extension TodoListViewController: TodoListCellDelegate {
    func addObject() {
        addButton.sendActions(for: .touchUpInside)
    }
    
    func update(id: String, isCheck: Bool) {
        do {
            try delegate.update(id: id, isCheck: isCheck)
        } catch {
            print("チェックの更新に失敗しました")
            print(error.localizedDescription)
        }
        todoListTableView.reloadData()
    }
    
    func update(id: String, title: String) {
        do {
            try delegate.update(id: id, title: title)
        } catch {
            print("titleの更新に失敗しました")
            print(error.localizedDescription)
        }
    }
    
    func delete(id: String) {
        guard let filterdList = filterdList else {
            return
        }
        for num in 0..<filterdList.count {
            if filterdList[num].id == id {
                do {
                    try delegate.delete(object: filterdList[num])
                } catch {
                    print("削除に失敗しました")
                    print(error.localizedDescription)
                }
                // 動きをつけるため個別でdelete
                let indexPath = IndexPath(row: num, section: 0)
                todoListTableView.beginUpdates()
                todoListTableView.deleteRows(at: [indexPath], with: .top)
                todoListTableView.endUpdates()
                break
            }
        }
    }
    

}
