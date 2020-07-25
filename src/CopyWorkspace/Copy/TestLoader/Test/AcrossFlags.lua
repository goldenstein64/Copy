return {

  CopyKeysOn = function(Copy)
    local key = newproxy(false)
    local otherKey = newproxy(false)
    local someTable = {
      [key] = "value"
    }
    local otherTable = {
      [otherKey] = "other value"
    }

    Copy.Flags.Flush = false
    Copy.Flags.CopyKeys = true
    Copy:Across(otherTable, someTable)
    local newKey = Copy.Transform[key]

    assert(newKey ~= key)
    assert(otherTable[newKey] == "other value")
  end,
  CopyKeysOff = function(Copy)
    local key, otherKey = newproxy(false), newproxy(false)
    local someTable = {
      [key] = "value"
    }
    local otherTable = {
      [otherKey] = "other value"
    }

    Copy.Flags.CopyKeys = false
    Copy:Across(otherTable, someTable)
    
    assert(otherTable[key] == "value")
  end,

  CopyMetaOn = function(Copy)
    local meta, otherMeta = {}, {}
    local someTable = setmetatable({}, meta)
    local otherTable = setmetatable({}, otherMeta)

    Copy.Flags.Flush = false
    Copy.Flags.CopyMeta = true
    Copy:Across(otherTable, someTable)
    local newMeta = Copy.Transform[meta]

    assert(newMeta ~= meta)
    assert(getmetatable(otherTable) == newMeta)

  end,
  CopyMetaOff = function(Copy)
    local meta, otherMeta = {}, {}
    local someTable = setmetatable({}, meta)
    local otherTable = setmetatable({}, otherMeta)

    Copy.Flags.CopyMeta = false
    Copy:Across(otherTable, someTable)
    
    assert(getmetatable(otherTable) == meta)
  end,

}