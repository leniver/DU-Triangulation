---@class Translator : Class
---@field labels {[string] : string}|nil
Translator = Class()

-- French puts a non-breaking space before ":". Written as bytes so that every Lua parser and minifier reads it.
local NBSP = "\194\160"

-- The keys are the English texts. "%s" is filled with the extra arguments of Translator:get().
local labels = {
    fr = {
        ["Ready"] = "Prêt",
        ["Too close"] = "Trop proche",
        ["Move sideways"] = "Décalez-vous sur le côté",
        ["Move up or down"] = "Montez ou descendez",
        ["Triangulation failed"] = "Échec de la triangulation",
        ["Triangulation hidden"] = "Triangulation masquée",
        ["Triangulation"] = "Triangulation",
        ["Add reading"] = "Ajouter une mesure",
        ["Show/hide (resets)"] = "Afficher/masquer (réinitialise)",
        ["Fast scroll"] = "Défilement rapide",
        ["Track distance to result"] = "Suivre la distance au résultat",
        ["Calibration"] = "Calibrage",
        ["Calibration mode"] = "Mode calibrage",
        ["Move overlay up/down"] = "Déplacer en haut/en bas",
        ["Move overlay left/right"] = "Déplacer à gauche/à droite",
        ["Adjust angle"] = "Ajuster l’angle",
        ["Calibration on: see the help for the keys"] = "Calibrage activé" .. NBSP .. ": voir l’aide pour les touches",
        ["Calibration off. To keep it, set these Lua parameters:"] = "Calibrage désactivé. Pour le conserver, réglez ces paramètres Lua" .. NBSP .. ":",
        ["mouse wheel"] = "molette",
        ["Miscellaneous"] = "Divers",
        ["Hide help"] = "Masquer l’aide",
        ["Waypoint to the board"] = "Point de passage vers la carte de programmation",
        ["Waypoint set to the board"] = "Point de passage placé sur la carte de programmation",
        ["Show help: %s"] = "Afficher l’aide" .. NBSP .. ": %s",
        ["Version %s"] = "Version %s",
        ["Triangulation settings"] = "Réglages de la triangulation",
        ["Screen resolution: %s"] = "Résolution de l’écran" .. NBSP .. ": %s",
        ["Left offset: %s px"] = "Décalage horizontal" .. NBSP .. ": %s px",
        ["Top offset: %s px"] = "Décalage vertical" .. NBSP .. ": %s px",
        ["Font size: %s px"] = "Taille de police" .. NBSP .. ": %s px",
        ["Angle: %s°"] = "Angle" .. NBSP .. ": %s°",
    },
    de = {
        ["Ready"] = "Bereit",
        ["Too close"] = "Zu nah",
        ["Move sideways"] = "Zur Seite bewegen",
        ["Move up or down"] = "Nach oben oder unten bewegen",
        ["Triangulation failed"] = "Triangulation fehlgeschlagen",
        ["Triangulation hidden"] = "Triangulation ausgeblendet",
        ["Triangulation"] = "Triangulation",
        ["Add reading"] = "Messung hinzufügen",
        ["Show/hide (resets)"] = "Ein-/Ausblenden (setzt zurück)",
        ["Fast scroll"] = "Schnell scrollen",
        ["Track distance to result"] = "Entfernung zum Ergebnis verfolgen",
        ["Calibration"] = "Kalibrierung",
        ["Calibration mode"] = "Kalibriermodus",
        ["Move overlay up/down"] = "Nach oben/unten verschieben",
        ["Move overlay left/right"] = "Nach links/rechts verschieben",
        ["Adjust angle"] = "Winkel anpassen",
        ["Calibration on: see the help for the keys"] = "Kalibrierung an: Tasten siehe Hilfe",
        ["Calibration off. To keep it, set these Lua parameters:"] = "Kalibrierung aus. Zum Beibehalten diese Lua-Parameter setzen:",
        ["mouse wheel"] = "Mausrad",
        ["Miscellaneous"] = "Sonstiges",
        ["Hide help"] = "Hilfe ausblenden",
        ["Waypoint to the board"] = "Wegpunkt zur Programmierplatine",
        ["Waypoint set to the board"] = "Wegpunkt zur Programmierplatine gesetzt",
        ["Show help: %s"] = "Hilfe anzeigen: %s",
        ["Version %s"] = "Version %s",
        ["Triangulation settings"] = "Triangulationseinstellungen",
        ["Screen resolution: %s"] = "Bildschirmauflösung: %s",
        ["Left offset: %s px"] = "Horizontaler Versatz: %s px",
        ["Top offset: %s px"] = "Vertikaler Versatz: %s px",
        ["Font size: %s px"] = "Schriftgröße: %s px",
        ["Angle: %s°"] = "Winkel: %s°",
    },
}

--- Translations by language code, for the tests.
Translator.languages = labels

---@param lang? string language code (en, fr, de); defaults to the "language" Lua parameter
function Translator:init(lang)
    self.labels = labels[string.lower(lang or language or "en")]
end

--- The text for `key` in the current language, or `key` itself (English) when there is no translation.
--- Extra arguments fill the "%s" placeholders.
---@param key string
---@param ... any
---@return string
function Translator:get(key, ...)
    local text = (self.labels ~= nil and self.labels[key]) or key
    if select("#", ...) > 0 then
        return string.format(text, ...)
    end
    return text
end
