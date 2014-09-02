
app.directive 'stopEvent', ->
  restrict: 'A'
  link: (scope, element, attr)->
    element.bind 'click', (e)->
      e.preventDefault()
      e.stopPropagation()

app.directive "dropDown", ->
  restrict: 'E'
  link: (scope, element, attrs, dropdownCtrl)->
    dropdownCtrl.init element
  controller: ->
    @init = (element)->
      element.bind 'click', @toggle

    @toggle = (event)->
      event.preventDefault()
      angular.element(this).toggleClass 'active'

    return this

