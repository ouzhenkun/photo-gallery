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
           modalInstance = $modal.open(
              backdrop    : false
              controller  : 'LoginCtrl'
              templateUrl : '/partials/register.html'
            )

        logout: ->
            console.debug "logout..."

.controller 'LoginCtrl', (
    $scope
    $http
    $modalInstance
) ->

    _.extend $scope,
        username   : ''
        password   : ''
        confirmPWD : ''

        processing : false
        error      : undefined

        #TODO refactor
        login: ->
            @removeError()
            if @username == ''
                @error = "请输入用户名。"
                return
            if @password == ''
                @error = "请输入登录密码。"
                return

            @processing = true
            $http(
                method: 'POST'
                url: "/authenticate/login"
                params: {username: @username, password: @password}
            ).success((data) =>
                $modalInstance.close()
            ).error((error) =>
                @processing = false
                @error = "登录错误。"
            )

        register: ->
            @removeError()
            if @username == ''
                @error = "请输入用户名。"
                return
            if @password == ''
                @error = "请输入登录密码。"
                return
            if @confirmPWD == ''
                @error = "请再次输入登录密码。"
                return
            if @password != @confirmPWD
                @error = "两次输入的密码不一致。"
                return

            @processing = true
            $http(
                method: 'POST'
                url: "/authenticate/register"
                params: {username: @username, password: @password}
            ).success((data) =>
                $modalInstance.close()
            ).error((error) =>
                @processing = false
                @error = "注册错误。"
            )

        removeError: ->
            @error = undefined

        cancel: ->
            $modalInstance.dismiss('cancel')

