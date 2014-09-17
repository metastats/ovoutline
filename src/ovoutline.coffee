close = ->
  $('#popup_content').empty()
  $('#popup').css 'display', 'none'

save = (filer, db)->
  filer.write 'file.txt', {
    data: JSON.stringify(db)
    type: 'text/plain'
  }

redraw = (filter, db)->
  $('#content').empty()
  table = $ '<table></table>'
  $.each db, (index, value)->
    tr = $ '<tr></tr>'
    select = $ '<p>' + '</p>'
    input = $ '<p>' + value['text'] + '</p>'
    submit = $ "<p class='link' title='#{index}'>Delete</p>"
    submit.click ->
      ask = window.confirm 'Delete this?'
      if ask then remove(filter, db, $(this).attr('title'))
    tr.append $('<td class="select"></td>').append(select)
    tr.append $('<td class="input"></td>').append(input)
    tr.append $('<td class="submit"></tr>').append(submit)
    table.append tr
  table.append line(filter, db)
  $('#content').append table
  window.scrollTo(0, document.body.scrollHeight)

line = (filter, db)->
  tr = $('<tr class="line"></tr>')
  select = $ '<select></select>'
  select.append $ '<option>Category</option>'

  input = $ '<input class="text" type="text"></input>'
  input.focus ->
    close()
    dt = new Date($.now())
    $(this).attr 'value',
      dt.getFullYear() + sprintf('.%02d.%02d, ', dt.getMonth(), dt.getDate()) +
      sprintf('%02d:%02d:%02d | ', dt.getHours(), dt.getMinutes(), dt.getSeconds())

  submit = $ '<p class="link">Save</p>'
  submit.click ->
    if input.val() and input.val()[input.val().length - 2] != '|'
      db.push {
        'time': $.now()
        'category': select.val()
        'text': '' + input.val()
      }
      save filter, db
      redraw filter, db

  input.keypress (e)->
      char = true
      if $(this).val()[$(this).val().length - 2] == '|'
        char = false
      if e.which == 13 and $(this).val() and char
        db.push {
          'time': $.now()
          'category': select.val()
          'text': '' + input.val()
        }
        save filter, db
        redraw filter, db

  tr.append $('<td class="select"></td>').append(select)
  tr.append $('<td class="input"></td>').append(input)
  tr.append $('<td class="submit"></td>').append(submit)

popup = (copy, contents, values)->
    $('#popup_content').empty().append copy.append(contents)
    for value in values
      $('#popup_content').append copy.append(value)
    $('#popup').css 'display', 'block'

categories = ->
  $('#categories_link').click ->
    contents = $('#categories_template').html()
    copy = $ '<div id="categories"></div>'
    popup copy, contents, [ ]

download = (filer)->
  $('#download_link').click ->
    contents = $('#download_template').html()
    copy = $ '<div id="download"></div>'
    textarea = $ '<textarea></textarea>'

    filer.open 'file.txt', (file)->
      reader = new FileReader()
      reader.onload = (e)->
        textarea.text reader.result
        if reader.result == '[]'
          popup copy, contents, [ ]
        else
          copybutton = $ '<p class="link">Copy</p>'
          copybutton.click ->
            close()
          popup copy, contents, [ textarea, copybutton ]
      reader.readAsText(file)

upload = (filer)->
  $('#upload_link').click ->
    contents = $('#upload_template').html()
    copy = $ '<div id="upload"></div>'

    textarea = $ '<textarea></textarea>'
    savebutton = $ '<p class="link">Save</p>'
    savebutton.click ->
      if textarea.val()
        save filer, JSON.parse(textarea.val())
        redraw filer, JSON.parse(textarea.val())
        close()
     popup copy, contents, [ textarea, savebutton ]

clear = (filer)->
  $('#clear_link').click ->
    ask = window.confirm 'Would you like to empty the scaffold?'
    if ask
      close()
      empty(filer)

$(document).ready ->
  filer = new Filer()
  filer.init {
    persistent: true
    size: 1024 * 1024
  }, ->
    filer.open 'file.txt', (file)->
      reader = new FileReader()
      reader.onload = (e)->
        redraw filer, JSON.parse(reader.result)
      reader.readAsText(file)
      categories()
      download filer
      upload filer
      clear filer

  $('#close_link').click ->
    close()

remove = (filer, db, index)->
  db.splice index, 1
  save filer, db
  redraw filer, db

empty = (filer)->
  save filer, []
  redraw filer, []

error = (e)->
  console.log 'Error' + e.name
