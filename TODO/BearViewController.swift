//
//  BearViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/21.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData

class BearViewController: UIViewController {
    
    var mainNavController: MainNavController?
    var menuNavController: MenuNavController?
    
    /// 单击手势
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    enum MenuState {
        // 未显示（收起）
        case Collapsed
        // 展开中
        case Expanding
        // 已展开
        case Expanded
    }

    /// 菜单打开后主页在屏幕右侧露出部分的宽度
    let menuNavViewExpandedOffset: CGFloat = 160
    var currentState = MenuState.Collapsed {
        didSet {
            /// 展开的时候，给主页添加阴影
            let shouldShowShadow = currentState != .Collapsed
            
            showShadowForMainViewController(shouldShowShadow: shouldShowShadow)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavController") as? MainNavController
        view.addSubview(mainNavController!.view)

        // 建立父子关系
        addChild(mainNavController!)
        mainNavController?.didMove(toParent: self)
        
        /// 添加拖动手势
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        mainNavController?.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // 拖动手势响应
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        guard let originX = recognizer.view?.frame.origin.x
            else {return}
        switch recognizer.state {
        // 刚刚开始滑动
        case .began:
            /// 判断拖动方向
            let dragFromeLeftToRight = recognizer.velocity(in: view).x > 0
            // 如果刚刚开始滑动的时候还处于主页面，从左向右滑动加入侧面菜单
            if currentState == .Collapsed && dragFromeLeftToRight {
                currentState = .Expanding
                // 加入侧面菜单方法
                addMenuViewController()
            }
        // 如果是正在滑动，则偏移主视图的坐标实现跟随手指位置移动
        case .changed:
            // 如果是在mainNav页面中滑动
            if recognizer.view == mainNavController?.view {
                let positionX = originX + recognizer.translation(in: view).x
                // 页面滑到最左侧的话就不许继续往左移动
                mainNavController?.view?.frame.origin.x = positionX < 0 ? 0 : positionX
                recognizer.setTranslation(.zero, in: view)
            }
            // 如果是在菜单栏中滑动
            else {
                let positionX = mainNavController?.view.frame.origin.x
                mainNavController?.view.frame.origin.x = positionX! + recognizer.translation(in: view).x
                recognizer.setTranslation(.zero, in: view)
            }

            
        case .ended:
            // 如果是在mainNav界面中滑动
            if recognizer.view == mainNavController?.view {
                // 根据页面滑动是否过半，判断后面是自动展开还是收缩
                let hasMovedhanHalfway = { () -> Bool in
                    if (recognizer.view?.center.x)! > self.view.bounds.size.width || recognizer.velocity(in: self.view).x > CGFloat(1000) {
                        return true
                    }
                    return false
                }
                // 自动展开方法
                animateMainView(shouldExpand: hasMovedhanHalfway())
            }
            // 如果是在菜单栏中滑动
            else{
                animateMainView(shouldExpand: recognizer.velocity(in: view).x > 0)
            }
        default:
            break
        }
    }
    
    // 单击手势响应
    @objc func handleTapGesture() {
        if currentState == .Expanded {
            animateMainView(shouldExpand: false)
        }
    }
    
    func addMenuViewController() {
        if menuNavController == nil {
            ///FIXME: 是否是指向同一个实例？？
            menuNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuNavController") as? MenuNavController
            // 插入当前视图并置顶
            view.insertSubview(menuNavController!.view, at: 0)
            
            // 建立父子关系
            addChild(menuNavController!)
            menuNavController!.didMove(toParent: self)
        }
    }
    
    // 主页自动展开、收起动画
    func animateMainView(shouldExpand: Bool) {
        // 如果是用来展开
        if shouldExpand {
            // 更新当前状态
            currentState = .Expanded
            // 动画
            //            animateMainViewXposition(targetPosition: mainNavController!.view.frame.width - menuNavViewExpandedOffset)
            
            animateMainViewXposition(targetPosition: mainNavController!.view.frame.width - menuNavViewExpandedOffset) { (isComplete) in
                /// 添加单击手势
                self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
                self.mainNavController?.view.addGestureRecognizer(self.tapGestureRecognizer!)
                // 设置主页面不可滚动
                (self.mainNavController?.children[0] as? CategoryTableViewController)?.tableView.isScrollEnabled = false
                
                /// 添加拖动手势
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
                self.menuNavController?.view.addGestureRecognizer(panGestureRecognizer)
            }
        }
        // 如果用于隐藏
        else {
            // 动画
            animateMainViewXposition(targetPosition: 0) { (isCompletion) in
                // 动画结束后，更新状态
                // 更新当前状态
                self.currentState = .Collapsed
                // 移除左侧菜单视图
                self.menuNavController?.view.removeFromSuperview()
                // 释放内存
                self.menuNavController = nil
                // 设置主页面可以交互
                (self.mainNavController?.children[0] as? CategoryTableViewController)?.tableView.isScrollEnabled = true
                // 移除单击手势
                if self.tapGestureRecognizer != nil {
                    self.mainNavController?.view.removeGestureRecognizer(self.tapGestureRecognizer!)
                }
            }
        }
    }
    
    // 主页移动动画
    func animateMainViewXposition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        // usingSpringWithDamping: 1.0 表示没有弹簧震动动画
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.mainNavController?.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    // 展开后添加阴影
    func showShadowForMainViewController(shouldShowShadow: Bool) {
        
        if shouldShowShadow {
            mainNavController?.view.layer.shadowOpacity = 2
        } else {
            mainNavController?.view.layer.shadowOpacity = 0.0
        }
    }
}
