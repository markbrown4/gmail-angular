
app.factory 'AppState', ->
  composing: false
  flash: ''

app.factory 'Thread', ($resource)->
  $resource '/api/threads/:id.json', {},
    query:
      method: 'GET'
      params: { id: 'index' }
      isArray: true
