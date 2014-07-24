'use strict'

angular.module('login', [])

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
                $rootScope.$broadcast 'currentUserUpdated', user
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
                $rootScope.$broadcast 'currentUserUpdated', newUser
                $modalInstance.close()
            ).error((error) =>
                @processing = false
                @error = error
            )

        removeError: ->
            @error = undefined

        cancel: ->
            $modalInstance.dismiss('cancel')
