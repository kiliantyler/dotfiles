function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
style = {
    strokeWidth  = 1,
    strokeColor = { white = 1, alpha = 1 },
    fillColor   = { white = 0, alpha = 0.75 },
    textColor = { white = 1, alpha = 1 },
    textFont  = ".AppleSystemUIFont",
    textSize  = 27,
    radius = 27,
    atScreenEdge = 1,
    fadeInDuration = 0.15,
    fadeOutDuration = 0.15,
    padding = 30,
}
hs.alert.show("HS: Config loaded", style)
