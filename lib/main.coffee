WordcountView = require './wordcount-view'
view = null
tile = null

module.exports =

  config:
    extensions:
      title: 'Autoactivated file extensions'
      description: 'list of file extenstions which should have the wordcount plugin enabled'
      type: 'array'
      default: [ 'md', 'markdown', 'readme', 'txt', 'rst' ]
      items:
        type: 'string'
      order: 1
    noextension:
      title: 'Autoactivate for files without an extension'
      description: 'wordcount plugin enabled for files without a file extension'
      type: 'boolean'
      default: false
      items:
        type: 'boolean'
      order: 2
    goal:
      title: 'Work toward a word goal'
      description: 'shows a bar showing progress toward a word goal'
      type: 'number'
      default: 0
      order: 3
    goalColor:
      title: 'Color for word goal'
      description: 'use a CSS color value, like rgb(255, 255, 255) or green'
      type: 'string'
      default: 'rgb(0, 85, 0)'
      order: 4

  activate: (state) ->
    view = new WordcountView()
    atom.workspace.observeTextEditors (editor) ->
      editor.onDidChange -> view.update_count editor
      editor.onDidChangeSelectionRange -> view.update_count editor

    atom.workspace.onDidChangeActivePaneItem @show_or_hide_for_item

    @show_or_hide_for_item atom.workspace.getActivePaneItem()

  show_or_hide_for_item: (item) ->
    extensions = (atom.config.get('wordcount.extensions') || []).map (extension) -> extension.toLowerCase()
    no_extension = atom.config.get('wordcount.noextension') && item?.buffer?.file?.path.split('.').length == 1
    current_file_extension = item?.buffer?.file?.path.split('.').pop().toLowerCase()
    if no_extension or current_file_extension in extensions
      view.css("display", "inline-block")
    else
      view.css("display", "none")

  consumeStatusBar: (statusBar) ->
    tile = statusBar.addRightTile(item: view, priority: 100)

  deactivate: ->
    tile?.destroy()
    tile = null
