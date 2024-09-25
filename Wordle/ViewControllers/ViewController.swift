//
//  ViewController.swift
//  Wordle
//
//  Created by Ariuna Banzarkhanova on 22/09/24.
//

import UIKit

class ViewController: UIViewController {
    
    var answers: [String] = []
    
    var answer = ""
    private var guesses: [[Character?]] = Array(repeating: Array(repeating: nil, count: 5), count: 6)
    
    var isRowConfirmed: Bool = false
    var isRowCompleted: Bool = false
    
    let gameBoardVC = BoardViewController()
    let keyBoardVC = KeyboardViewController()
    
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loadedWords = WordLoader.loadWords(from: "words") {
            answers = loadedWords
        }
        answer = answers.randomElement() ?? "after"
        print(answer)
        view.backgroundColor = .black
        addChildren()
    }
    
    private func addChildren() {
        addChild(gameBoardVC)
        gameBoardVC.didMove(toParent: self)
        gameBoardVC.dataSource = self
        gameBoardVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameBoardVC.view)
        
        addChild(keyBoardVC)
        keyBoardVC.didMove(toParent: self)
        keyBoardVC.delegate = self
        keyBoardVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyBoardVC.view)
        
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            gameBoardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameBoardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameBoardVC.view.bottomAnchor.constraint(equalTo: keyBoardVC.view.topAnchor),
            gameBoardVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gameBoardVC.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.65),
            
            keyBoardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyBoardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyBoardVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

extension ViewController: KeyboardViewControllerDelegate {
    func keyboardViewController(_ vc: KeyboardViewController, didTapKey letter: Character) {
        if letter == "⌫" {
            removeLastCharacter()
        } else if letter == "✓"{
            confirmCurrentRow()
            isRowCompleted = false
        } else {
            addCharacter(letter)
        }
        gameBoardVC.reloadData()
    }
    
    private func isRowComplete() -> Bool {
        guard let currentRow = guesses.first(where: { $0.contains(nil) }) else {
            return true
        }
        return currentRow.compactMap({ $0 }).count == 5
    }
    
    private func addCharacter(_ letter: Character) {
        var stop = false
        for i in 0..<guesses.count {
            for j in 0..<guesses[i].count {
                if guesses[i][j] == nil {
                    guesses[i][j] = letter
                    stop = true
                    break
                }
            }
            if stop {
                break
            }
        }
        isRowCompleted = isRowComplete()
    }
    
    private func removeLastCharacter() {
        var stop = false
        for i in (0..<guesses.count).reversed() {
            for j in (0..<guesses[i].count).reversed() {
                if guesses[i][j] != nil {
                    guesses[i][j] = nil
                    stop = true
                    break
                }
            }
            if stop {
                break
            }
        }
    }
    
    private func confirmCurrentRow() {
        isRowConfirmed = true
        gameBoardVC.reloadData()
    }
}

extension ViewController: BoardViewControllerDataSource {
    
    var currentGuesses: [[Character?]] {
        return guesses
    }
    
    func boxColor(at indexPath: IndexPath) -> UIColor? {
        let rowIndex = indexPath.section
        
        guard isRowConfirmed else {
            return nil
        }
        
        let count = guesses[rowIndex].compactMap({$0}).count
        guard count == 5 else {
            return nil
        }
        
        let indexedAnswer = Array(answer)
        
        guard let letter = guesses[indexPath.section][indexPath.row] else {
            return nil
        }
        
        if !indexedAnswer.contains(letter) {
            return .systemGray
        }
        
        if indexedAnswer[indexPath.row] == letter {
            return .systemGreen
        }
        
        return .white
    }
    
    func labelTextColor(at indexPath: IndexPath) -> UIColor? {
        let color = boxColor(at: indexPath)
        
        if color == .white || color == .systemGreen {
            return .black
        } else {
            return .white
        }
    }
}
