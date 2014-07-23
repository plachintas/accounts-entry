
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
      if Meteor.userId()
        Router.go AccountsEntry.settings.dashboardRoute

      Session.set('entryError', undefined)
      Session.set('buttonText', 'in')
      Session.set('fromWhere', Router.current().path)

      applyCustomTemplate('signIn').apply(@)

  @route "entrySignUp",
    path: "/sign-up"
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('buttonText', 'up')

      applyCustomTemplate('signUp').apply(@)

  @route "entryForgotPassword",
    path: "/forgot-password"
    onBeforeAction: ->
      Session.set('entryError', undefined)

      applyCustomTemplate('forgotPassword').apply(@)

  @route 'entrySignOut',
    path: '/sign-out'
    onBeforeAction: (pause)->
      Session.set('entryError', undefined)
      if AccountsEntry.settings.homeRoute
        Meteor.logout () ->
          AccountsEntry.settings.onLogout?()
          Router.go AccountsEntry.settings.homeRoute
      pause()

  @route 'entryResetPassword',
    path: 'reset-password/:resetToken'
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('resetToken', @params.resetToken)

      applyCustomTemplate('resetPassword').apply(@)
