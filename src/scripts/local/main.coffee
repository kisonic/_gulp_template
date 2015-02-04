pde = (e) ->
	if e.preventDefault
		e.preventDefault()
	else
		e.returnValue = false
	return

$(document).ready ->
	$('#fullscreen_slider').superslides
		slide_speed: 800,
		pagination: false,
		hashchange: false,
		scrollable: true

	$('.js_toggle_class').on 'click', (e) ->
		pde(e)
		$(this).toggleClass($(this).data('toggle-class'))
		return

	$('.person_info_img, .person_more_info').on 'click', (e) ->
		pde(e)
		$(this).parents('.person').toggleClass('show_person_more_info')
		return

	return