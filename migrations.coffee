Migrations.add
  version : 1
  up : ->
    Meteor.users.find
      lastActive :
        $exists : false
      "profile.lastActive" :
        $exists : true
    .forEach (user) ->
      console.log "copying lastActive for user #{user._id}"
      Meteor.users.update _id : user._id,
        $set :
          lastActive : user.profile.lastActive
    Meteor.users.find
      schoolClassId :
        $exists : false
      "profile.schoolClassId" :
        $exists : true
    .forEach (user) ->
      console.log "copying schoolClassId for user #{user._id}"
      Meteor.users.update _id : user._id,
        $set :
          schoolClassId : user.profile.schoolClassId
    Meteor.users.find
      useKaTeX :
        $exists : false
      "profile.useKaTeX" :
        $exists : true
    .forEach (user) ->
      console.log "copying schoolClassId for user #{user._id}"
      Meteor.users.update _id : user._id,
        $set :
          useKaTeX : user.profile.useKaTeX
