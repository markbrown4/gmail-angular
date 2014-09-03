
app.factory 'Flash', ->
  message: ''

app.factory 'Thread', ($resource)->
  $resource '/api/threads/:id.json', { id: 'index' }
