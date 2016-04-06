# nGmail

What better example of a rich client-side application than Gmail, the iconic web app that started it all.

In this tutorial we'll explain all of the important components of Angular - Modules, Controllers, Scopes, Directives, Services and Filters whilst building out a Gmail clone.  No prior knowledge of Angular is necessary.

[Screencast](http://youtu.be/1P2lPfJejek) - Bump up the quality to 720p for better viewing.

### Prerequisites

You'll need npm installed and an intermediate knowledge of JavaScript and a tolerance or love of CoffeeScript.

## Install

```bash
git clone https://github.com/markbrown4/gmail-angular
cd gmail-angular
git checkout origin/start
npm start
```

In a separate process watch our assets for changes

```bash
npm run assets
```

Hit [http://localhost:8000/](http://localhost:8000/) in your favourite browser and you should see a bunch of familiar Gmail elements on the screen - you'll be bringing that static page to life and responding to events, just like Pinocchio.

If you're not familiar with Bower, it simply downloads the dependencies listed in bower.json into the bower_components/ directory.  These are already included in scripts at the bottom of index.html

```html
...
<script src="bower_components/angular/angular.js"></script>
<script src="bower_components/angular-route/angular-route.js"></script>
<script src="bower_components/angular-resource/angular-resource.js"></script>
<script src="bower_components/angular-sanitize/angular-sanitize.js"></script>
<script src="app/js/app.js"></script>
<script src="app/js/controllers.js"></script>
<script src="app/js/directives.js"></script>
<script src="app/js/filters.js"></script>
<script src="app/js/services.js"></script>
</body>
```

All you need to do to start using Angular is to include angular.js and whack an ng-app attribute on the part of the page you want to use it - Let's add it to the `<html>` tag so we can use it everywhere.

```html
<html lang="en" ng-app>
```

This special attribute is an angular directive, we'll cover directives in detail later, for now all you need to know is that they are attributes or elements for expanding the capabilities of HTML.

*Congratulations*, you're running Angular!

We can now start adding expressions and directives anywhere within the document, add an expression to the title tag to confirm everything is working as it should.

```html
<title>nGmail {{ (2 + 2) + "!" }}</title>
```

After loading the title in the browser should read nGmail 4!

These expressions in double curly braces are auto updated bindings that are evaluated whenever the underlying data changes, you'll be using these whenever you want to dynamically produce a value in the HTML.

### Modules

Modules are a way to group related controllers, directives and services together.  Let's start by creating a module for our application and adding the name to the ng-app attribute we added earlier.  angular.module takes 2 arguments, a name and an array of dependencies, which we don't require just yet.


*app.coffee*

```coffee
window.app = angular.module('nGmail', [])
```

*index.html*

```html
<html lang="en" ng-app="nGmail">
```

## The Inbox

Let's start by making our list of threads in the inbox dynamic.


### Controllers

Controllers are responsible for exposing variables and functions to the view through a $scope object, you link an HTML element to a controller through the ng-controller attribute

```html
<ul id="threads" ng-controller="ThreadsController">
...
</ul>
```

When creating a controller you give it a name a name and a list of dependencies, in this case we want to pass $scope so we can send data back to the view and $http so we can fetch JSON.

*controllers.coffee*

```coffee
app.controller 'ThreadsController', ($scope, $http)->
  $scope.threads = []
  $http.get('/api/threads/index.json').success (data)->
    $scope.threads = data
```

This code is pretty straight forward, we're making a request to `/api/threads/index.json` and saving the array in `$scope.threads`

Our view has access to all properties on this scope so we can start looping through the threads and making it dynamic.

*index.html*

```html
<ul id="threads" ng-controller="ThreadsController">
  <li ng-repeat="thread in threads">
    <a href>
      <time>{{ thread.last_message.created_at }}</time>
      <span class="check"></span>
      <span class="people">
        <span class="name" ng-repeat="person in thread.participants">{{ person.first_name }} {{ person.last_name }} </span>
        <span>({{ thread.message_count }})</span>
      </span>
      <span class="subject">{{ thread.last_message.subject }}</span>
      <span class="body">- {{ thread.last_message.snippet }}</span>
    </a>
  </li>
</ul>
```

The only new piece in this code above is the ng-repeat directive, which we're using to loop through the threads and the participants.

### Filters

We can format the date using the date filter - filters are tacked onto the end of an expression with a pipe followed by any arguments separated by colons.

```html
<time>{{ thread.last_message.created_at  | date : "MMM dd" }}</time>
```

Gmail does even better by returning a time if it's less than 1 day old, let's achieve this by making a new filter to format our smartDate

*filters.coffee*

```coffee
app.filter 'smartDate', ($filter)->
  $dateFilter = $filter('date')

  (date)->
    oneDayAgo = Date.now() - 86400000
    if date < oneDayAgo
      $dateFilter(date, "MMM dd")
    else
      $dateFilter(date, "h:mm a")
```

We're passing in the $filter dependency because we want to make use of Angular's date filter

```html
<time>{{ thread.last_message.created_at  | smartDate }}</time>
```

To confirm this is working update one of the last messages in our JSON with a fresh timestamp generated with `Date.now()` in the console, refresh the page and you should see a mix of dates and times in your inbox.

```json
"last_message": {
  ...
  "created_at": 1409366556530
}
```

Boom.

Gmail applies different styles to the thread and names if there's unread messages, let's apply these via the `ng-class` directive

```html
<li ng-repeat="thread in threads" ng-class="{ unread: thread.unread }">
  ...
  <span class="name" ng-repeat="person in thread.participants" ng-class="{ unread: person.unread }">
```

Now we'll see some nicely highlighted threads and names in our list if there's unread messages.  Angular is smart enough to mix `class` and `ng-class` and not clobber anything.  Look back at `threads/index.json` to see where these unread booleans are coming from.

The list of participants still needs work, Gmail also does these things:

- Replaces your name with "me"
- Comma separates names
- Only shows first names if the number of participants is greater than 1
- Only shows the message count if it's greater than 1

Let's put a global object in the page called `currentUser` so we can test against the current signed in user.

*index.html*

```html
...
<script>
window.currentUser = {
  email: 'markbrown4@gmail.com',
  first_name: 'Mark',
  last_name: 'Brown',
  avatar: 'me.jpg',
  accounts: [{
    id: 1,
    email: "markbrown4@gmail.com",
    first_name: "Mark",
    last_name: "Brown",
    avatar: "me.jpg"
  },{
    id: 2,
    email: "mark@inspire9.com",
    first_name: "Mark",
    last_name: "Brown",
    avatar: "me.jpg"
  },{
    id: 3,
    email: "mark@adioso.com",
    first_name: "Mark",
    last_name: "Brown",
    avatar: "me.jpg"
  }]
}
</script>
</body>
```

We could use `$http` to fetch the current signed in user but it's best to bootstrap core data like this on page load as the page is useless without it, why wait for a second response before we can make the page do something? Global variables are rightfully frowned upon but I make an exception with things like this as I do want to be to access them globally.

Let's make another filter called `smartName` to apply our logic.

```coffee
app.filter 'smartName', ->
  (person, fullName=false)->
    if currentUser.email == person.email
      'me'
    else if fullName
      "#{person.first_name} #{person.last_name}".trim()
    else
      person.first_name
```

In the view we'll use our `smartName` filter, passing through true if the threads `message_count` is 1

```html
<span class="people">
  <span ng-repeat="person in thread.participants">
    <span class="name" ng-class="{ unread: person.unread }">{{ person | smartName : thread.message_count == 1 }}</span>{{ $last ? '': ', ' }}
  </span>
  <span ng-show="thread.message_count > 1">({{ thread.message_count }})</span>
</span>
```

Within loops we can access a few magic variables like `$index`, `$first` and `$last`, we're using `$last` to conditionally omit the last comma.

The `ng-show` directive conditionally applies an 'ng-hide' class to set "display: none" on elements.  We could also use the inverse directive `ng-hide` to achieve the same thing.

```html
<span ng-hide="thread.message_count == 1">({{ thread.message_count }})</span>
```

The last thing we'll do on the inbox for now is wiring up the selected states when you toggle the checkbox, with an ng-click directive we access anything in the current scope so we can simply toggle a property on the thread and display a class on the list item.

```html
<li ng-repeat="thread in threads" ng-class="{ unread: thread.unread, selected: thread.selected }">
  ...
  <span class="check" ng-click="thread.selected = !thread.selected"></span>
```

This is the first example of 2 way binding that we've seen so far, we didn't need to do anything special to apply the selected class Angular automatically updates these bound expressions whenever the underlying data changes.

Now, we do a celebratory backfilp.  The inbox is looking sharp, and we've written surprising little code to do it.

## A second view

Let's move the `#threads` ul from `index.html` into `partials/threads.html` and shift the `#thread` div into `partials/thread.html` and load the correct template based on the route.  Add an `ng-view` directive to the now empty `#content` div to say where these views should be rendered inside.

```html
<div id="content" ng-view></div>
```

We'll inject the `ngRoute` dependencies into our `app` module, configure our routes to load the correct controller and template, and while we're here also expose our `currentUser` on `$rootScope`, making it available in all of the views.

*app.coffee*

```coffee
window.app = angular.module('nGmail', ['ngRoute'])

app.run ($rootScope)->
  $rootScope.current_user = window.currentUser

app.config ($routeProvider)->
  $routeProvider
    .when '/inbox',
      templateUrl: 'partials/threads.html'
    .when '/threads/:id',
      templateUrl: 'partials/thread.html'
    .otherwise
      redirectTo: '/inbox'
```

By default the routing will use the hash, we can easily make the router use pushState for updating the urls through `$locationProvider` but let's leave this out for now.  We link the views together using good old fashioned anchor tags.

*partials/threads.html*

```html
<a href="#/threads/{{ thread.id }}">
```

*index.html*

```html
<a href="#/inbox" class="btn"><img src="/public/images/icons/back.png"></a>
...
<li class="active"><a href="#/inbox">Inbox</a></li>
```

The thread detail view controller will need the `$routeParams` service so we can fetch the dynamic :id from our route.

*controllers.coffee*

```coffee
app.controller 'ThreadController', ($scope, $http, $routeParams)->
  $scope.thread = {}
  $http.get("/api/threads/#{ $routeParams.id }.json").success (data)->
    $scope.thread = data
```

Now for the view.

*partials/thread.html*

```html
<div id="thread" ng-controller="ThreadController">
  <h1>{{ thread.messages[0].subject }}</h1>
  <ul class="messages">
    <li ng-repeat="message in thread.messages" ng-class="{ active : message.active }">
      <div class="thread-tools">
        <time>{{ message.created_at | smartDate }} (timeAgo)</time>
        <div class="split-btn" ng-show="message.active">
          <a href class="btn"><img src="/images/icons/reply.png"></a>
          <div class="drop-down btn btn-mini">
            <img src="/images/icons/down.png">
            <ul class="align-right">
              <li><a href>Reply</a></li>
              <li><a href>Reply all</a></li>
              <li><a href>Forward</a></li>
            </ul>
          </div>
        </div>
      </div>
      <img class="avatar" src="/images/avatars/{{ message.from.avatar }}">
      <div class="from">
        <span class="name">{{ message.from | smartName }}</span>
        <span class="email">&lt;{{ message.from.email }}&gt;</span>
      </div>
      <div class="to" ng-show="message.active">to
        <span ng-repeat="person in message.to">{{ person | smartName : false }}{{ $last ? '': ', ' }}</span>
      </div>
      <div class="body" ng-bind-html="message.active ? message.body : message.snippet"></div>
    </li>
  </ul>
  <div class="reply">
    <img class="avatar" src="/images/avatars/{{ current_user.avatar }}">
    <div class="reply-box">
      <p>Click here to <a href>Reply</a>, <a href>Reply to all</a> or <a href>Forward</a></p>
    </div>
  </div>
</div>
```

The only new piece in the above template is the `ng-bind-html` directive which will santize the HTML before inserting it into the document - We'll need to pass it in as a dependency for this to work.

```coffee
window.app = angular.module('nGmail', ['ngRoute', 'ngSanitize']
```

Great, now the data in our thread list is dynamic too.

There's something funky going on with the images though, they are displaying ok but in console there's 404's that have started popping up.

The reason for this is that the browser is requesting the image at "images/avatars/{{ message.from.avatar }}" before Angular has had a chance go in and rewrite those attributes.

```html
<img src="images/avatars/{{ message.from.avatar }}">
```

We need to change these `src` attributes to `ng-src` which is specifically there to solve this problem.

```html
<img ng-src="images/avatars/{{ message.from.avatar }}" class="avatar">
...
<img ng-src="images/avatars/{{ current_user.avatar }}" class="avatar">
```

No more 404's.

Let's add one more filter for handling the `timeAgo`

```coffee
app.filter 'timeAgo', ($filter)->
  units = [
    { name: "second", limit: 60, in_seconds: 1 },
    { name: "minute", limit: 3600, in_seconds: 60 },
    { name: "hour", limit: 86400, in_seconds: 3600  },
    { name: "day", limit: 604800, in_seconds: 86400 },
    { name: "week", limit: 2629743, in_seconds: 604800  },
    { name: "month", limit: 31556926, in_seconds: 2629743 },
    { name: "year", limit: null, in_seconds: 31556926 }
  ]

  (date)->
    diff = (Date.now() - date)/1000
    return "just now" if diff < 5

    for unit in units
      if diff < unit.limit || !unit.limit
        diff =  Math.floor(diff / unit.in_seconds)
        return "#{diff} #{unit.name}#{ if diff > 1 then 's' else '' } ago"
```

And update the view accordingly

```html
<time>{{ message.created_at | smartDate }} ({{ message.created_at | timeAgo }})</time>
```

Different parts of this view are visible when the message is active, let's toggle this value using a new method we'll place on the `$scope`.

```html
<li ng-repeat="message in thread.messages" ng-class="{ active : message.active }" ng-click="toggleActive(message)">
```

Gmail automatically activates the last message and doesn't let us toggle it, let's do this in the controller.

```coffee
app.controller 'ThreadController', ($scope, $routeParams, $http)->

  $http.get("/api/threads/#{ $routeParams.id }.json").success (data)->
    $scope.thread = data
    $scope.lastMessage = thread.messages[thread.messages.length-1]
    $scope.lastMessage.active = true

  $scope.toggleActive = (message)->
    unless message == $scope.lastMessage
      message.active = !message.active
```

Nice!  We can now click between our inbox and specific thread, fetch data from our API, toggle some application state, format things nicely with custom filters - things are shaping up nicely.

### Directives

We did manage to break something by adding links to our threads though, the checkboxes 🙁

When you click on a checkbox it toggles and then follows the parent link, let's make a custom directive `stopEvent` which will prevent the event moving up to the parent link.

*directives.coffee*

```coffee
app.directive 'stopEvent', ->
  restrict: 'A'
  link: (scope, element, attr)->
    element.bind 'click', (event)->
      event.preventDefault()
      event.stopPropagation()
```

The whacky "restrict: 'A'" limits this directive to <b>A</b>ttributes, we'll look at <b>E</b>lements next.

The link function fires just after the element is added to the DOM so it's safe to mess with.

We can now start sprinkling our new `stop-event` attribute anywhere in the document we want this behavior to occur, note the normalised casing for both the directive name and attribute.

```html
<span class="check" ng-click="thread.selected = !thread.selected" stop-event></span>
```

Yay, It works!

One place we can make use of an element directive is building our drop down menus - we've got them sprinkled through the HTML already:

```html
<div class="drop-down active">
  <img src="/public/images/icons/down.png">
  <ul class="align-right">
    <li><a href>An option</a></li>
    <li><a href>Yet another</a></li>
  </ul>
</div>
```

Angular allows us to create new HTML elements and attach our desired behavior, within `#sub-header` replace the drop down's `<div>` tag with a `<drop-down>` element.

```html
<drop-down class="drop-down btn">
  ...
</drop-down>
```

Then add our new directive that will toggle a class on the root element when clicked

```coffee
app.directive 'dropDown', ->
  restrict: 'E'
  link: (scope, el, attr)->
    el.bind 'click', (event)->
      event.preventDefault()
      angular.element(this).toggleClass 'active'
```

`angular.element` delegates to jQuery if present, or in our case uses their own mini jQuery alternative *jqLite*, jqLite is a really nice option if you don't need the whole hog - it only includes a very small subset of the features so it's not a drop-in replacement (https://code.google.com/p/jqlite/wiki/UsingJQLite)

You could use jQuery to do something similar though, and if this was all the drop down element was doing there's not much difference between them.

```coffee
$(document.body).on 'click', '.drop-down', (event)->
  event.preventDefault()
  $(event.target).closest('.drop-down').toggleClass 'active'
```

Directives give you a lot more power than what we're demonstrating here though, they allow access to `$scope`, can evaluate expressions on attributes and watch for changes to make updates i.e they make the element place nicely with the rest of Angular.  Any time you'd consider using jQuery for updating the DOM and responding to user events you should first consider using a directive.

Here's a full featured drop down directive using the angular patterns if you're interested - https://github.com/angular-ui/bootstrap/blob/master/src/dropdown/dropdown.js

## Services

Services are objects that can be included anywhere else in our application like controllers, directives and filters.  There's a few different methods for creating them:

- factory: for creating a singleton
- service: for a constructor function
- provider: if you want to be able to configure a passed in object.

We'll use the `ngResource` service to work with our Models, let's first add the dependency to our app module.

```coffee
window.app = angular.module('nGmail', ['ngRoute', 'ngSanitize', 'ngResource'])
```

Models in our application will be singletons so we'll use a factory.  In `services.coffee` make a `Thread` factory responsible for querying our API through `ngResource`. The second parameter to `$resource` is a list of default params that can be overridden in the query and get methods.

```coffee
app.factory 'Thread', ($resource)->
  $resource '/api/threads/:id.json', { id: 'index' }
```

Then working with our models becomes considerably nicer in our controllers.  We just pass in `Thread` as a dependency and can then call methods like query and get to fetch our threads. Sweet.

```coffee
app.controller 'ThreadsController', ($scope, Thread)->
  $scope.threads = []
  Thread.query (threads)->
    $scope.threads = threads

app.controller 'ThreadController', ($scope, $routeParams, Thread)->
  $scope.thread = {}
  Thread.get { id: $routeParams.id }, (thread)->
    $scope.thread = thread
    $scope.lastMessage = thread.messages[thread.messages.length-1]
    $scope.lastMessage.active = true
  ...
```

### Menu States

Let's work through the `#sub-header` element next and make it respond to state changes.

The first thing we'll do is promote `ThreadsController` to manage more of the page so it's scope data can effect the sub-header too - Move it from `ul#threads` to `div#wrapper`

```html
<div id="wrapper" ng-controller="ThreadsController">
```

After querying our data we can save the counts for some simple paging.

```coffee
app.controller 'ThreadsController', ($scope, Thread)->
  $scope.threads = []
  Thread.query (threads)->
    $scope.threads = threads
    $scope.page =
      from: 1
      to: threads.length
      count: threads.length
```

We won't have any real paging data without a back-end but here's how it could be implemented. Display 1 of 1 if there's 1 record, 1-3 of 3 for 3 records and showing inactive states on the next and previous buttons.

```html
<div class="paging">
  <strong>{{ page.from == page.to ? page.from : page.from + '-'+ page.to }}</strong>
  of
  <strong>{{ page.count }}</strong>
  <div class="split-btn">
    <a href class="btn btn-mini" title="Previous" ng-class="{ inactive: page.from == 1 }"><img src="images/icons/prev.png"></a>
    <a href class="btn btn-mini" title="Next" ng-class="{ inactive: page.to == page.count }"><img src="images/icons/next.png"></a>
  </div>
</div>
```

The back button we only want to show if we're not already on the index page

```html
<a href="#/inbox" class="btn" ng-hide="isRouteActive('/inbox')"><img src="images/icons/back.png"></a>
```

Because our `isRouteActive` helper will be helpful in many pages of the app let's add it to `$rootScope`, the `$location` service gives us access to the active route.

*app.coffee*

```coffee
app.run ($rootScope, $location)->
  ...
  $rootScope.isRouteActive = (route)->
    route == $location.path()
```

Next, let's add more functions to our controller to handle the bulk select dropdown.

```coffee
app.controller 'ThreadsController', ($scope, Thread)->
  ...
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
```

Let's use all of these in the view, only showing the dropdown if it's the `/inbox` route

```html
<drop-down class="drop-down btn" ng-show="isRouteActive('/inbox')">
  <a href class="check" ng-click="selectToggle()" ng-class="{ 'all-selected': allSelected(), 'some-selected': someSelected() }" stop-event></a>
  <img src="images/icons/down.png">
  <ul>
    <li><a href ng-click="selectAll()">All</a></li>
    <li><a href ng-click="selectNone()">None</a></li>
    <li><a href ng-click="selectRead()">Read</a></li>
    <li><a href ng-click="selectUnread()">Unread</a></li>
  </ul>
</drop-down>
```

The next three buttons we only want to show if any threads are selected, the refresh button we only show if it's the `/index` route and no threads are selected.

```html
<div class="split-btn" ng-show="someSelected()">
  <a href class="btn" title="Archive"><img src="images/icons/archive.png"></a>
  <a href class="btn" title="Report Spam"><img src="images/icons/spam.png"></a>
  <a href class="btn" title="Delete"><img src="images/icons/delete.png"></a>
</div>
<a href class="btn" ng-show="isRouteActive('/inbox') && noneSelected()"><img src="images/icons/refresh.png"></a>
```

Nice.

### Search

It's a little bit silly to implement a search without a backend but implementing a client-side search gives us a chance to look at two new features so we'll do it.

```html
<input name="query" ng-model="query">
```

The `ng-model` directive saves the value of a form element on the current `$scope`, so we can pass it into a built in filter named.. `filter` which will do a fuzzy search on the data.

```html
<li ng-repeat="thread in threads | filter : query">
```

And there you go, a client-side fuzzy search in 30 characters or less.

## Compose

The final component we'll make is the New Message popover, let's add a controller and add a visible state.

*index.html*

```html
<div id="compose" ng-controller="ComposeController" ng-show="visible">
```

*controllers.coffee*

```coffee
app.controller 'ComposeController', ($scope)->
  $scope.visible = false
```

Now, things get interesting here because the compose button that launches this sits outside of this controllers scope, we need a way to communicate across controllers.  There's a few ways to do this, one way is through events on `$rootScope`, or passing in a shared object(a service) as dependencies to both controllers.

*index.html*

```html
<a href class="compose" ng-click="composeMessage()">COMPOSE</a>
```

We'll look at using events first, include `$rootScope` as a dependency and `$broadcast` our event when the button is clicked.

*controllers.coffee*

```coffee
app.controller 'ThreadsController', ($rootScope, $scope, Thread)->
  ...
  $scope.composeMessage = ->
    $rootScope.$broadcast 'composeMessage'
```

Then in our `ComposeController`, listen for the composeMessage event on `$rootScope`

```coffee
app.controller 'ComposeController', ($rootScope, $scope)->
  $scope.visible = false

  $rootScope.$on 'composeMessage', ->
    $scope.visible = true
```

Let's add close and send click handlers to call functions in our controller.

```html
<a class="close" ng-click="close()">&times;</a>
...
<input type="submit" value="Send" class="btn primary-btn" ng-click="send()">
```

Both of these actions close the New Message popover so let's do that.

```coffee
app.controller 'ComposeController', ($rootScope, $scope)->
  ...
  $scope.close = ->
    $scope.visible = false

  $scope.send = ->
    $scope.visible = false
```

As a second example of cross controller messaging let's wire up a Flash that we can push messages like "Sending..." to and display at the top of the page.  We'll be using a simple singleton object `Flash` which we can pass around and different parts of the app can set it's message.

*services.coffee*

```coffee
app.factory 'Flash', ->
  message: ''
```

Our view will reference a new controller and show itself depending on it's message.

*index.html*

```html
<div class="flash" ng-controller="FlashController" ng-show="flash.message.length > 0">
  <div class="inner">{{ flash.message }}</div>
</div>
```

We'll need to expose our `Flash` object to the view through `$scope`

```coffee
app.controller 'FlashController',  ($scope, Flash)->
  $scope.flash = Flash
```

Now we can inject `Flash` and display a message anywhere in the app that needs it, let's display "Sending..." from the send function and clear it after 1 second.

```coffee
app.controller 'ComposeController', ($rootScope, $scope, Flash)->
  ...
  $scope.send = ->
    $scope.visible = false
    Flash.message = 'Sending...'
    setTimeout ->
      Flash.message = ''
    , 1000
```

This displayed our message perfectly but the message never goes away.. WTF

Code within `setTimeout` won't cause changes to scopes unless you explicitly call `$scope.apply()` - it's safer just to replace setTimeout with Angular's `$timeout` which behaves as you'd expect.

```coffee
app.controller 'ComposeController', ($rootScope, $scope, Flash, $timeout)->
  ...
  $timeout ->
    Flash.message = ''
  , 1000
```

Now it displays the message and clears itself after a second, Nice.

The completed compose view looks this, we've added `ng-model` to our inputs, conditionally displayed sections depending on the active one, you can see how that's wired up below.

```html
<div id="compose" ng-controller="ComposeController" ng-show="visible">
  <div class="header">
    <a class="close" ng-click="close()">&times;</a>
    <h2>New Message</h2>
  </div>
  <div>
    <div ng-hide="active_section == 'to'">
      <input placeholder="Recipients" name="recipients" class="full" ng-focus="active_section = 'to'" ng-model="message.to">
    </div>
    <div ng-show="active_section == 'to'">
      <div class="input" ng-show="active_section == 'to'">
        <label for="message_to">To</label>
        <div class="fit">
          <input id="message_to" class="full" ng-model="message.to">
        </div>
      </div>
      <div class="input" ng-show="cc_active">
        <label for="message_cc">Cc</label>
        <div class="fit">
          <input id="message_cc" class="full" ng-model="message.cc">
        </div>
      </div>
      <div class="input" ng-show="bcc_active">
        <label for="message_bcc">Bcc</label>
        <div class="fit">
          <input for="message_bcc" class="full" ng-model="message.bcc">
        </div>
      </div>
      <div>
        <label>From</label>
        <a href class="bcc" ng-click="bcc_active = true" ng-hide="bcc_active">Bcc</a>
        <a href class="cc" ng-click="cc_active = true" ng-hide="cc_active">Cc</a>
        <drop-down class="drop-down from-address">
          <span>{{ message.from | nameAndEmail }}</span>
          <img src="images/icons/down.png">
          <ul class="align-right">
            <li ng-repeat="account in current_user.accounts"><a href ng-click="message.from = account">{{ account | nameAndEmail }}</a></li>
          </ul>
        </drop-down>
      </div>
    </div>
  </div>
  <div>
    <input id="message_subject" placeholder="Subject" class="full" ng-model="message.subject" ng-focus="active_section = 'subject'">
  </div>
  <div>
    <textarea id="message_body" placeholder="Body" ng-model="message.body" ng-focus="active_section = 'body'"></textarea>
  </div>
  <div class="footer">
    <input type="submit" value="Send" class="btn primary-btn" ng-click="send()">
  </div>
</div>
```

This view uses a new filter called `nameAndEmail` for formatting this common string.

*filters.coffee*

```coffee
app.filter 'nameAndEmail', ->
  (person)->
    "#{ person.first_name } #{ person.last_name } <#{ person.email }>"
```

We also need to reset the message whenever the controller is closed

*controllers.coffee*

```coffee
app.controller 'ComposeController', ($rootScope, $scope, Flash, $timeout)->
  reset = ->
    $scope.visible = false
    $scope.cc_active = false
    $scope.bcc_active = false
    $scope.active_section = null
    $scope.message =
      from: currentUser.accounts[0]

  reset()

  $rootScope.$on 'composeMessage', ->
    $scope.visible = true
    $scope.active_section = 'to'

  $scope.close = ->
    reset()

  $scope.send = ->
    reset()

    Flash.message = 'Sending...'
    $timeout ->
      Flash.message = ''
    , 1000
```

The final touch will be controlling input focus, we'll set focus on the to field when it launches and focus on the cc and bcc fields when they're enabled with a a new directive focusWhen.  It watches if the passed in expressions value changes, when it produces a truthy value we'll focus our element.

*directives.coffee*

```coffee
app.directive 'focusWhen', ($timeout)->
  link: (scope, element, attrs)->
    scope.$watch attrs.focusWhen, (value)->
      return unless value
      $timeout ->
        element[0].focus()
```

Then we can pass in an expression that states when our inputs should gain focus, easy!

```html
<input id="message_to" class="full" ng-model="message.to" focus-when="active_section == 'to'">
<input id="message_cc" class="full" ng-model="message.cc" focus-when="cc_active">
<input for="message_bcc" class="full" ng-model="message.bcc" focus-when="bcc_active">
```

This concludes our exploration of some of Angular's most important concepts and features.

**A note on compression**

Angular's Dependency Injection API is a bit whack.. code like we've been writing below will explode when uglified because Angular uses the name of these arguments to find out which dependency to inject. Ouch.

```js
app.controller('ThreadController', function($scope, $routeParams, Thread) {

});
```

The solution is to add a sweaty armpit of doubled up names and arguments.  This is shit but it's the recommended way to do dependency injection.

```js
app.controller('ThreadController', ['$scope', '$routeParams', 'Thread', function($scope, $routeParams, Thread) {

}]);
```

## Closing

I've enjoyed learning Angular far more than I thought I would, it will be interesting to see how it feels as the complexity grows.

As we build out an app like this further we'd need to organise the code into related modules - everything so far we've whacked on the app module, a fully fledged Gmail application would have separate modules for any distinct components like Notifications, Settings, Chat etc..

I'm finding the views automatic bindings to the underlying data particularly nice, the core components of modules, controllers, services, directives and filters are great.  I have certain gripes with the API and wish things could have been named better - nobody mention the `transclude` function! and I'm sure I'll drop a few wtf's when learning the differences between services, factories and providers but there's always things to learn.

Enjoy.
