
app.controller 'ThreadsController', ($scope, Thread, $location)->
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

app.controller 'ThreadController', ($scope, $routeParams, Thread)->
  $scope.thread = Thread.get { id: $routeParams.id }, (thread)->
    $scope.lastMessage = thread.messages[thread.messages.length-1]
    $scope.lastMessage.active = true

  $scope.toggleActive = (message)->
    unless message == $scope.lastMessage
      message.active = !message.active
