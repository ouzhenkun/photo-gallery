'use strict'

angular.module('photo-gallery', [
    'ui.bootstrap'
    'directives'
    'session'
    'ngRoute'
    'login'
    'home'
])

.config ($routeProvider, $locationProvider) ->
    $routeProvider
        .when('/home',  {templateUrl: '/partials/home.html', auth: true})

    $locationProvider.html5Mode(true)

.controller 'AppCtrl', ($scope, $http, $rootScope, $modal, Session, Photo) ->

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

        upload: ->
            $http.get("/photos/token").success (token) ->
                console.debug "TODO upload photo with token: #{token}"

            newPhoto = _.extend new Photo,
                id   : 'new'
                text : 'New Photo'
            newPhoto.$save (newPhoto) ->
                $rootScope.$broadcast 'currentPhotosUpdated', newPhoto

