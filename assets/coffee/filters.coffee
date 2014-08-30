
app.filter 'smartDate', ($filter)->
  $dateFilter = $filter('date')

  (input)->
    oneDayAgo = Date.now() - 86400000
    if input < oneDayAgo
      $dateFilter(input, "MMM dd")
    else
      $dateFilter(input, "h:mm a")

app.filter 'smartName', ->
  (person, fullName=false)->
    if currentUser.email == person.email
      'me'
    else if fullName
      "#{person.first_name} #{person.last_name}".trim()
    else
      person.first_name
