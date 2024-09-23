//
//  WordLoader.swift
//  Wordle
//
//  Created by Ariuna Banzarkhanova on 22/09/24.
//
import Foundation

class WordLoader {
    static func loadWords(from filename: String) -> [String]? {
        if let fileURL = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let wordList = try JSONDecoder().decode(WordList.self, from: data)
                return wordList.words
            } catch {
                print("Ошибка при чтении файла: \(error)")
            }
        } else {
            print("Файл не найден.")
        }
        return nil
    }
}
