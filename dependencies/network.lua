--
-- User: Glastis
-- Mail: glastis@glastis.com
-- Date: 12/09/19
-- Time: 11:43
--

local network = {}

local curl = require 'cURL'
local curl_data = {}

local function request(url, headers)
    curl.easy {
        url = url,
        httpheader = headers,
        ssl_verifypeer = false,
        ssl_verifyhost = false,
        verbose = false,
        writefunction = function(data, size, n)
            curl_data.data = data
            curl_data.size = size
        end
    }
    :perform()
    :close()
    return curl_data.data
end
network.request = request

return network