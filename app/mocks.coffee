'use strict'

# 封装主App，用 ngMockE2E 模拟其中的服务器请求
angular.module('photo-gallery-dev', [
    'photo-gallery'
    'ngMockE2E'
])

# 存取 Json 格式信息到 localStorage
.factory '$localStorage', ->
    set: (key, value) -> window.localStorage?[key] = JSON.stringify(value)
    get: (key)        -> JSON.parse(localStorage?[key] ? null)

# TODO 整合 qiniu 云
.service 'QiniuService', ->
    genDownPhoto: (photo) ->
        id  : photo.id
        text: photo.text
        url : "http://placekitten.com/#{600+photo.id}/300"
    genUpToken: (filename) ->
        accessKey = '57r8ikBR1yNeWVLbe3NbjupXZI3Ihxi7ecPwhBF5'
        secretKey = 'ndh92aY38OB8uoCCKfImKuetQ-WPbel1XbmU6piK'
        putPolicy =
            scope: "public-cloud3edu:#{filename}"
            deadline: 1451491200
        put_policy = JSON.stringify(putPolicy)
        encoded = base64encode(utf16to8(put_policy))
        hash = CryptoJS.HmacSHA1(encoded, secretKey)
        encoded_signed = hash.toString(CryptoJS.enc.Base64)
        upload_token = accessKey + ":" + safe64(encoded_signed) + ":" + encoded
        upload_token

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
    QiniuService
    $httpBackend
    $localStorage
) ->

    console.debug "Start Mock HttpBackend ..."

    # 设置初始数据给 $localstorage
    defaultUsers = [
        {username: 'ryan', password: '123'}
        {username: 'test', password: '123'}
    ]
    defaultPhotos = [
        {username: 'ryan', text: 'Photo 1', id:0}
        {username: 'ryan', text: 'Photo 2', id:1}
        {username: 'test', text: 'Photo 3', id:2}
        {username: 'test', text: 'Photo 4', id:3}
    ]
    $localStorage.set("db.users" , defaultUsers)  if !$localStorage.get("db.users")?
    $localStorage.set("db.photos", defaultPhotos) if !$localStorage.get("db.photos")?

    # 将 url 中的 queryString 转换成 paramsObject
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

    # 模拟 获取上传凭证-服务端
    $httpBackend.whenGET("/upload/token").respond (method, url, data) ->
        console.debug "get token: #{url}"

        currentUser = $localStorage.get('cookies.user')
        if currentUser?
            [200, QiniuService.genUpToken(currentUser.username+"-"+Date.now())]
        else
            [401]

    # 模拟 获取用户相册-服务端
    $httpBackend.whenGET(/photos\/all/).respond (method, url, data) ->
        console.debug "get photos: #{url}"
        currentUser = $localStorage.get('cookies.user')

        photos = _.chain($localStorage.get('db.photos'))
                  .filter((photo) -> photo.username == currentUser.username)
                  .map(QiniuService.genDownPhoto)
                  .value()
        console.dir photos
        [200, photos]

    # 模拟 保存用户相册-服务端
    $httpBackend.whenPOST("/photos/new").respond (method, url, data) ->
        console.debug "post new photo #{url}"
        params = JSON.parse(data)
        # save new photo
        currentUser = $localStorage.get('cookies.user')
        dbPhotos    = $localStorage.get('db.photos')
        newPhoto =
            id       : dbPhotos.length + 1
            text     : params.text
            username : currentUser.username
        dbPhotos.push newPhoto
        $localStorage.set('db.photos', dbPhotos)

        [200, QiniuService.genDownPhoto(newPhoto)]

    $httpBackend.whenGET(/.*/).passThrough()
