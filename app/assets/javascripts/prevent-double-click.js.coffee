$ = jQuery

$ ->
  $(".prevent-double-click").each ->
    $(this).prevent_double_click()

$.fn.prevent_double_click = () ->
  control = $(this)
  control.click((event) ->
    last_clicked = control.data("last-clicked")

    if last_clicked && jQuery.now() - last_clicked < 8000
      event.preventDefault()
      event.stopPropagation()
      return

    control.data("last-clicked", jQuery.now())
  )
