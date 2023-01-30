//
//  TodoObject.swift
//  TodoApp
//
//  Created by 鈴木楓香 on 2023/01/30.
//

import Foundation
import RealmSwift

class TodoObject: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var isCheck: Bool = false
    
    override class func primaryKey() -> String? {
            return "id"
        }
}

class TodoList: Object {
    @Persisted var todoList = List<TodoObject>()
}
