import { Submissions } from "./submissions.coffee"

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

Migrations.add
  version : 2
  up : ->
    Submissions.find()
    .forEach (submission) ->
      Submissions.update _id : submission._id,
        $set :
          problemTeX : submission.problem

Migrations.add
  version : 3
  up : ->
    changed = 0
    Submissions.find()
    .forEach (submission) ->
      if submission.SVGData?
        changed += 1
        Submissions.update _id : submission._id,
          $set :
            geometryDrawData : submission.SVGData
      if submission.functionData?
        changed += 1
        Submissions.update _id : submission._id,
          $set :
            functionPlotData : submission.functionData
    console.log "#{changed} entries changed"
