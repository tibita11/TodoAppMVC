//
//  TodoListTableViewCell.swift
//  TodoApp
//
//  Created by 鈴木楓香 on 2023/01/30.
//

import UIKit

protocol TodoListCellDelegate: AnyObject {
    func addObject()
    /// 対象のisCheckを更新する
    /// - Parameter id: 更新対象
    /// - Parameter isCheck: 更新後の値
    func update(id: String, isCheck: Bool)
    /// 対象のtitleを更新する
    /// - Parameter id: 更新対象
    /// - Parameter title: 更新後の値
    func update(id: String, title: String)
    /// 対象を削除する
    /// - Parameter id: 削除対象
    func delete(id: String)
}

class TodoListTableViewCell: UITableViewCell {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var todoText: UITextField!
    private var toolBar: UIToolbar {
        get {
            let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 45.0)))
            let doneItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(closeKeyboard))
            let addItem = UIBarButtonItem(title: "追加", style: .plain, target: self, action: #selector(addObject))
            let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            toolBar.setItems([flexibleItem, addItem, doneItem], animated: true)
            toolBar.sizeToFit()
            return toolBar
        }
    }
    weak var delegate: TodoListCellDelegate!
    /// DB検索用ID
    var id: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        todoText.borderStyle = .none
        todoText.inputAccessoryView = toolBar
        todoText.returnKeyType = .done
        todoText.delegate = self
        todoText.addTarget(self, action: #selector(updateTitle), for: .editingChanged)
    }
    @IBAction func uncheck(_ sender: Any) {
        checkButton.isHidden = true
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()
        
        // 0.1秒遅らせる
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let delegate = self!.delegate else { return }
            delegate.update(id: self!.id, isCheck: false)
        }
    }
    
    @IBAction func check(_ sender: Any) {
        checkButton.isHidden = false
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()
        
        // 0.1秒遅らせる
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let delegate = self!.delegate else { return }
            delegate.update(id: self!.id, isCheck: true)
        }
    }
    
    @objc private func closeKeyboard() {
        todoText.resignFirstResponder()
    }
    
    @objc private func addObject() {
        guard todoText.text != "" else {
            // 空欄の場合は何もしない
            return
        }
        delegate.addObject()
        todoText.resignFirstResponder()
    }
    
    @objc private func updateTitle(_ sender: UITextField) {
        delegate.update(id: id, title: sender.text ?? "")
    }
    
}

extension TodoListTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text == "" else {
            return
        }
        // 空欄の場合に、行を削除する
        delegate.delete(id: id)
    }
    
}

