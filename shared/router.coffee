
applyCustomTemplate = (templateName) ->
  ->
    if AccountsEntry.settings["#{templateName}Template"]
      @template = AccountsEntry.settings["#{templateName}Template"]
      pkgTemplateName = "entry#{templateName.capitalize()}"

      # If the user has a custom template, and not using the helper, then
      # maintain the package Javascript so that OpenGraph tags and share
      # buttons still work.
      pkgRendered= Template[pkgTemplateName].rendered
      userRendered = Template[@template].rendered

      if userRendered
        Template[@template].rendered = ->
          pkgRendered.call(@)
          userRendered.call(@)
      else
        Template[@template].rendered = pkgRendered

      Template[@template].events(AccountsEntry["#{pkgTemplateName}Events"])
      Template[@template].helpers(AccountsEntry["#{pkgTemplateName}Helpers"])


Router.map ->

  @route "entrySignIn",
    path: "/sign-in"
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('buttonText', 'in')
      Session.set('fromWhere', Router.current().path)
    onRun: ->
      if Meteor.userId()
        Router.go AccountsEntry.settings.dashboardRoute

      applyCustomTemplate('signIn').apply(@)


  @route "entrySignUp",
    path: "/sign-up"
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('buttonText', 'up')
    onRun: applyCustomTemplate('signUp')

  @route "entryForgotPassword",
    path: "/forgot-password"
    onBeforeAction: ->
      Session.set('entryError', undefined)
    onRun: applyCustomTemplate('forgotPassword')

  @route 'entrySignOut',
    path: '/sign-out'
    onBeforeAction: (pause)->
      Session.set('entryError', undefined)
      if AccountsEntry.settings.homeRoute
        Meteor.logout () ->
          Router.go AccountsEntry.settings.homeRoute
      pause()

  @route 'entryResetPassword',
    path: 'reset-password/:resetToken'
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('resetToken', @params.resetToken)
    onRun: applyCustomTemplate('resetPassword')
