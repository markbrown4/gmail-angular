
app.controller 'ThreadsController', ($scope, $http)->
  $http.get('/api/threads.json').success (data)->
    $scope.threads = data

app.controller 'ThreadController', ($scope, $routeParams, $http)->
  lastMessage = null

  $http.get("/api/threads/#{ $routeParams.id }.json").success (data)->
    $scope.thread = data
    lastMessage = _.last($scope.thread.messages)
    lastMessage.active = true

  $scope.toggleActive = (message)->
    unless message == lastMessage
      message.active = !message.active
