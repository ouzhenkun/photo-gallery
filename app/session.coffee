'use strict'

angular.module('session', [])

.factory 'Session', ($http, $route, $location, $rootScope) ->
    service =
        getCurrentUser: -> angular.copy @currentUser
        setCurrentUser: (user) -> @currentUser = user
        isAuthenticated: -> @currentUser?

        setup: ->
            if !@currentUser?
                $http.get("/authenticate/user").success (user) ->
                    $rootScope.$broadcast 'currentUserUpdated', user
        logout: ->
            $http.get("/authenticate/logout").success ->
                $rootScope.$broadcast 'currentUserUpdated', null

    gotoDefaultPath = (auth) ->
        if !auth && service.isAuthenticated()
            $location.path "/home"
        else if auth && !service.isAuthenticated()
            $location.path "/"

    $rootScope.$on 'currentUserUpdated', (event, user) ->
        service.setCurrentUser user
        gotoDefaultPath($route?.current?.auth)

    $rootScope.$on '$routeChangeSuccess', (event, current) -> _.defer ->
        gotoDefaultPath(current?.auth)

    service



