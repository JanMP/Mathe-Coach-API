import { Accounts } from "meteor/accounts-base"

if Meteor.isServer

  Accounts.urls.resetPassword = (token) ->
    Meteor.absoluteUrl "password-reset/#{token}"
  Accounts.urls.verifyEmail = (token) ->
    Meteor.absoluteUrl "email-verifizieren/#{token}"

  Accounts.onCreateUser (options, user) ->
    console.log {options, user}
    user.profile ?= {}
    user.profile.firstName = options.firstName
    user.profile.lastName = options.lastName
    user.language = options.language
    user.schoolClassId = options.schoolClassId
    user

  Accounts.emailTemplates = {
    Accounts.emailTemplates...,
    from : "no-reply@mathe-coach-rivius.herokuapp.com"
    verifyEmail :
      subject : (user) -> "Willkommen bei MatheCoach"
      text : (user, link) ->
        """
          Hallo #{user?.profile?.firstName ? ''}
          Du hast dich mit dieser Email unter dem Benutzernamen #{user.username} auf unserer Übungsseite für Mathematikaufgaben eingetragen.
          Diese Email ist notwendig um dein Passwort zu ändern, falls Du es mal vergessen solltest. Damit wir sicher sein können, dass wir auch wirklich die richtige Addresse haben, bestätige bitte die Email mit dem folgenden Link:

          #{link}

          Vielen Dank und viel Spass mit MatheCoach
        """
    resetPassword :
      subject : (user) -> "MatheCoach: Passwort zurücksetzen"
      text : (user, link) ->
        """
          Hallo #{user?.profile?.firstName ? ''}
          Du hast auf unserer Übungsseite für Mathematikaufgaben ein neuesPasswort angefordert. Um das Passwort zurückzusetzen klicke bitte auf den folgenden Link:

            #{link}

          Vielen Dank und viel Spass mit MatheCoach
        """
  }

  Accounts.config
    sendVerificationEmail : true
