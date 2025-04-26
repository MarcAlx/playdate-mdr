--[[
    Add in this file all needed lua function
]]

--To create constant
function protect(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function(t, key, value)
            error("attempting to change constant " ..
                   tostring(key) .. " to " .. tostring(value), 2)
        end
    })
end

--[[
    dump table

    @see https://stackoverflow.com/a/27028488
]]
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

--returns a table with the keys of a given input table, doesn't work on 'protect'ed tables
function keys(t)
    local keys={}
    for key,_ in pairs(t) do
      table.insert(keys, key)
    end
    return keys
end

--return a random value from an array
function pickRandom(arr)
    return arr[math.random(1,#arr)]
end

--return key for first found value in an array
function getKeyForValue(arr,val)
    for k,v in pairs(arr) do
        if(v == val) then
            return k
        end
    end
    return nil
end

--true if table tab contains val
function contains(tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

--true if table tab contains key key
function containsKey(tab, key)
    for index, value in pairs(tab) do
        if index == key then
            return true
        end
    end
    return false
end