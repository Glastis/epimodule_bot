--
-- User: Glastis
-- Mail: glastis@glastis.com
-- Date: 12/09/19
-- Time: 11:16
--

local net = require 'dependencies.network'
local utilitie = require 'dependencies.utilities'
local constant = require 'constants'

function get_modules_suscribed(module)
    local i
    local tmp
    local ret

    i = 1
    ret = {}
    while module[i] do
        tmp = utilitie.split(module[i], constant.SEPARATOR_LINK_SUSCRIBED)
        ret[i] = {}
        ret[i].link = tmp[1]
        if tmp[2] then
            ret[i].suscribed = tonumber(tmp[2])
        else
            ret[i].suscribed = false
        end
        i = i + 1
    end
    return ret
end

function get_modules()
    local modules

    modules = utilitie.read_file(constant.MODULES_FILE)
    modules = utilitie.split(modules, '\n')
    modules = get_modules_suscribed(modules)
    return modules
end

function save_modules(modules)
    local i
    local tmp

    i = 1
    tmp = ''
    while i <= #modules do
        tmp = tmp .. modules[i].link
        if modules[i].suscribed_new then
            tmp = tmp .. constant.SEPARATOR_LINK_SUSCRIBED .. modules[i].suscribed_new .. '\n'
        end
        i = i + 1
    end
    tmp = tmp .. '\n'
    utilitie.write_to_file(constant.MODULES_FILE, tmp, 'w')
end

function refresh_suscribed_module(url, token)
    local headers
    local ret

    headers = {}
    headers[1] = constant.COOKIES .. token

    utilitie.var_dump(url, true)
    ret = net.request(url .. constant.URL_ADD_FORMAT_JSON, headers)
    print(ret)
end

function refresh_suscribed(modules, token)
    local i

    i = 1
    while i <= #modules do
        modules[i].suscribed_new = refresh_suscribed_module(modules[i].link, token)
        if not modules[i].suscribed_new then
            modules[i].suscribed_new = modules[i].suscribed
        end
        i = i + 1
    end
end

function main()
    local token
    local modules

    token = utilitie.read_file(constant.TOKEN_FILE)
    modules = get_modules()
    refresh_suscribed(modules, token)
    utilitie.var_dump({modules, token}, true)
    save_modules(modules)
end

main()