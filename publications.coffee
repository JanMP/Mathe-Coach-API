{ Submissions } = require "/imports/api/submissions.coffee"
{ SchoolClasses } = require "/imports/api/schoolClasses.coffee"
{ ChatMessages } = require "/imports/api/chatMessages.coffee"
{ ActivityGraphs } = require "/imports/api/activityGraphs.coffee"
{ Scores } = require "/imports/api/scores.coffee"
import SimpleSchema from "simpl-schema"

if Meteor.isServer
  Meteor.publish "userOwnData", ->
    if @userId
      Meteor.users.find _id : @userId
    else
      @ready()

  Meteor.publish "userData", ({id}) ->
    new SimpleSchema
      id :
        type : String
    .validate {id}
    cursor = Meteor.users.find _id : id
    user = cursor.fetch()[0]
    unless user?.teacher?()?._id is @userId or Roles.userIsInRole "admin"
      @ready()
    else
      cursor

  Meteor.publishComposite "allUserData", ->
    find : ->
      if Roles.userIsInRole @userId, "admin"
        Meteor.users.find()
      else
        @ready()

  Meteor.publish "teachersData", ->
    Roles.getUsersInRole("mentor")

  Meteor.publish "schoolClasses", ->
    SchoolClasses.find()

  Meteor.publish "schoolClassUsers", ({schoolClassId}) ->
    new SimpleSchema
      schoolClassId :
        type : String
    .validate {schoolClassId}
    schoolClass = SchoolClasses.findOne _id : schoolClassId
    unless schoolClass.teacherId is @userId
      @ready()
    else
      schoolClass.students()

  Meteor.publish "userSubmissions", ({userId, page}) ->
    new SimpleSchema
      userId :
        type : String
      page :
        type : Number
        optional : true
    .validate {userId, page}
    user = Meteor.users.findOne _id : userId
    unless userId is @userId or user?.schoolClass()?.teacherId is @userId
      @ready()
    else
      if page?
        user?.submissionsPage page
      else
        user?.submissions()

  Meteor.publish "userStatistics", ({userId}) ->
    dateFormat ="D-M-Y"
    submissionCount = 0
    obj =
      total : 0
      correct : 0
      incorrect : 0
      byDate : {}
    initializing = true
    handle = Submissions.find({userId}).observeChanges
      added :
        (id, submission) =>
          dk = moment(submission.date).startOf("day").format(dateFormat)
          mk = submission.moduleKey
          lk = "#{submission.level}"
          rk = if submission.answerCorrect then "correct" else "incorrect"
          obj.total += 1
          obj[rk] += 1
          unless obj.byDate[dk]?
            obj.byDate[dk] =
              total : 0
              correct : 0
              incorrect : 0
              byModule : {}
          obj.byDate[dk].total += 1
          obj.byDate[dk][rk] += 1
          unless obj.byDate[dk].byModule[mk]?
            obj.byDate[dk].byModule[mk] =
              total : 0
              correct : 0
              incorrect : 0
              byLevel : {}
          obj.byDate[dk].byModule[mk].total += 1
          obj.byDate[dk].byModule[mk][rk] += 1
          unless obj.byDate[dk].byModule[mk].byLevel[lk]?
            obj.byDate[dk].byModule[mk].byLevel[lk] =
              total : 0
              correct : 0
              incorrect : 0
          obj.byDate[dk].byModule[mk].byLevel[lk].total += 1
          obj.byDate[dk].byModule[mk].byLevel[lk][rk] += 1
          unless initializing
            @changed "userStatistics", userId, {submissionCount, obj}
    initializing = false
    @added "userStatistics", userId, { submissions : obj }
    @ready()
    @onStop -> handle.stop()


  Meteor.publishComposite "schoolClassActivityGraphs", ->
    find : ->
      Meteor.users.find
        _id : @userId
    children : [
      find : (teacher) ->
        SchoolClasses.find teacherId : teacher._id
      children : [
        find : (schoolClass) ->
          ActivityGraphs.find schoolClassId : schoolClass._id
      ]
    ]

  Meteor.publishComposite "chatMessages", ->
    find : ->
      if @userId?
        ChatMessages.find
          $or :
            [
              receiverId : @userId
            ,
              senderId : @userId
            ]
      else
        @ready()

  Meteor.publishComposite "userScores", ->
    find : ->
      if @userId?
        Scores.find userId : @userId
      else
        @ready()
