
window.app = angular.module('nGmail', ['ngRoute', 'ngSanitize'])

app.config ($routeProvider)->
  $routeProvider
    .when '/inbox',
      templateUrl: 'views/threads.html'
      controller: 'ThreadsController'
    .when '/threads/:id',
      templateUrl: 'views/thread.html'
      controller: 'ThreadController'
    .otherwise
      redirectTo: '/inbox'

app.run ($rootScope)->
  $rootScope.current_user = currentUser