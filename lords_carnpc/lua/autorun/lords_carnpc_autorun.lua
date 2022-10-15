LCarNPC = LCarNPC or {}
hook.Add("PIXEL.UI.FullyLoaded", "LCarNPC:Load", function()
    PIXEL.LoadDirectoryRecursive("lords_carnpc")
end)