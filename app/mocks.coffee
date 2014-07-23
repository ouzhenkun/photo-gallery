'use strict'

angular.module('photo-gallery-dev', [
    'photo-gallery'
    'ngMockE2E'
])

# 延迟 $httpbackend 返回结果，模拟服务器请求延时行为
.config ($provide) ->
    $provide.decorator '$httpBackend', ($delegate) ->
        proxy = (method, url, data, callback, headers) ->
            interceptor = ->
                _this = this
                _arguments = arguments
                setTimeout( ->
                    callback.apply(_this, _arguments)
                , 800)
            $delegate.call(this, method, url, data, interceptor, headers)
        for key of $delegate
            proxy[key] = $delegate[key]
        proxy


.run (
    $httpBackend
    $localStorage
) ->

    console.debug "running... dev"

    defaultDBUsers = [
        {username: 'ryan', password: '123'}
        {username: 'test', password: '123'}
    ]
    $localStorage.set("db.users", defaultDBUsers) if !$localStorage.get("db.users")?

    # url 中的 queryString 转换成 paramsObject
    getParams = (url) ->
        RE = /[?&]?([^=]+)=([^&]*)/g
        url = decodeURIComponent(url?.replace(/\+/g, '%20'))
        queryString = url.replace(/.*\?/g, '')
        params = {}
        params[tokens[1]] = tokens[2] while tokens = RE.exec(queryString)
        params

    # 模拟 用户登录-服务端
    $httpBackend.whenPOST(/authenticate\/login/).respond (method, url, data) ->
        console.debug "post login: #{url}"

        params = getParams(url)
        if !params.username? then return [401, "请输入用户名。"]
        if !params.password? then return [401, "请输入登录密码。"]

        dbUser = _.findWhere($localStorage.get('db.users'), {username: params.username, password: params.password})
        if !dbUser? then return [401, "用户名或密码错误。"]

        # 模拟 登录后设置 cookies user
        $localStorage.set('cookies.user', dbUser)
        [200, dbUser]

    # 模拟 注册新用户-服务端
    $httpBackend.whenPOST(/authenticate\/register/).respond (method, url, data) ->
        console.debug "post register: #{url}"

        params = getParams(url)
        if !params.username? then return [401, "请输入用户名。"]
        if !params.password? then return [401, "请输入登录密码。"]
        if !params.confirmPWD? then return [401, "请再次输入登录密码。"]

        exists = _.findWhere($localStorage.get('db.users'), {username: params.username})
        if exists? then return [401, "用户名已被占用。"]

        newUser =
            username: params.username
            password: params.password
        $localStorage.set('db.users', _.union($localStorage.get('db.users'), newUser))

        # 模拟 注册后设置 cookies user
        $localStorage.set('cookies.user', newUser)
        [200, newUser]

    # 模拟 获取当前用户-服务端
    $httpBackend.whenGET(/authenticate\/user/).respond (method, url, data) ->
        currentUser = $localStorage.get('cookies.user')
        console.debug "get current user: #{currentUser}"
        [200, currentUser]

    # 模拟 退出-服务端
    $httpBackend.whenGET(/authenticate\/logout/).respond (method, url, data) ->
        console.debug "logout: #{url}"
        $localStorage.set('cookies.user', null)
        [200]

    $httpBackend.whenGET(/.*/).passThrough()
