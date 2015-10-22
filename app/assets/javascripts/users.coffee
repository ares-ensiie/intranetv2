# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $(document).on 'change', '.btn-file :file', ->
	  input = $(this)
	  numFiles = if input.get(0).files then input.get(0).files.length else 1
	  label = input.val().replace(/\\/g, '/').replace(/.*\//, '')
	  input.trigger 'fileselect', [
	    numFiles
	    label
	  ]
  	return

  $('.btn-file :file').on 'fileselect', (event, numFiles, label) ->
    input = $(this).parents('.input-group').find(':text')
    log = if numFiles > 1 then numFiles + ' files selected' else label
    if input.length
      input.val log
    return
  return
