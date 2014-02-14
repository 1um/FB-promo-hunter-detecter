# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

click_next = false
$(".profile_form form input:radio").on 'change', ->
  $(this).parent('form').submit()

$('.button_to input:submit').on 'click', ->
  $(this).prop('disabled',true)
  $(this).parents('form').submit()
$('.button_to').on 'ajax:success', (e, data, status, xhr)->
  $(this).find("input:submit").prop('disabled',false)
  input = $(this).parents('tr').find('.percentage input')
  input.val(data.percent)
  if  data.right   
    input.css('background-color', 'green')
  else
    input.css('background-color', 'red')
  if click_next
    $(this).parents('tr').next().find('input:submit').trigger('click')
$('#auto_click').on 'change', (e)->
  click_next = $(this).is(":checked")  