//
//  RealmOperation.swift
//  TodoApp
//
//  Created by 鈴木楓香 on 2023/01/30.
//

import Foundation
import RealmSwift

class RealmOperation: TodoListViewControllerDelegate {

    
    func update(id: String, isCheck: Bool) throws {
        let realm = try Realm()
        guard let targetObject = realm.objects(TodoObject.self).filter("id == %@",id).first,
              var todoList = realm.objects(TodoList.self).first?.todoList else { return }
        try realm.write {
            targetObject.isCheck = isCheck
            todoList.sort { !$0.isCheck && $1.isCheck}
        }
    }
    
    func delete(object: TodoObject) throws {
        let realm = try Realm()
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll(objects: Results<TodoObject>) throws {
        let realm = try Realm()
        try realm.write {
            objects.forEach {
                realm.delete($0)
            }
        }
    }
    
    func getTodoList() throws -> List<TodoObject>? {
        let realm = try Realm()
        let todoList = realm.objects(TodoList.self).first?.todoList
        return todoList
    }
     
    func createTodoList(list: TodoList) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(list)
        }
    }
    
    func addToList(object: TodoObject) throws {
        let realm = try Realm()
        var todoList = realm.objects(TodoList.self).first?.todoList
        try realm.write {
            todoList?.append(object)
            todoList?.sort { !$0.isCheck && $1.isCheck}
        }
    }
    
    func sort(from: Int, to: Int) throws {
        let realm = try Realm()
        let todoList = realm.objects(TodoList.self).first?.todoList
        let object = todoList![from]
        try realm.write {
            todoList?.remove(at: from)
            todoList?.insert(object, at: to)
        }
    }
    
    func update(id: String, title: String) throws {
        let realm = try Realm()
        guard let targetObject = realm.objects(TodoObject.self).filter("id == %@",id).first else { return }
        try realm.write {
            targetObject.title = title
        }
    }
    
}

