//
//  GameScene.swift
//  Nintendo_Laser
//
//  Created by mac on 2018/10/13.
//  Copyright © 2018年 ruiju.com. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var bezierPath:UIBezierPath!
    let eachTime: CGFloat = 0.03
    var targetNode: SKShapeNode?
    var targetLines: [CGPoint] = []
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint.zero
        // Get label node from scene and store it for use later
        
    }
    
    func laser(at startPos:CGPoint, count:Int) -> SKShapeNode{
        
        bezierPath = UIBezierPath.init()
        bezierPath.move(to: CGPoint.zero)
        let linePoints = shootLaser(with: CGFloat(Double.pi) * 0.2, pos: startPos, maxReflect: count)
        
        let shapeNode = SKShapeNode.init()
        shapeNode.position = startPos
        shapeNode.lineWidth = 4
        let shader = SKShader.init(fileNamed: "rayBullet.fsh")
        shapeNode.strokeShader = shader
        
        let timeForAnimation = 0.05 * CGFloat(linePoints.count)
        addChild(shapeNode)
        
        let lastIdx = -1
        run(SKAction.customAction(withDuration: TimeInterval(timeForAnimation), actionBlock: { (node, time) in
            let idx = Int(time / self.eachTime)
            if idx != lastIdx {
                if idx < linePoints.count {
                    let nextPos = linePoints[idx]
                    let toPos = CGPoint(x: nextPos.x - startPos.x, y: nextPos.y - startPos.y)
                    //For reverse
                    self.targetLines.append(toPos)
                    
                    self.bezierPath.addLine(to: toPos)
                    self.bezierPath.addArc(withCenter: toPos, radius: 10, startAngle: 0 , endAngle: CGFloat.pi * 1.99 , clockwise: true)
                    self.bezierPath.move(to: toPos)
                    shapeNode.path = self.bezierPath.cgPath
                }
            }
        })){
            
            let persentUniform = SKUniform(name: "u_current_percentage", float: 0.0)
            let path = Bundle.main.path(forResource: "rayDismiss", ofType: "fsh")
            let source = try! NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            let disShader = SKShader.init(source: source as String, uniforms: [persentUniform])
//            disShader.attributes = [
//                SKAttribute(name: "u_current_percentage", type: .float)
//            ]
            shapeNode.strokeShader = disShader
            
            let timeForAnimation = 0.05 * CGFloat(linePoints.count)

            shapeNode.setValue(SKAttributeValue(float: 0), forAttribute: "u_current_percentage")

//            disShader.uniforms = [
//                SKUniform(name: "t_pass", float:0),
//                SKUniform(name: "t_all", float: Float(timeForAnimation))
//            ]

            shapeNode.run(SKAction.customAction(withDuration: TimeInterval(0.05 * CGFloat(linePoints.count)), actionBlock: { (node, time) in
//                    disShader.uniforms = [
//                        SKUniform(name: "t_pass", float: Float(time)),
//                        SKUniform(name: "t_all", float: Float(timeForAnimation))
//                    ]
                persentUniform.floatValue = Float(time/timeForAnimation)
//                shapeNode.setValue(SKAttributeValue(float: Float(time/timeForAnimation)), forAttribute: "u_current_percentage")

            }))
        }
        
        return shapeNode
    }
    
    func reverseLaser(node: SKShapeNode) {

        node.path = nil
        
        let lastIdx = -1
        run(SKAction.customAction(withDuration: TimeInterval(0.05 * CGFloat(targetLines.count)), actionBlock: { (runNode, time) in
            let idx = Int(time / self.eachTime)
            if idx != lastIdx {
                if idx < self.targetLines.count {
                        let bezier = UIBezierPath.init()
                        bezier.move(to: .zero)
                    let maxLen = self.targetLines.count - idx
                    if maxLen > 2 {
                        for i in 0..<maxLen {
                            let nextPos = self.targetLines[i]
                            bezier.addLine(to: nextPos)
                            bezier.addArc(withCenter: nextPos, radius: 10, startAngle: 0 , endAngle: CGFloat.pi * 1.99 , clockwise: true)
                            bezier.move(to: nextPos)
                        }
                        node.path = bezier.cgPath
                    }else {
                        node.path = nil
                    }
                }
            }
        })){
            self.targetLines.removeAll()
            node.removeFromParent()
        }
        
    }
    
    func shootLaser(with angle:CGFloat, pos:CGPoint, maxReflect:Int = 24, minAngle:CGFloat = CGFloat(Double.pi) / 128.0) ->[CGPoint] {
        if abs(angle) < minAngle || maxReflect < 1 {
            //wait 2 sec, then reverse laser
            return [pos]
        }else{

            let p00 = CGPoint.zero
            let p01 = CGPoint(x: 0, y: size.height)
            let p11 = CGPoint(x: size.width, y: size.height)
            let p10 = CGPoint(x: size.width, y: 0)
            
            var aQdt:CGFloat = 0
            var bQdt:CGFloat = 0
            var cQdt:CGFloat = 0
            var dQdt: CGFloat = 0
            
            let a = (p11.y - pos.y)/(p11.x - pos.x)
            let b = (p01.y - pos.y)/(p01.x - pos.x)
            let c = (p00.y - pos.y)/(p00.x - pos.x)
            let d = (p10.y - pos.y)/(p10.x - pos.x)
            
            if pos.x == p11.x {
                //如果在右边界
                aQdt = CGFloat.pi / 2.0
                bQdt = CGFloat.pi + atan(b)
                cQdt = CGFloat.pi + atan(c)
                dQdt = CGFloat.pi * 2.0
            }else if p01.y == pos.y {
                //如果在上边界
                aQdt = 0
                bQdt = CGFloat.pi
                cQdt = CGFloat.pi + atan(c)
                dQdt = atan(d) + CGFloat.pi * 2.0
            }else if pos.x == 0 {
                //如果在Y轴
                aQdt = atan(a)
                bQdt = CGFloat.pi / 2.0
                cQdt = CGFloat.pi * 3.0 / 2.0
                dQdt = atan(d) + CGFloat.pi * 2.0
            }else if pos.y == 0 {
                //如果在x轴
                aQdt = atan(a)
                bQdt = atan(b) + CGFloat.pi
                cQdt = CGFloat.pi
                dQdt = CGFloat.pi * 2.0
            }else {
                //在内部
                aQdt = atan(a)
                bQdt = atan(b) + CGFloat.pi
                cQdt = atan(-c) + CGFloat.pi * 2.0
                dQdt = atan(-d) + CGFloat.pi * 2.0
            }
            
            var nextPos = CGPoint.zero
            var nextAngle: CGFloat = 0.0
            
            if angle < aQdt {
                //与右边界相交
                nextPos = CGPoint(x: size.width, y: pos.y - tan(angle) * (pos.x - size.width))
                nextAngle = CGFloat.pi - angle
            }else if angle < bQdt {
                //与上边界相交s
                nextPos = CGPoint(x: pos.x - (pos.y - size.height)/tan(angle), y: size.height)
                nextAngle = 2.0 * CGFloat(Double.pi) - angle
            }else if angle < cQdt {
                //与左边界相交, y轴
                nextPos = CGPoint(x: 0, y: pos.y - tan(angle) * pos.x)
                nextAngle = 3 * CGFloat(Double.pi) - angle
            }else if angle < dQdt{
                //与下边界相交，x轴
                nextPos = CGPoint(x: pos.x - pos.y / tan(angle), y: 0)
                nextAngle = 2 * CGFloat(Double.pi) - angle
            }else {
                //xx
                nextPos = CGPoint(x: size.width, y: pos.y - tan(angle) * (pos.x - size.width))
                nextAngle = 3 * CGFloat(Double.pi) - angle
            }
            nextAngle = fmod(nextAngle, CGFloat(Double.pi) * 2.0)
            let subValues = shootLaser(with: nextAngle, pos: nextPos, maxReflect: maxReflect - 1, minAngle: minAngle)
            var result = [nextPos]
            result.append(contentsOf: subValues)
            return result
        }
    }
    
    func addEffect(to bullet:SKShapeNode) {
        
        let shader = SKShader.init(fileNamed: "rayBullet.fsh")
        bullet.strokeShader = shader
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {
        reverseLaser(node: targetNode!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            targetNode = laser(at: CGPoint(x: t.location(in: self).x, y: 0), count: 24)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
