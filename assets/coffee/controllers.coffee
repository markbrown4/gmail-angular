
app.controller 'ThreadsController', ($scope, $http)->

  $http.get('/api/threads.json').success (data)->
    $scope.threads = data
