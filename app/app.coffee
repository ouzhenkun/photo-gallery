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
              templateUrl : '/partials/login.html'
              controller  : 'LoginCtrl'
            )

        register: ->
            console.debug "register..."

        logout: ->
            console.debug "logout..."

.controller 'LoginCtrl', (
    $scope
    $modalInstance
) ->

    _.extend $scope,
        username: ''
        password: ''

        login: ->
            console.debug "login...#{@username}, #{@password}"
            $modalInstance.close()

        cancel: ->
            $modalInstance.dismiss('cancel')

.run () ->
    console.debug "running..."

