.pragma library

function serializeParams(object, prefix) {
    if (typeof object !== 'object') {
        return ''
    }

    if (!prefix) {
        prefix = ''
    }

    var output = []
    var keysArray = (Array.isArray(object) ? object : Object.keys(object))
    for (var i = 0; i < keysArray.length; i++) {
        var key = (Array.isArray(object) ? i : keysArray[i])
        if (typeof object[key] === 'object') {
            output.push(serializeParams(object[key], (!prefix ? key : '%1[%2]'.arg(prefix).arg(key))))
        } else {
            output.push('%1=%2'.arg(encodeURIComponent(!prefix ? key : '%1[%2]'.arg(prefix).arg(Array.isArray(object) ? '' : key)))
                        .arg(encodeURIComponent(object[key])))
        }
    }

    return output.join('&').replace('%20', '+')
}

function parseParams(url) {
    if (typeof url !== 'string') {
        return null
    }

    var result = {}
    var queries = url.replace(/[?#]/g, '&').replace(/^[^&]*?&/, '').replace(/[+]/g, '%20').split(/[&;]/)
    for (var i = 0; i < queries.length; i++) {
        var params = queries[i].split('=')
        result[decodeURIComponent(params[0])] = decodeURIComponent(params[1])
    }

    return result
}
