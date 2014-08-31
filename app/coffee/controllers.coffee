
app.controller 'ThreadsController', ($scope, Thread)->
  $scope.threads = Thread.query()

app.controller 'ThreadController', ($scope, $routeParams, Thread)->
  $scope.thread = Thread.get { id: $routeParams.id }, (thread)->
    $scope.lastMessage = thread.messages[thread.messages.length-1]
    $scope.lastMessage.active = true

  $scope.toggleActive = (message)->
    unless message == $scope.lastMessage
      message.active = !message.active
