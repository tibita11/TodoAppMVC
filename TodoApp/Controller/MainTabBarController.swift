//
//  MainTabBarController.swift
//  TodoApp
//
//  Created by 鈴木楓香 on 2023/01/30.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        guard let todoList = UIStoryboard(name: "TodoList", bundle: nil).instantiateViewController(withIdentifier: "todoList") as? TodoListViewController,
              let doneList = UIStoryboard(name: "TodoList", bundle: nil).instantiateViewController(withIdentifier: "todoList") as? TodoListViewController else {
            return
        }

        todoList.tabBarItem.title = "Todo"
        doneList.tabBarItem.title = "Done"
        doneList.tabBarItem.image = UIImage(systemName: "checkmark")
        
        let todoNaviVC = UINavigationController(rootViewController: todoList)
        let doneNaviVC = UINavigationController(rootViewController: doneList)
        viewControllers = [todoNaviVC, doneNaviVC]
    }

}
