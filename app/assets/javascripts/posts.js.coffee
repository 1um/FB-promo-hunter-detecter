# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(".manual_type form").on 'ajax:success', ->
  $(this).parents('.post').remove()

