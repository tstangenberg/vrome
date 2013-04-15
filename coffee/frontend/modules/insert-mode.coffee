class InsertMode
  [caretPosition, value, lineStart, prevLineStart, nextLineStart] = [null, null]

  currentElement = ->
    elem = document.activeElement
    try
      if elem
        caretPosition = elem.selectionEnd
        value = elem.value or elem.innerText
        lineStart = caretPositionOfCurrentLine()
        prevLineStart = caretPositionOfAboveLine()
        nextLineStart = caretPositionOfNextLine()
    catch err
      Debug err
    elem

  caretPositionOfCurrentLine = ->
    value[0...caretPosition].lastIndexOf("\n") + 1

  caretPositionOfAboveLine = ->
    value[0..caretPositionOfCurrentLine()-2].lastIndexOf("\n") + 1

  caretPositionOfNextLine = ->
    position = value[caretPosition..-1].indexOf("\n")
    return value.length if position is -1
    caretPosition + position + 1

  @blurFocus: ->
    $(currentElement()).blur()

  @focusFirstTextInput: ->
    elems = $("input[type=\"text\"],input[type=\"password\"],input[type=\"search\"],input:not([type])").filter(':visible')
    $(elems[times() - 1]).focus().select()
  desc @focusFirstTextInput, "Focus the {count} input field"

  @moveToFirstOrSelectAll: ->
    currentElement()?.setSelectionRange 0, (if caretPosition is 0 then value.length else 0)
  desc @moveToFirstOrSelectAll, "Move to first words or select all"

  @moveToEnd: ->
    currentElement()?.setSelectionRange value.length, value.length
  desc @moveToEnd, "Move to end"

  @deleteToBegin: ->
    elem = currentElement()
    elem.value = value[0...lineStart] + value[caretPosition..-1]
    elem?.setSelectionRange lineStart, lineStart
  desc @deleteToBegin, "Delete to the beginning of the line"

  @deleteToEnd: ->
    elem = currentElement()
    elem.value = value[0...caretPosition] + value[nextLineStart-1..-1]
    elem?.setSelectionRange caretPosition, caretPosition
  desc @deleteToEnd, "Delete forwards to end of line"

  @deleteForwardChar: ->
    elem = currentElement()
    elem.value = value.substr(0, caretPosition) + value.substr(caretPosition + 1)
    elem?.setSelectionRange caretPosition, caretPosition
  desc @deleteForwardChar, "Delete forward char. <M-(yuio)> for delete back/forward a word/char"

  @deleteBackwardChar: ->
    elem = currentElement()
    elem.value = value.substr(0, caretPosition - 1) + value.substr(caretPosition)
    elem?.setSelectionRange caretPosition - 1, caretPosition - 1
  desc @deleteBackwardChar, "Delete backward char. <M-(yuio)> for delete back/forward a word/char"

  @deleteBackwardWord: ->
    elem = currentElement()
    elem.value = value.substr(0, caretPosition).replace(/[^\s\n.,]*?.\s*$/, "") + value.substr(caretPosition)
    position = elem.value.length - (value.length - caretPosition)
    elem?.setSelectionRange position, position
  desc @deleteBackwardWord, "Delete backward word. <M-(yuio)> for delete back/forward a word/char"

  @deleteForwardWord: ->
    elem = currentElement()
    elem.value = value.substr(0, caretPosition) + value.substr(caretPosition).replace(/^\s*.[^\s\n.,]*/, "")
    elem?.setSelectionRange caretPosition, caretPosition
  desc @deleteForwardWord, "Delete forward word. <M-(yuio)> for delete back/forward a word/char"

  @moveBackwardWord: ->
    elem = currentElement()
    str = value.substr(0, caretPosition).replace(/[^\s\n.,]*?.\s*$/, "")
    elem?.setSelectionRange str.length, str.length
  desc @moveBackwardWord, "Move backward word. <M-(hjkl)> for move back/forward a word/char"

  @moveForwardWord: ->
    elem = currentElement()
    position = value.length - value.substr(caretPosition).replace(/^\s*.[^\s\n.,]*/, "").length
    elem?.setSelectionRange position, position
  desc @moveForwardWord, "Move forward word. <M-(hjkl)> for move back/forward a word/char"

  @moveBackwardChar: ->
    elem = currentElement()
    elem.setSelectionRange caretPosition - 1, caretPosition - 1
  desc @moveBackwardChar, "Move backward char. <M-(hjkl)> for move back/forward a word/char"

  @moveForwardChar: ->
    elem = currentElement()
    elem.setSelectionRange caretPosition + 1, caretPosition + 1
  desc @moveForwardChar, "Move forward char. <M-(hjkl)> for move back/forward a word/char"


  @externalEditorCallBack: (msg) ->
    $("[vrome_edit_id='#{msg.edit_id}']").val(msg.value).removeAttr("vrome_edit_id")

  @externalEditor: ->
    elem = currentElement()
    edit_id = String(Math.random())
    text = elem.value.substr(0, elem.selectionStart)
    line = 1 + text.replace(/[^\n]/g, "").length
    column = 1 + text.replace(/[^]*\n/, "").length
    elem.setAttribute "vrome_edit_id", edit_id
    Post action: "Editor.open", callbackAction: "InsertMode.externalEditorCallBack", data: elem.value, edit_id: edit_id, line: line, col: column

  desc @externalEditor, "Launch the external editor"
  @externalEditor.options = {
    editor:
      description: "Set editor command,default 'editor' is 'gvim -f'"
      example: "set editor=gvim -f"
  }


root = exports ? window
root.InsertMode = InsertMode
