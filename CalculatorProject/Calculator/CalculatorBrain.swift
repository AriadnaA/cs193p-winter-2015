//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Kate Arapova on 16.10.15.
//  Copyright © 2015 Kate Arapova. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case NullaryOperation(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                    return symbol
                case .NullaryOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    var description: String {
        get {
            let ops = opStack
            var (desc, newOps) = describe(ops)
            while newOps.count > 0 {
                let (nextDesc, nextOps) = describe(newOps)
                desc = "\(nextDesc!) , \(desc!)"
                newOps = nextOps
            }
            return "\(desc!)"
        }
    }
    
    init() {
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", {sin($0)}))
        learnOp(Op.UnaryOperation("cos", {cos($0)}))
        learnOp(Op.NullaryOperation("∏", { M_PI }))
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
    }
    
    // add for Assignment 3
    //    var program: AnyObject { // guaranteed to be a PropertyList
    //        get {
    //            return opStack.map{ $0.description }
    //        }
    //        set {
    //            if let opSymbols = newValue as? Array<String> {
    //                var newOpStack = [Op]()
    //                for opSymbol in opSymbols {
    //                    if let op = knownOps[opSymbol] {
    //                        newOpStack.append(op)
    //                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
    //                        newOpStack.append(.Operand(operand))
    //                    }
    //                }
    //                opStack = newOpStack
    //            }
    //        }
    //    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        // Lecture 3, 30min - recursion explanation
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch  op{
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            case .NullaryOperation(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    } else {
                        return (operand1, op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) =  \(result) with \(remainder) left over")
        //print("variables \(variableValues) ")
        return result
    }
    
    func pushOperand(operand: Double?) -> Double? {
        if let op1 = operand  {
            opStack.append(Op.Operand(op1))
        }
        return evaluate()
    }
    
    func pushOperand(operand: String?) -> Double? {
        if let op1 = operand  {
            opStack.append(Op.Variable(op1))
        }
        return evaluate()
    }
    
    func setVariable(symbol: String, operand: Double?) {
        if let op1 = operand {
            variableValues[symbol] = op1
        }
    }
    
    func performOperation(symbol: String)  -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearOps() {
        opStack = []
        variableValues = [:]
    }
    
    private func describe(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch  op{
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let symbol):
                return (symbol, remainingOps)
            case .NullaryOperation(let symbol, _):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = describe(remainingOps)
                if let operand = operandEvaluation.result{
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = describe(remainingOps)
                var op1:String
                if let operand1 = op1Evaluation.result{
                    if remainingOps.count < 2 {
                        return ("? \(symbol) \(operand1)", op1Evaluation.remainingOps)
                    } else {
                        if remainingOps.count - op1Evaluation.remainingOps.count > 2 {
                            op1 = "(\(operand1))"
                        } else {
                            op1 = "\(operand1)"
                        }
                        let op2Evaluation = describe(op1Evaluation.remainingOps)
                        if let operand2 = op2Evaluation.result {
                            return ("\(operand2) \(symbol) \(op1)", op2Evaluation.remainingOps)
                        }
                    }
                }
            }
        }
        return (" ", ops)
    }
}