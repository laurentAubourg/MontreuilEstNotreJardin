//
//  UIStringExtension.swift
//  reciplease
//
//  Created by laurent aubourg on 12/11/2021.
//

import Foundation

extension String {
    /**
     * Check if a string contains at least one element
     */
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespaces) == String() ? true : false
    }
}
/*
La ville de Montreil met à disposition un ensemble de jeux de données ouvertes ÷n L'un de ceux ci est consacré aux espaces végétalisés, aux jardins partagés
*/
