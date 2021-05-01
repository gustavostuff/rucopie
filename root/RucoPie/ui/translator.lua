local translator = {
  current = 'EN'
}

local labels = {
  'Back',
  'Options',
  'Systems',
  'Refresh Game List',
  'Themes',
  'Restart',
  'Shutdown',
  'Advanced',
  'Smooth UI',
  'Smooth Games',
  'Stretch Games',
  'Network Name',
  'Password',
  'Apply',
  'Set theme',
  'Refresh resolutions',
  'Show debug info',
  'Preview',
  'Language',
  'Add',
  'Remove',
  'Confirm',
  'Cancel'
}

local function initLang(translations)
  local set = {}
  for i, label in ipairs(labels) do
    set[label] = translations[i]
  end

  return set
end

translator.EN = {
  -- empty, EN is default (see translator.get() below)
}

translator.ES = initLang({
  'Volver',
  'Opciones',
  'Sistemas',
  'Recargar Lista de Juegos',
  'Temas',
  'Reiniciar',
  'Apagar',
  'Avanzado',
  'Suavizar Interfaz',
  'Suavizar Juegos',
  'Estirar Juegos',
  'Nombre de la red',
  'Contraseña',
  'Aplicar',
  'Aplicar tema',
  'Actualizar resoluciones',
  'Mostrar debug info',
  'Ver',
  'Idioma',
  'Agregar',
  'Quitar',
  'Confirmar',
  'Cancelar'
})

translator.FR = initLang({
  'Retourner',
  'Options',
  'Systèmes',
  'Actualiser la Liste des Jeux',
  'Thèmes',
  'Redémarrer',
  'Éteindre',
  'Avancé',
  'Lisse UI',
  'Lisse Jeux',
  'Étirer Jeux',
  'Nom de Réseau',
  'Mot de passe',
  'Appliquer',
  'Définir le thème',
  'Actualiser les résolutions',
  'Afficher les info de débogage',
  'Aperçu',
  'Langue',
  'Ajouter',
  'Supprimer',
  'Confirmer',
  'Annuler'
})

function translator.get(text) -- text must be in English by default
  local lang = translator[translator.current]
  if lang then
    return lang[text] or text
  else
    error('No language ' .. translator.current .. ' is defined.')
  end
end

function translator.set(code)
  translator.current = code
end

return translator
