//
//  FluencyDC.swift
//  CogniApp
//
//  Created by Dylan Bautista on 13/12/25.
//

import Foundation


class FluencyDomainController {
    
    private let categories: [String: [String]] = [
    "Animals": [""],
    "Menjar": [""],
    "Països": [""],
    "Noms de Persones": [""],
    "Professions": [""],
    "Instruments": [""]
    ]

    func comencaPer(paraula: String, lletra: Character) -> Bool {
        guard let primeraLletra = paraula.lowercased().first else {
            return false
        }
        return primera == Character(lletra.lowercased())
    }

    func pertanyCategoria(paraula: String, categoria: String) -> Bool 
    {
        guard let paraulesCategoria = categories[categoria.lowercased()] else {
            return false
        }
        return paraulesCategoria.contains(paraula.lowercased())
    }
}
