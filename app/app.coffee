'use strict'

angular.module('photo-gallery', [
    'ui.bootstrap'
    'ngRoute'
])

.config ($routeProvider, $locationProvider) ->
    $routeProvider
        .when('/home',  {templateUrl: '/partials/home.html', auth: true})

    $locationProvider.html5Mode(true)


.factory '$localStorage', ->
    set: (key, value) -> window.localStorage?[key] = JSON.stringify(value)
    get: (key)        -> JSON.parse(localStorage?[key] || null)


.factory 'Session', ($http, $route, $location, $rootScope) ->
    service =
        getCurrentUser: -> angular.copy @currentUser
        setCurrentUser: (user) -> @currentUser = user
        isAuthenticated: -> @currentUser?

        setup: ->
            if !@currentUser?
                $http.get("/authenticate/user").success (user) ->
                    console.debug user
                    $rootScope.$broadcast 'auth:currentUserUpdated', user
        logout: ->
            $http.get("/authenticate/logout").success ->
                $rootScope.$broadcast 'auth:currentUserUpdated', null

    gotoDefaultPath = (auth) ->
        if !auth && service.isAuthenticated()
            $location.path "/home"
        else if auth && !service.isAuthenticated()
            $location.path "/"

    $rootScope.$on 'auth:currentUserUpdated', (event, user) ->
        service.setCurrentUser user
        gotoDefaultPath($route?.current?.auth)

    $rootScope.$on '$routeChangeSuccess', (event, current) -> _.defer ->
        gotoDefaultPath(current?.auth)

    service


.controller 'AppCtrl', ($scope, $modal, Session) ->

    Session.setup()

    _.extend $scope,
        session: Session
        login: ->
           modalInstance = $modal.open(
              backdrop    : false
              controller  : 'LoginCtrl'
              templateUrl : '/partials/login.html'
            )

        register: ->
           modalInstance = $modal.open(
              backdrop    : false
              controller  : 'LoginCtrl'
              templateUrl : '/partials/register.html'
            )

.controller 'LoginCtrl', ($scope, $http, $rootScope, $modalInstance) ->

    _.extend $scope,
        username   : undefined
        password   : undefined
        confirmPWD : undefined

        processing : false
        error      : undefined

        login: ->
            @removeError()
            @processing = true
            $http(
                method: 'POST'
                url: "/authenticate/login"
                params: {username: @username, password: @password}
            ).success((user) =>
                $rootScope.$broadcast 'auth:currentUserUpdated', user
                $modalInstance.close()
            ).error((error) =>
                @processing = false
                @error = error
            )

        register: ->
            @removeError()
            @processing = true
            $http(
                method: 'POST'
                url: "/authenticate/register"
                params: {username: @username, password: @password, confirmPWD: @confirmPWD}
            ).success((newUser) =>
                $rootScope.$broadcast 'auth:currentUserUpdated', newUser
                $modalInstance.close()
            ).error((error) =>
                @processing = false
                @error = error
            )

        removeError: ->
            @error = undefined

        cancel: ->
            $modalInstance.dismiss('cancel')

.directive 'ngEnter', ->
    (scope, element, attrs) ->
        element.bind "keydown keypress", (event) ->
            if event.which == 13
                scope.$apply(-> scope.$eval(attrs.ngEnter))
                event.preventDefault()

