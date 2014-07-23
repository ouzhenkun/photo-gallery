'use strict'

angular.module('photo-gallery', [
    'ui.bootstrap'
    'ngRoute'
])

.config ($routeProvider, $locationProvider) ->
    $routeProvider
        .when('/home',  {templateUrl: '/partials/home.html'})

    $locationProvider.html5Mode(true)

.controller 'AppCtrl', (
    $scope
    $modal
) ->

    _.extend $scope,
        loggedIn: false

        login: ->
           modalInstance = $modal.open(
              backdrop    : false
              controller  : 'LoginCtrl'
              templateUrl : '/partials/login.html'
            )

        register: ->
            console.debug "register..."

        logout: ->
            console.debug "logout..."

.controller 'LoginCtrl', (
    $scope
    $http
    $modalInstance
) ->

    _.extend $scope,
        state   : 'init' #init, loggingIn, error
        username: ''
        password: ''

        login: ->
            @state = 'loggingIn'
            $http(
                method: 'POST'
                url: "/authenticate/login"
                params: {username: @username, password: @password}
            ).success((data) =>
                $modalInstance.close()
            ).error((error) =>
                @state = 'error'
            )

        cancel: ->
            $modalInstance.dismiss('cancel')

