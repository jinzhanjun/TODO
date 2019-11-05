//
//  BearViewController.swift
//  TODO
//
//  Created by 金占军 on 2019/10/21.
//  Copyright © 2019 金占军. All rights reserved.
//

import UIKit
import CoreData

class BearViewController: UIViewController, UINavigationControllerDelegate {
    
    var mainNavController: MainNavController?
    var menuNavController: MenuNavController?
    
    /// 单击手势
    var tapGestureRecognizer: UITapGestureRecognizer?
    /// 滑动手势
    var panGestureRecognizer: UIPanGestureRecognizer?
    
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
        
        // 设置代理
        mainNavController?.delegate = self

        /// 添加拖动手势
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        mainNavController?.view.addGestureRecognizer(panGestureRecognizer!)
        
        /// 设置点击手势
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
    }
    
    // 拖动手势响应
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        /// 定义是否是在main界面滑动
        let isOnMain = recognizer.view == mainNavController?.view
        guard let originX = isOnMain ? recognizer.view?.frame.origin.x : mainNavController?.view.frame.origin.x
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
            let positionX = originX + recognizer.translation(in: view).x
            // 页面滑到最左侧的话就不许继续往左移动
            mainNavController?.view?.frame.origin.x = positionX < 0 ? 0 : positionX
            recognizer.setTranslation(.zero, in: view)
        case .ended:
            // 根据页面滑动是否过半，判断后面是自动展开还是收缩(闭包-注意循环引用，需要使用weak self)
            let hasMovedhanHalfway = { [weak self] () -> Bool in
                guard isOnMain else {return recognizer.velocity(in: self?.view).x > 0}
                if (recognizer.view?.center.x)! > self?.view.bounds.size.width ?? 375 || recognizer.velocity(in: self?.view).x > CGFloat(1000) {
                    return true
                }
                return false
            }
            // 自动展开方法
            animateMainView(shouldExpand: hasMovedhanHalfway())
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
            // 动画
            animateMainViewXposition(targetPosition: mainNavController!.view.frame.width - menuNavViewExpandedOffset) { [weak self] isComplete in
                if isComplete {
                    // 当前状态如果是未展开状态，则添加手势，否则不添加手势
                    if self?.currentState != .Expanded {
                        /// 添加单击手势
                        guard let tapGestureRecognizer = self?.tapGestureRecognizer else {return}
                        self?.mainNavController?.view.addGestureRecognizer(tapGestureRecognizer)
                        // 禁止mainNavController的表格用户交互
                        (self?.mainNavController?.children.first as? CategoryTableViewController)?.tableView.isUserInteractionEnabled = false
                        /// 菜单栏添加拖动手势
                        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self?.handlePanGesture(_:)))
                        self?.menuNavController?.view.addGestureRecognizer(panGestureRecognizer)
                    }
                    self?.currentState = .Expanded
                }
            }
        }
        // 如果用于隐藏
        else {
            // 动画
            animateMainViewXposition(targetPosition: 0) { [weak self] (isCompletion) in
                if isCompletion {
                    // 动画结束后，更新状态
                    // 更新当前状态
                    self?.currentState = .Collapsed
                    // 移除左侧菜单视图
                    self?.menuNavController?.view.removeFromSuperview()
                    // 释放内存
                    self?.menuNavController = nil
                    // 开启mainNavController的表格用户交互
                    (self?.mainNavController?.children.first as? CategoryTableViewController)?.tableView.isUserInteractionEnabled = true
                    // 移除单击手势
                    guard let tapGestureRecognizer = self?.tapGestureRecognizer else {return}
                    self?.mainNavController?.view.removeGestureRecognizer(tapGestureRecognizer)
                }
            }
        }
    }
    
    // 主页移动动画
    func animateMainViewXposition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        // usingSpringWithDamping: 1.0 表示没有弹簧震动动画
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .allowAnimatedContent,
                       animations: { [weak self] in
                        self?.mainNavController?.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    // 展开后添加阴影
    func showShadowForMainViewController(shouldShowShadow: Bool) {
        
        if shouldShowShadow {
//            mainNavController?.view.backgroundColor = UIColor.white
            mainNavController?.view.layer.shadowOpacity = 0.8
            mainNavController?.view.layer.shadowColor = UIColor.darkGray.cgColor
            mainNavController?.view.layer.shadowRadius = 0.6
            mainNavController?.view.layer.shadowOffset = CGSize(width: -10, height: 10)
        } else {
            mainNavController?.view.layer.shadowOpacity = 0.0
        }
    }
    
    // 移除、添加手势
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let _ = viewController as? CategoryTableViewController {
            mainNavController?.view.addGestureRecognizer(panGestureRecognizer!)
            print("添加移动手势")
        } else {
            mainNavController?.view.removeGestureRecognizer(panGestureRecognizer!)
            print("移除移动手势")
        }
    }
}
