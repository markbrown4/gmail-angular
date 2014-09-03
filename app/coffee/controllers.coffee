
app.controller 'ThreadsController', ($rootScope, $scope, Thread, $location)->
  $scope.threads = []
  Thread.query (threads)->
    $scope.threads = threads
    $scope.page =
      from: 1
      to: threads.length
      count: threads.length

  $scope.isRouteActive = (route)->
    route == $location.path()

  $scope.selectAll = ->
    for thread in $scope.threads
      thread.selected = true

  $scope.selectNone = ->
    for thread in $scope.threads
      thread.selected = false

  $scope.selectUnread = ->
    for thread in $scope.threads
      thread.selected = thread.unread

  $scope.selectRead = ->
    for thread in $scope.threads
      thread.selected = !thread.unread

  $scope.someSelected = ->
    selected = false
    for thread in $scope.threads
      selected = true if thread.selected

    selected

  $scope.noneSelected = ->
    !$scope.someSelected()

  $scope.allSelected = ->
    return false if $scope.threads.length == 0
    selected = true
    for thread in $scope.threads
      selected = false if !thread.selected

    selected

  $scope.selectToggle = ->
    if $scope.someSelected()
      $scope.selectNone()
    else
      $scope.selectAll()

  $scope.composeMessage = ->
    $rootScope.$broadcast 'composeMessage'

app.controller 'ThreadController', ($scope, $routeParams, Thread)->
  $scope.thread = Thread.get { id: $routeParams.id }, (thread)->
    $scope.lastMessage = thread.messages[thread.messages.length-1]
    $scope.lastMessage.active = true

  $scope.toggleActive = (message)->
    unless message == $scope.lastMessage
      message.active = !message.active

app.controller 'ComposeController', ($rootScope, $scope, $timeout, Flash)->

  $scope.close = ->
    $scope.visible = false
    $scope.cc_active = false
    $scope.bcc_active = false
    $scope.active_section = null
    $scope.message =
      from: currentAccounts[0]

  $scope.close()

  $rootScope.$on 'composeMessage', ->
    $scope.visible = true
    $scope.active_section = 'to'
    $scope.message =
      from: currentAccounts[0]

  $scope.send = ->
    $scope.close()

    Flash.message = 'Sending...'
    $timeout ->
      Flash.message = ''
    , 1000


app.controller 'FlashController',  ($scope, Flash)->
  $scope.flash = Flash
