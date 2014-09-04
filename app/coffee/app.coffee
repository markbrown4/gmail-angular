
window.app = angular.module('nGmail', ['ngRoute', 'ngSanitize', 'ngResource'])

app.config ($routeProvider)->
  $routeProvider
    .when '/inbox',
      templateUrl: 'partials/threads.html'
    .when '/threads/:id',
      templateUrl: 'partials/thread.html'
    .otherwise
      redirectTo: '/inbox'

app.run ($rootScope)->
  $rootScope.current_user = currentUser
