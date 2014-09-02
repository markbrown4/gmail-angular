
app.filter 'smartDate', ($filter)->
  $dateFilter = $filter('date')

  (date)->
    oneDayAgo = Date.now() - 86400000
    if date < oneDayAgo
      $dateFilter(date, "MMM dd")
    else
      $dateFilter(date, "h:mm a")


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

app.filter 'smartName', ->
  (person, fullName=true)->
    if currentUser.email == person.email
      'me'
    else if fullName
      "#{person.first_name} #{person.last_name}".trim()
    else
      person.first_name

app.filter 'nameAndEmail', ->
  (person)->
    "#{ person.first_name } #{ person.last_name } <#{ person.email }>"
