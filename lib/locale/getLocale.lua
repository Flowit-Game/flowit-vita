local current = (...)
local load
load = function(path)
  local succ, loaded = pcall(require, path)
  if not (succ) then
    local LC_PATH = current .. '.' .. path
    succ, loaded = pcall(require, LC_PATH)
    if not (succ) then
      LC_PATH = current:gsub("%.[^%..]+$", "") .. '.' .. path
      succ, loaded = pcall(require, LC_PATH)
      if not (succ) then
        error(loaded)
      end
    end
  end
  return loaded
end
local codes = load('localeCodes')
local exec
exec = function(command)
  local handle = assert(io.popen(command))
  local result = handle:read('*all')
  handle:close()
  return result
end
local split
split = function(input, separator)
  if separator == nil then
    separator = "%s"
  end
  local t = { }
  local i = 1
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end
local shortLocale
shortLocale = function(loc)
  --loc = loc:gsub('_.+$', '') -- en_US.UTF8 -> en
  loc = loc:gsub('%..+$', '') -- en_US.UTF8 -> en_US
  return loc
end
local getters = {
  linux = function(x)
    x = exec('locale')
    local splitted = split(x, '\n')
    local env = { }
    for _, d in pairs(splitted) do
      d = split(d, '=')
      local g = ""
      pcall(function()
        g = d[2]:gsub('"', '')
        env[d[1]] = g
      end)
    end
    local loc = env.LC_ALL or env.LC_MESSAGES or env.LANG or env.LANGUAGE
    return shortLocale(loc)
  end,
  android = function()
    return shortLocale(exec('getprop persist.sys.language'))
  end,
  windows = function()
    local wmic = exec('wmic get os locale')
    local codeString = wmic:gsub('Locale', '')
    local code = tonumber(codeString, 16)
    local loc = codes[code]
    return shortLocale(loc)
  end,
  osx = function()
    return shortLocale(exec('defaults read -g AppleLocal'))
  end,
  ios = function()
    return shortLocale(exec('defaults read -g AppleLocal'))
  end
}
local cache
local getLocale
getLocale = function(fallback)
  if cache then
    return cache
  end
  local platform
  if love and love.system and love.system.getOS then
    platform = love.system.getOS()
  else
    error('Locale detection currently works only in LÖVE!')
  end
  local _exp_0 = platform
  if "Linux" == _exp_0 then
    cache = getters.linux()
  elseif "Android" == _exp_0 then
    cache = getters.android()
  elseif "OS X" == _exp_0 then
    cache = getters.osx()
  elseif "Windows" == _exp_0 then
    cache = getters.windows()
  elseif "iOS" == _exp_0 then
    cache = getters.ios()
  else
    cache = fallback
  end
  return cache
end
return getLocale
