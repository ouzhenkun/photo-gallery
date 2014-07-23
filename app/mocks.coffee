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

.run ($httpBackend) ->

    console.debug "running... dev"

    $httpBackend.whenPOST(/authenticate\/login/).respond (method, url, data) ->
        console.debug "post login...#{url}"
        [200]

    $httpBackend.whenGET(/.*/).passThrough()
