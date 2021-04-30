local translator = {
  current = 'FR'
}

translator.ES = {
  ['Back'] = 'Volver',
  ['Options'] = 'Opciones',
  ['Systems'] = 'Sistemas',
  ['Refresh Game List'] = 'Recargar Lista de Juegos',
  ['Themes'] = 'Temas',
  ['Restart'] = 'Reiniciar',
  ['Shutdown'] = 'Apagar',
  ['Advanced'] = 'Avanzado',
  ['Smooth UI'] = 'Suavizar Interfaz',
  ['Smooth Games'] = 'Suavizar Juegos',
  ['Stretch Games'] = 'Estirar Juegos',
  ['Network Name'] = 'Nombre de la red',
  ['Password'] = 'Contraseña',
  ['Apply'] = 'Aplicar',
  ['Set theme'] = 'Aplicar tema',
  ['Refresh resolutions'] = 'Recargar resoluciones',
  ['Show debug info'] = 'Mostrar debug info',
  ['Preview'] = 'Ver',
  ['Language'] = 'Idioma'
}

translator.FR = {
  ['Back'] = 'Retourner',
  ['Options'] = 'Options',
  ['Systems'] = 'Systèmes',
}

function translator:get(text)
  return self[self.current][text] or text
end

return translator
