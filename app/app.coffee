'use strict'

angular.module('app', [
    'ngRoute'
])

.config ($routeProvider, $locationProvider) ->
    $routeProvider
        .when('/login', {templateUrl: '/partials/login.html'})
        .when('/home',  {templateUrl: '/partials/home.html'})
        .otherwise({redirectTo: '/'})

    $locationProvider.html5Mode(true)

