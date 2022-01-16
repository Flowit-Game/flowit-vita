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
local getLocale = load('getLocale')
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
local reporter = {
  fileNotFound = function(name, stack)
    local report = 'Localization file ' .. name .. ' not found!\n'
    local splitted = split(stack, '\n')
    local separator = '   '
    local tabStack = separator .. table.concat(splitted, separator .. '\n')
    report = report .. tabStack
    return error(report)
  end,
  mustBeATable = function()
    return error('Locale must be a table!')
  end,
  noLanguage = function()
    return error('Locale must have a "language" property!')
  end,
  failedMount = function(name)
    return error('Failed to mount locale "' .. name .. '": locale not found!')
  end,
  notFoundFallback = function()
    return error('Not found fallback locale!')
  end
}
local clean
clean = function(a)
  for name in pairs(a) do
    a[name] = nil
  end
end
local assign
assign = function(a, b)
  for name, value in pairs(b) do
    a[name] = value
  end
end
local private = {
  load = function(self, locale)
    if type(locale) ~= 'table' then
      reporter.mustBeATable()
    end
    locale.language = locale.language or (locale.lang or locale.locale or locale.loc)
    locale.values = locale.values or (locale.values or locale.storage or locale.main or locale.all or { })
    if not (locale.language) then
      reporter.noLanguage()
    end
    self.locales[locale.language] = locale.values
  end,
  mount = function(self, locale)
    clean(self.value)
    assign(self.value, self.locales[locale])
    clean(self.values)
    return assign(self.values, self.locales[locale])
  end
}
local proto = {
  load = function(self, ...)
    local arguments = {
      ...
    }
    for _, argument in pairs(arguments) do
      if type(argument) == 'string' then
        local succ, result = pcall(require, argument)
        if not (succ) then
          reporter.fileNotFound(argument, result)
        end
        argument = result
      end
      if type(argument) == 'table' then
        private.load(self, argument)
      end
    end
  end,
  get = function(self)
    return getLocale()
  end
}
local Localization
Localization = function(...)
  local values = {
    current = nil,
    fallback = 'en',
    locales = { },
    value = { },
    values = { }
  }
  local self = setmetatable({ }, {
    __index = function(t, k)
      if proto[k] then
        return proto[k]
      elseif values[k] then
        return values[k]
      end
    end,
    __newindex = function(_, k, v)
      if k == 'current' then
        values.current = v
        if values.locales[values.current] then
          return private.mount(values, values.current)
        elseif not values.locales[values.fallback] then
          return reporter.notFoundFallback()
        else
          return private.mount(values, values.fallback)
        end
      else
        values[k] = v
      end
    end
  })
  self:load(...)
  return self
end
local loc = {
  new = Localization,
  get = getLocale
}
return loc
