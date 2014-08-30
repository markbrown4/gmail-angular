
window.app = angular.module('nGmail', [])

app.run ($rootScope)->
  $rootScope.current_user = currentUser
