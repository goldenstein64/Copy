return {

  KeySelect = function(Copy)
    local key = newproxy(false)
    local someTable = {
      [key] = "value"
    }

    Copy.Flags.Flush = false
    Copy.Flags.CopyKeys = false
    Copy:QueueDelete(key)
    Copy:QueueForce(key)
    local newTable = Copy(someTable)
    local newKey = Copy.Transform[key]

    assert(newKey ~= key)
    assert(newTable[newKey] == "value")
  end,

  MetaSelect = function(Copy)
    local meta = {}
    local someTable = setmetatable({}, meta)

    Copy.Flags.Flush = false
    Copy.Flags.CopyMeta = false
    Copy:QueueDelete(meta)
    Copy:QueueForce(meta)
    local newTable = Copy(someTable)
    local newMeta = Copy.Transform[meta]

    assert(newMeta == nil)
    assert(getmetatable(newTable) == nil)
  end,

}