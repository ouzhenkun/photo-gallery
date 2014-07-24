'use strict'

angular.module('home', ['ngResource'])

.factory 'Photo', ($resource) ->
    $resource '/photos/:id', {id: '@id'}

.controller 'HomeCtrl', ($scope, Photo, $rootScope) ->

    _.extend $scope,
        interval : 3000
        photos   : Photo.query id:'all'

    $rootScope.$on 'currentPhotosUpdated', (event, newPhoto) ->
        $scope.photos.push newPhoto

