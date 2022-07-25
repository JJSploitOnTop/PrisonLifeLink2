-- Global Vars
local ExecutionTime = tick()

local Players = game:GetService("Players")

local Teams = game.Teams

local rService = game:GetService("RunService")

local rStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")

local CoreGui = game:GetService("CoreGui")

local HttpService = game:GetService("HttpService")

local TweenService = game:GetService("TweenService")

local RegionModule = require(game.ReplicatedStorage["Modules_client"]["RegionModule_client"])

local TooltipModule = require(game.ReplicatedStorage.Modules_client.TooltipModule)

local LocalPlayer = Players.LocalPlayer

local Mouse = LocalPlayer:GetMouse()

local scriptversion = "V2 Beta"

-- Load Game:
if not game:IsLoaded() then
    repeat
        task.wait(0.03)
    until game:IsLoaded()
end

-- Script:
local Settings = {Prefix = ".", ToggleGui = "RightControl"}
local ProtectedSettings = {tpcmds = true, killcmds = true, arrestcmds = true, givecmds = true, othercmds = true}
local AdminSettings = {tpcmds = true, killcmds = true, arrestcmds = true, givecmds = true, othercmds = true}
local OpenCommandBarKey = "Period"
local States = {
    AutoRespawn = false,
    AntiCriminal = false,
    AntiBring = false,
    ArrestAura = false,
    AntiFling = false,
    AutoInfiniteAmmo = false,
    AutoAutoFire = false,
    AntiPunch = false,
    MeleeAura = false,
    CombatLogs = false,
    ShootBack = false,
    TaseBack = false,
    FriendlyFire = false,
    PunchAura = false,
    SpamPunch = false,
    OnePunch = false,
    OneShot = false,
    ClickTeleport = false,
    AntiCrash = false,
    FastPunch = false,
    AutoTeamChange = true
}

--// Tables:
local AmmoGuns = {}
local Walls = {}
local SavedWaypoints = {}
local Admins = {}
local Trapped = {}
local CommandQueue = {}
local ChatQueue = {}
local Loopkilling = {}
local Infected = {}
local KillAuras = {}
local LoopTasing = {}
local TaseAuras = {}
local Protected = {}
local WhitelistedItems = {}
local ArmorSpamFlags = {}
local MeleeKilling = {}
local SpeedKilling = {}
local Nukes = {}
local ClickTeleports = {}
local Oneshots = {}
local Onepunch = {}
local AntiShoots = {}
local TaseBacks = {}
local ArrestFlags = {}

local Info = {FriendlyFireOldTeam = LocalPlayer.TeamColor.Name, ExecutionTime = tick(), Bullets = 0}

local PunchFunction
local CurrentlyViewing
local SavedPosition = CFrame.new()
local SavedCameraPosition = CFrame.new()
local Camera = workspace.CurrentCamera
local HasBeenArrested = false

local MT = getrawmetatable(game)
local IndexMT = MT.__index
local __Namecall = MT.__namecall
local NewIndex = MT.__newindex

setreadonly(MT, false)

-- Reload:
function UnloadScript()
    print("UNLOADING WRATH ADMIN...")

    -- Tables:
    AmmoGuns = {}
    Walls = {}
    Trapped = {}
    CommandQueue = {}
    ChatQueue = {}
    Admins = {}
    Trapped = {}
    PunchFunction = {}
    Loopkilling = {}
    Infected = {}
    KillAuras = {}
    WhitelistedItems = {}
    ArmorSpamFlags = {}

    -- Locals:
    PunchFunction = nil
    CurrentlyViewing = nil
    SavedPosition = CFrame.new()
    SavedCameraPosition = CFrame.new()

    task.wait(1 / 10)

    for i, State in next, States do
        State = false
    end
    for i, Setting in next, ProtectedSettings do
        Setting = true
    end
    for i, Setting in next, AdminSettings do
        Setting = true
    end

    local ListGui = CoreGui:FindFirstChild("CMDList")
    local CommandBarGui = CoreGui:FindFirstChild("WrathCommandBar")

    if ListGui then
        ListGui:Destroy()
    end
    if CommandBarGui then
        CommandBarGui:Destroy()
    end
end

-- Spawn Points
pcall(
    function()
        local File = readfile("WrathAdminSavedWayPoints.json")
        SavedWaypoints = HttpService:JSONDecode(File)
    end
)

-- Walls:
for i, v in pairs(workspace:GetDescendants()) do
    local Lower = v.Name:lower()
    if
        (Lower:find("wall") or Lower:find("building") or Lower:find("fence") or Lower:find("gate") or
            Lower:find("window") or
            Lower:find("glass") or
            Lower:find("outline") or
            Lower:find("accent")) and
            (v:IsA("BasePart") or v:IsA("Model"))
     then
        Walls[#Walls + 1] = v
    end
end

local Commands = {
    "Welcome To Wrath Admin",
    "Made by Zyrex, Silent#4508, JJ Sploit On Top, & Hiidk",
    "INFO: -- Reformated some of it c: Admin is broken and im not fixing!",
    "Press . for command bar",
    "cmds -- shows this",
    "output -- shows the output",
    "=== TELEPORTS ===",
    "goto / to [plr] -- teleports you to plr",
    "bring [plr] -- teleports plr to you",
    "lb / loopbring [plr,all] -- loop brings plr/all to you",
    "unlb / unloopbring [plr,all] -- unloopbrings",
    "nexus / nex [plr] -- teleports plr to nexus",
    "yard / yar [plr] -- teleports plr to yard",
    "back / bac [plr] -- teleports plr to back nexus",
    "tower / tow [plr] -- teleports plr to tower",
    "base [plr] -- teleports plr to crim base",
    "cafe [plr] -- teleports plr to cafe",
    "cells / cel [plr] -- teleports to cells",
    "kitchen / kit [plr]",
    "tp [plr] [plr2] -- teleports plr to plr2",
    "trap [plr] -- traps plr",
    "untrap [plr] untraps plr",
    "void [plr] -- teleports plr to void",
    "towaypoint / tw [name] -- teleports to a certain spawnpoint",
    "wp / setwaypoint [name] -- set spawnpoint where you stand ",
    "dwp / delwaypoint [name] -- remove spawnpoint",
    "getwpnames / getwaypointnames -- gets waypoint names",
    "clwp -- clears waypoints",
    "=== Troll Cmds ===",
    "vent [plr] -- vents player",
    "snack [plr] / vending [plr] -- snacks player",
    "slide [plr] -- slides player",
    "drop [plr] -- drops player",
    "oob [plr] / mountain [plr] -- brings to a spot on mountain",
    "escape [plr] -- tps player to where you escape",
    "secretroom [plr] -- brings player to secret room",
    "undermap [plr] -- good spot for chilling",
    "toilet [plr] -- puts player into toilet",
    "trash [plr] -- puts player into dumpster",
    "policecar [plr] brings player to police car spawner",
    "busstop [plr] -- brings you to the bus stop with car spawner",
    "store [plr] -- brings player to store",
    "bridge [plr] -- brings player to the bridge",
    "station [plr] -- brings you to station in prison",
    "hiddenplace [plr] -- brings you to another hidden place",
    "roof [plr] -- brings player to roof",
    "gate [plr] -- brings player to the gate",
    "ref [plr] / fridge [plr] -- locks player in fridge",
    "oven [plr] -- locks player in oven",
    "chillout [plr] -- sends you to a enclosed building",
    "base2 [plr] -- sends you to 2nd base",
    "base3 [plr] -- sends you to 3rd base",
    "sewer [plr] -- sends you to sewer system",
    "container [plr] -- sends you to container 1",
    "=== KILL CMDS ===",
    "kill [plr] / kill guards, inmates, criminals -- kills a player, team, or all",
    "mkill [plr] -- melee kill player or all",
    "vkill [plr] -- void kill player (kills them by sending them to the void)",
    "nuke / kamikaze [plr] -- turns plr into a nuke",
    "defuse / unnuke [plr] -- removes nuke from plr",
    "tase [plr,all] -- tase a player or all",
    "lk [plr,all,inmates,guards,criminals] -- loopkills plr/team/all",
    "unlk [plr,all,inmates,guards,criminals] -- stops loopkill",
    "mlk [plr,all] -- melee loopkil plr/all",
    "unmlk [plr,all] -- unmelee loopkill plr/all",
    "slk [plr,team,all] -- speed loopkill plr/team/all",
    "unslk [plr,team,all] -- stop speed loopkill plr/team/all",
    "clk / clearloopkills -- clears loopkill tables (EVERY LOOPKILL INCLUDING TEAMKILLS)",
    "getlk / getloopkills -- gets all players who are being loopkilled",
    "aura / ka [plr] -- kill aura plr or all",
    "unka / unaura [plr] -- removes kill aura from player or all",
    "virus / infect [plr] -- gives virus to a player (touch kill)",
    "rvirus / unvirus [plr]",
    "ta / taseaura [plr] -- gives plr tase aura",
    "getv / getinfected -- gets all currently infected players",
    "getk / getkillauras -- gets all players that have a kill aura",
    "getlt / getlooptase -- gets all players that are being loop tased",
    "getmlk / getmeleeloopkill -- gets all players that are being melee loop killed",
    "lt [plr,all] -- loop tase plr or all",
    "unlt [plr,all] -- stops loop tase plr or all",
    "sp / spampunch -- toggles spam punch (your punches will be really fast if you hold down F)",
    "pa / punchaura -- toggles punch aura (your punches have more range)",
    "op / onepunch [plr] -- toggles one punch (your punches will insta kill)",
    "os / oneshot [plr] -- toggles one shot for plr",
    "shootback / sb [plr] -- shoot back plr (when they get shot the person who shot them dies)",
    "tb / taseback [plr] -- tase back plr (when they get shot the person who shot them gets tased)",
    "clv -- clear virus",
    "clka -- clear kill auras",
    "clt -- clear loop tase",
    "clos -- clear one shots",
    "clsb / clearshootback -- clears shoot back",
    "cltb / cleartaseback -- clears tase back",
    "atc / autoteamchange -- toggles auto team change (changes your team if whoever you are killing is on the same team as you, true by default)",
    "=== GIVE ITEMS ===",
    "armor -- gives armor (requires riot gamepass | only works on you)",
    "shield [plr] -- gives plr riot shield",
    "cuffs / handcuffs [plr] -- gives handcuffs to player",
    "giveshotty / shotty [plr] -- gives plr shotgun",
    "giveak / ak [plr] -- gives plr ak47",
    "givem9 / m9 [plr] -- gives plr m9",
    "givem4 / m4 [plr] -- gives plr m4a1",
    "givehammer / hammer [plr] -- gives plr hammer",
    "giveknife / knife [plr] -- gives plr knife",
    "givekeycard / keycard [plr] -- gives plr keycard",
    "givehandcuffs / handcuffs [plr] -- gives plr handcuffs",
    "givetaser / taser [plr] -- gives plr taser",
    "=== GUN COMMANDS ===",
    "aguns -- auto give gun",
    "unaguns -- stop auto give gun",
    "gun / guns -- gives guns (one time)",
    "af / autofire -- disables semi auto guns (m9) || taser isn't affected :(",
    "aaf / autoaf -- automatically enables autofire every time you respawn",
    "ia / infammo -- emables infinite ammo",
    "aia / autoinfammo -- automatically enables infinite ammo every time you respawn",
    "ffire / friendlyfire -- toggles friendly fire on/off",
    "oneshot / os [plr] -- one shot gun",
    "=== ARREST ===",
    "sa [plr] -- spam arrest plr",
    "unsa / breaksa -- breaks spam arrest",
    "arrest [plr,all] [number] -- arrests player with specified number of arrests (defaults to 1 if not specified)",
    "aa / arrestaura -- arrest aura",
    "=== OTHER ===",
    "getinvis / getinv -- get invisible players",
    "geta / getarmorspammers -- (gets armor spammers)",
    "fps / antilag / boost -- Make game FPS faster (Depends on your computer on how much faster it'll be, but nonetheless it will work!)",
    "crim [plr] -- turns plr into criminal",
    "team / t [color / guards / inmates / criminals / rgb] -- change team",
    "rejoin / rj -- makes you rejoin the server",
    "auto -- toggle auto respawn",
    "view [plr] -- view plr",
    "unview -- unview plr",
    "annoy [plr] -- repeatedly walks up to the player and punches them",
    "unannoy -- stops annoying the plr",
    "logspam / ls -- spams logs",
    "unlogspam / unls -- stops log spam",
    "meleeaura / ma -- melee aura",
    "prefix [new prefix] -- changes chat prefix to new prefix",
    "exit -- unloads the script",
    "god -- you cant die",
    "ungod -- disables god",
    "clogs / combatlogs -- toggles combat logs (NOT ACCURATE AGAINST EXPLOITERS / YOU NEED TO DISABLE ANTICRASH TO USE THIS)",
    "getd / getdef -- gets all defense states",
    "getstates / gets -- gets current states",
    "btools -- gives you btools",
    "noclip -- allows you to walk through walls",
    "clip -- disables noclip",
    "ff / forcefield -- enables ff",
    "unff / unforcefield -- disables ff",
    "ctp / clicktp -- clicktp plr",
    "clctp -- clears click teleports",
    "shop / serverhop -- server hop",
    "ct / copyteam [plr] -- copy team of plr",
    "gs / gunspin -- guns will spin around you",
    "sarmor / spamarmor [strength] -- armor spam",
    "unsarmor / unspamarmor -- stops armor spam",
    "lpunch / loudpunch -- makes your punches loud",
    "=== FLING ===",
    "fling [plr] -- Flings player (lowest fling)",
    "unfling -- break fling",
    "sfling [plr] -- Super flings player",
    "unsfling -- break sfling",
    "bfling [plr] -- Body flings player (For Godded players, NET bypass doesn't count!)",
    "unbfling -- breaks bfling",
    "getflings / getf -- gets invisible flingers",
    "=== COLOR TEAMS ===",
    "caucasian / white -- white",
    "red",
    "black -- black",
    "blue",
    "purple",
    "pink",
    "green",
    "cyan",
    "yellow",
    "gold",
    "grey",
    "brown",
    "maroon",
    "navy",
    "salmon",
    "lightpink",
    "lightblue",
    "copyteam [plr] -- copies a plr's team [use again to disable]",
    "=== DEFENSE ===",
    "ac / anticrim -- stops you from becoming criminal",
    "ab / antibring -- stops you from being bring (deletes tools)",
    "afling / antifling -- stops you from being flung",
    "ap / antipunch -- kills players that punch you",
    "anticrash / acrash -- disables bullet replication / makes you immune to crash scripts (disables/enables .clogs, .sb, .tb, .ctp, .os) || disabled by default",
    "def / defenses -- enables all defenses",
    "undef / undefenses -- disables all defenses",
    "=== MAP ===",
    "nodoors -- removes doors",
    "doors / redoors -- restores doors",
    "walls -- restores wall",
    "nowalls -- removes walls",
    "=== PROTECTION COMMANDS ===",
    "p / protect [plr] -- protects a player",
    "up / unprotect [plr] -- revokes a player's protection",
    "clp / clearprotected -- revokes every protected player",
    "getp / getprotected -- view all protected",
    "psettings / ps -- [killcmds/tpcmds/arrestcmds/givecmds/othercmds/karma] [true, immune / false, not immune]",
    "getps / getprotectedsettings -- gets all current configuration settings for protected players",
    "=== LAG COMMANDS ===",
    "rip / crash -- completely shits on the server",
    "sc / softcrash -- freezes everyone's screen but keeps the server alive, best way to empty servers",
    "lag [strength] -- lags server with strength indefinitely",
    "unlag -- stops lag",
    "timeout -- kills server, doesnt freeze people's screens",
    "=== GUI COMMANDS ===",
    "gui / guis -- toggle gui",
    "bindgui / guikeybind [keycode] (eg. 'G' or 'LeftAlt' or 'One') -- keybind for gui"
}

local CustomColors = {
    ["white"] = {255, 255, 255}, -- White
    ["red"] = {255, 0, 0}, -- Red
    ["black"] = {0, 0, 0}, -- Black
    ["blue"] = {0, 17, 201},
    ["purple"] = {176, 5, 255},
    ["pink"] = {255, 0, 187},
    ["green"] = {0, 252, 8}, -- Green
    ["cyan"] = {0, 255, 242}, -- Cyan
    ["yellow"] = {242, 250, 0},
    ["gold"] = {237, 167, 14},
    ["grey"] = {111, 110, 112},
    ["brown"] = {59, 41, 0}, -- Brown
    ["lightpink"] = {255, 182, 193},
    ["lightblue"] = {128, 128, 128},
    ["maroon"] = {128, 0, 0},
    ["salmon"] = {250, 128, 114},
    ["navy"] = {0, 0, 128}
}

local PauseChecks

-- Checks if it is loaded
if getgenv().WrathLoaded then
    UnloadScript()
else
    getgenv().WrathLoaded = true
end

function SavePos(POS)
    pcall(
        function()
            POS = POS or LocalPlayer.Character.Head.CFrame
        end
    )

    if POS and LocalPlayer.Character then
        SavedPosition = POS
        SavedCameraPosition = Camera.CFrame
    end
end

firetouchinterest = function(base, part)
    local oldp = part.Parent;
    local oldc = part.CFrame;
    part.Parent = workspace;
    part.Transparency = 1;
    part.CFrame = base.CFrame;
    task.wait();
    part.Parent = oldp;
    part.Transparency = 0;
    part.CFrame = oldc;
end;

function LoadPos()
    if SavedPosition and LocalPlayer.Character then
        if LocalPlayer.Character.PrimaryPart then
            LocalPlayer.Character:SetPrimaryPartCFrame(SavedPosition)
            rService.RenderStepped:wait()
            Camera.CFrame = SavedCameraPosition
        end
    end
end

function CheckWhitelisted(ITEM)
    for i, v in next, WhitelistedItems do
        if v == ITEM then
            return true
        end
    end
    return false
end

function Notify(Title, Text, Duration)
    game.StarterGui:SetCore(
        "SendNotification",
        {
            Title = Title,
            Text = Text,
            Icon = "",
            Duration = Duration
        }
    )
    AddLog(Title, Text)
end

local function Rejoin(SIR)
    game.Players.LocalPlayer:kick(SIR)
    local telepoitserveice = game:GetService("TeleportService")
    telepoitserveice:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end

function WhitelistItem(ITEM)
    WhitelistedItems[#WhitelistedItems + 1] = ITEM
end

function GetRegion(Player)
    if Player then
        if Player.Character then
            if RegionModule.findRegion(Player.Character) then
                return RegionModule.findRegion(Player.Character)["Name"]
            end
        end
    end
end

function IllegalRegion(Player)
    local Permitted = rStorage.PermittedRegions
    for i, v in pairs(Permitted:GetChildren()) do
        if GetRegion(Player) == v.Value then
            return false
        end
    end
    return true
end

function ArrestEvent(PLR, TIMES)
    pcall(
        function()
            TIMES = TIMES or 1
            if States.SpamArresting then
                for i = 1, TIMES do
                    if not States.SpamArresting or not PLR or not Players:FindFirstChild(PLR.Name) then
                        break
                    end
                    task.spawn(
                        function()
                            workspace.Remote.arrest:InvokeServer(PLR.Character:FindFirstChildWhichIsA("Part"))
                        end
                    )
                    task.wait(0.03)
                end
            else
                for i = 1, TIMES do
                    task.spawn(
                        function()
                            workspace.Remote.arrest:InvokeServer(PLR.Character:FindFirstChildWhichIsA("Part"))
                        end
                    )
                    if
                        PLR.TeamColor.Name ~= "Really red" or not IllegalRegion(PLR) or
                            not Players:FindFirstChild(PLR.Name)
                     then
                        break
                    end
                    rService.RenderStepped:wait()
                end
            end
        end
    )
end

function Arrest(PLR, TIMES)
    pcall(
        function()
            if TIMES > 1 then
                local STOP = false
                task.spawn(
                    function()
                        task.wait(1 / 5 + TIMES / 10)
                        STOP = true
                    end
                )
                while true do
                    LocalPlayer.Character.Humanoid.Sit = false
                    LocalPlayer.Character:SetPrimaryPartCFrame(PLR.Character.Head.CFrame * CFrame.new(0, 0, 1))
                    coroutine.wrap(ArrestEvent)(PLR, TIMES)
                    if STOP or PLR.TeamColor.Name ~= "Really red" or not Players:FindFirstChild(PLR.Name) then
                        break
                    end
                    rService.RenderStepped:wait()
                end
            else
                pcall(
                    function()
                        LocalPlayer.Character.Humanoid.Sit = false
                        LocalPlayer.Character:SetPrimaryPartCFrame(PLR.Character.Head.CFrame * CFrame.new(0, 0, 1))
                        task.wait(0.15)
                        coroutine.wrap(ArrestEvent)(PLR, 15)
                    end
                )
            end
        end
    )
end

function YieldUntilScriptLoaded(SCRIPT)
    while task.wait(0.03) do
        local SUCCESS, ERROR = pcall(getsenv, SCRIPT)
        if SUCCESS then
            break
        end
    end
end

function MeleeEvent(PLR)
    rStorage.meleeEvent:FireServer(PLR)
end

function CheckProtected(Player, index)
    if Player then
        return not Protected[Player.UserId] or (Protected[Player.UserId] and ProtectedSettings[index] == false)
    end
end

function ItemHandler(ITEM)
    workspace.Remote.ItemHandler:InvokeServer(ITEM)
    pcall(
        function()
            WhitelistItem(LocalPlayer.Backpack:FindFirstChild(ITEM.Parent.Name))
        end
    )
end

function TeamEvent(COLOR)
    workspace.Remote.TeamEvent:FireServer(COLOR)
end

function Loadchar(COLOR)
    if LocalPlayer.TeamColor.Name == "Medium stone grey" then
        if COLOR == nil or COLOR == "Medium stone grey" then
            Info.LoadingNeutralChar = true
            workspace.Remote.loadchar:InvokeServer(LocalPlayer.Name, "Really black")
            TeamEvent("Medium stone grey")
            Info.LoadingNeutralChar = false
        else
            workspace.Remote.loadchar:InvokeServer(LocalPlayer.Name, COLOR)
        end
    else
        workspace.Remote.loadchar:InvokeServer(LocalPlayer.Name, COLOR)
    end
end

function CheckOwnedGamepass()
    return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId, 96651)
end

function Chat(Message)
    ChatQueue[#ChatQueue + 1] = function()
        rStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Message, "All")
    end
end

function ModGun(Tool)
    local GS = Tool:WaitForChild("GunStates", 1)
    if GS then
        if States.AutoInfiniteAmmo then
            local Stats = require(GS)
            Stats.MaxAmmo = math.huge
            Stats.CurrentAmmo = math.huge
            Stats.AmmoPerClip = math.huge
            Stats.StoredAmmo = math.huge
            AmmoGuns[#AmmoGuns + 1] = Tool
        end
        if States.AutoAutoFire then
            local Stats = require(GS)
            Stats.AutoFire = true
        end
    end
end

function GiveGuns()
    if CheckOwnedGamepass() then
        ItemHandler(workspace.Prison_ITEMS.giver["M4A1"].ITEMPICKUP)
        ItemHandler(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)
        ItemHandler(workspace.Prison_ITEMS.giver["M9"].ITEMPICKUP)
        ItemHandler(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
        if workspace.Prison_ITEMS.single:FindFirstChild("Key card") then
            ItemHandler(workspace.Prison_ITEMS.single["Key card"].ITEMPICKUP)
        end
    else
        ItemHandler(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
        ItemHandler(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)
        ItemHandler(workspace.Prison_ITEMS.giver["M9"].ITEMPICKUP)
        if workspace.Prison_ITEMS.single:FindFirstChild("Key card") then
            ItemHandler(workspace.Prison_ITEMS.single["Key card"].ITEMPICKUP)
        end
    end
end


for i, v in pairs(workspace:FindFirstChild("Criminals Spawn"):GetChildren()) do
    if v.Name == "SpawnLocation" then
        v.Parent = game.Lighting
    end
end

local SpawnLocation = game:GetService("Lighting"):FindFirstChild("SpawnLocation")
function Crim(Player, isSpamArrest)
    pcall(
        function()
            local SpawnLocation = game:GetService("Lighting"):FindFirstChild("SpawnLocation")
            PauseChecks = true
            SavePos()
            local SavedTeam = LocalPlayer.TeamColor.Name
            Loadchar()
            if isSpamArrest then
                LoadPos()
            else
                LocalPlayer.Character:SetPrimaryPartCFrame(Player.Character.Head.CFrame * CFrame.new(0, 0, 0.75))
                task.spawn(
                    function()
                        rService.RenderStepped:wait()
                        Camera.CFrame = SavedCameraPosition
                    end
                )
            end

            SpawnLocation.Transparency = .5
            SpawnLocation.Anchored = true
            SpawnLocation.CanCollide = false
            local CHAR = LocalPlayer.Character
            CHAR.Humanoid.Name = "1"
            local c = CHAR["1"]:Clone()
            c.Name = "Humanoid"
            c.Parent = CHAR
            CHAR["1"]:Destroy()
            Workspace.CurrentCamera.CameraSubject = CHAR

            CHAR.Animate.Disabled = false
            wait(.01)
            CHAR.Animate.Disabled = true

            CHAR.Humanoid.DisplayDistanceType = "None"

            ItemHandler(workspace.Prison_ITEMS.single["Hammer"].ITEMPICKUP)
            if not LocalPlayer.Backpack:FindFirstChild("Hammer") then
                ItemHandler(workspace.Prison_ITEMS.single["Remington 870"].ITEMPICKUP)
            end

            local tool =
                LocalPlayer.Backpack:FindFirstChild("Hammer") or LocalPlayer.Backpack:FindFirstChild("Remington 870")
            WhitelistItem(tool)

            tool.Parent = CHAR
            local STOP = 0

            LoadPos()
            repeat
                STOP = STOP + 1
                if isSpamArrest then
                    LoadPos()
                    Player.Character:SetPrimaryPartCFrame(LocalPlayer.Character.Head.CFrame * CFrame.new(0, 0, -0.75))
                else
                    LocalPlayer.Character:SetPrimaryPartCFrame(Player.Character.Head.CFrame * CFrame.new(0, 0, 0.75))
                end
                if Player.TeamColor.Name == "Really red" then
                    break
                end
                firetouchinterest(Player.Character.Head, SpawnLocation, 0)
                task.wait(0.03)
            until (not LocalPlayer.Character:FindFirstChild(tool.Name) or not LocalPlayer.Character or
                not Player.Character) and
                STOP > 3
            task.wait(1 / 5)
            Loadchar(SavedTeam)
            LoadPos()
        end
    )
end



function Give(Player, TOOL, GIVER, TEAM, SPAWNED, DISABLESAVELOADPOS)
    PauseChecks = true
    pcall(
        function()
            if Player == LocalPlayer then
                if not SPAWNED then
                    if not GIVER then
                        ItemHandler(workspace.Prison_ITEMS.single[TOOL].ITEMPICKUP)
                    else
                        local SavedTeam = LocalPlayer.TeamColor.Name
                        if TOOL == "Riot Shield" then
                            SavePos()
                            if #Teams.Guards:GetChildren() > 8 then
                                Loadchar("Bright blue")
                            else
                                TeamEvent("Bright blue")
                            end
                        end
                        ItemHandler(workspace.Prison_ITEMS.giver[TOOL].ITEMPICKUP)
                        if TOOL == "Riot Shield" then
                            if SavedTeam == "Bright orange" or SavedTeam == "Medium stone grey" then
                                TeamEvent(SavedTeam)
                            else
                                Loadchar(SavedTeam)
                            end
                            LoadPos()
                        end
                    end
                end
            else
                if not DISABLESAVELOADPOS then
                    SavePos()
                end
                local SavedTeam = LocalPlayer.TeamColor.Name
                Loadchar(TEAM)
                if not SPAWNED then
                    if not GIVER then
                        ItemHandler(workspace.Prison_ITEMS.single[TOOL].ITEMPICKUP)
                    else
                        ItemHandler(workspace.Prison_ITEMS.giver[TOOL].ITEMPICKUP)
                    end
                end
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
                local CHAR = LocalPlayer.Character
                CHAR.Humanoid.Name = "1"
                local c = CHAR["1"]:Clone()
                c.Name = "Humanoid"
                c.Parent = CHAR
                CHAR["1"]:Destroy()
                Workspace.CurrentCamera.CameraSubject = CHAR
                CHAR.Animate.Disabled = true
                task.wait(0.03)
                CHAR.Animate.Disabled = false
                CHAR.Humanoid.DisplayDistanceType = "None"
                local tool = LocalPlayer.Backpack:FindFirstChild(TOOL)
                WhitelistItem(tool)
                tool.Parent = CHAR
                local STOP = 0
                repeat
                    STOP = STOP + 1
                    LocalPlayer.Character:SetPrimaryPartCFrame(Player.Character.Head.CFrame * CFrame.new(0, 0, 0.75))
                    task.wait(0.03)
                until (not LocalPlayer.Character:FindFirstChild(TOOL) or not LocalPlayer.Character or
                    not Player.Character or
                    STOP > 500) and
                    STOP > 3
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                if not DISABLESAVELOADPOS then
                    if Player ~= LocalPlayer then
                        Loadchar(SavedTeam)
                    else
                        if SavedTeam == "Bright orange" or SavedTeam == "Medium stone grey" then
                            TeamEvent(SavedTeam)
                        end
                    end
                    LoadPos()
                end
            end
        end
    )
end

function Keycard(Player)
    pcall(
        function()
            States.GivingKeycard = true
            local PICKUP = workspace.Prison_ITEMS.single
            local SavedTeam = LocalPlayer.TeamColor.Name
            SavePos()
            if not PICKUP:FindFirstChild("Key card") then
                while task.wait(0.03) do
                    LocalPlayer.Character.Humanoid.Health = 0
                    task.wait(1 / 10)
                    Loadchar("Bright blue")
                    if PICKUP:FindFirstChild("Key card") then
                        break
                    end
                end
            end
            if Player == LocalPlayer then
                Loadchar(SavedTeam)
                ItemHandler(workspace.Prison_ITEMS.single["Key card"].ITEMPICKUP)
            else
                Give(Player, "Key card", false, nil, nil, true)
                Loadchar(SavedTeam)
            end
            LoadPos()
            task.wait(1 / 5)
            States.GivingKeycard = false
        end
    )
end

function EditStat(GUN, Stat, Value)
    pcall(
        function()
            local Stats = require(GUN.GunStates)
            Stats[Stat] = Value
        end
    )
end

function AddToQueue(Function)
    CommandQueue[#CommandQueue + 1] = Function
end

function Kill(PLAYERS)
    local Events = {}

    for i, v in next, PLAYERS do
        if v.Character then
            if v.TeamColor == LocalPlayer.TeamColor and not States.AntiCriminal and States.AutoTeamChange then
                SavePos()
                Loadchar(BrickColor.random().Name)
                LoadPos()
            end
            for i = 1, 15 do
                Events[#Events + 1] = {
                    Hit = v.Character:FindFirstChildOfClass("Part"),
                    Cframe = CFrame.new(),
                    RayObject = Ray.new(Vector3.new(), Vector3.new()),
                    Distance = 0
                }
            end
        end
    end

    ItemHandler(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)

    pcall(
        function()
            local Gun =
                LocalPlayer.Backpack:FindFirstChild("Remington 870") or
                LocalPlayer.Character:FindFirstChild("Remington 870")
            if not Gun then
                ItemHandler(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
                Gun = LocalPlayer.Backpack:FindFirstChild("AK-47") or LocalPlayer.Character:FindFirstChild("AK-47")
            end
            WhitelistItem(Gun)
            task.spawn(
                function()
                    for i = 1, 5 do
                        rStorage.ReloadEvent:FireServer(Gun)
                        task.wait(1 / 2)
                    end
                end
            )

            rStorage.ShootEvent:FireServer(Events, Gun)
        end
    )
end

function Tase(PLAYERS)
    local Events = {}

    for i, v in next, PLAYERS do
        if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
            if v.Character and v.TeamColor.Name ~= "Bright blue" then
                Events[#Events + 1] = {
                    Hit = v.Character:FindFirstChildOfClass("Part"),
                    Cframe = CFrame.new(),
                    RayObject = Ray.new(Vector3.new(), Vector3.new()),
                    Distance = 0
                }
            end
        end
    end

    pcall(
        function()
            if not LocalPlayer.Backpack:FindFirstChild("Taser") and not States.AutoTeamChange then
                SavePos()
                Loadchar("Bright blue")
                LoadPos()
            end
            local Gun = LocalPlayer.Backpack:FindFirstChild("Taser") or LocalPlayer.Character:FindFirstChild("Taser")
            WhitelistItem(Gun)
            task.spawn(
                function()
                    for i = 1, 5 do
                        rStorage.ReloadEvent:FireServer(Gun)
                        task.wait(1 / 2)
                    end
                end
            )

            rStorage.ShootEvent:FireServer(Events, Gun)
        end
    )
end

local function FixScreen()
    for i = 1, 10 do
        pcall(
            function()
                LocalPlayer.PlayerGui.Home.intro.Visible = false
                LocalPlayer.PlayerGui.Home.hud.Visible = true
                Camera.FieldOfView = 70
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                LocalPlayer.Character.Torso.Anchored = false
            end
        )
        task.wait(0.03)
    end
end

LocalPlayer.CharacterAdded:Connect(
    function(Char)
        if
            (Info.AutoRespawnOldTeam == "Medium stone grey" or LocalPlayer.TeamColor.Name == "Medium stone grey") and
                not Info.RespawnPaused and
                not States.Forcefield
         then
            Info.RespawnPaused = true
            coroutine.wrap(FixScreen)()
            pcall(
                function()
                    if not Info.HasDied then
                        Loadchar("Really black")
                    end
                    TeamEvent("Medium stone grey")
                end
            )
            if not Info.HasDied and not Info.LoadingNeutralChar then
                LoadPos()
            end
            coroutine.wrap(FixScreen)()
            Info.RespawnPaused = false
        end
    end
)

LocalPlayer.CharacterRemoving:Connect(
    function()
        if not Info.HasDied then
            Info.AutoRespawnOldTeam = LocalPlayer.TeamColor.Name
        end
    end
)

function AutoRespawnCharacterAdded(CHAR)
    local function OnDied()
        if States.AutoRespawn and not States.GivingKeycard and not States.Forcefield then
            Info.HasDied = true
            SavePos()
            Info.AutoRespawnOldTeam = LocalPlayer.TeamColor.Name
            if Info.AutoRespawnOldTeam ~= "Medium stone grey" and LocalPlayer.TeamColor.Name ~= "Medium stone grey" then
                Loadchar()
            else
                Loadchar("Really black")
            end
            LoadPos()
            Info.HasDied = false
        end
    end
    local Humanoid = CHAR:WaitForChild("Humanoid", 1)
    if Humanoid then
        Humanoid.Died:Connect(OnDied)
    end
end

function LocalViewerAdded()
    pcall(
        function()
            Camera.CameraSubject = CurrentlyViewing.Player.Character
        end
    )
end

function Teleport(Player, Position)
    PauseChecks = true
    if Player == LocalPlayer then
        if LocalPlayer.Character then
            LocalPlayer.Character:SetPrimaryPartCFrame(Position)
        end
    else
        pcall(
            function()
                SavePos()
                Loadchar()
                LocalPlayer.Character:SetPrimaryPartCFrame(Position)
                task.spawn(
                    function()
                        rService.RenderStepped:wait()
                        Camera.CFrame = SavedCameraPosition
                    end
                )
                ItemHandler(workspace.Prison_ITEMS.single.Hammer.ITEMPICKUP)
                if LocalPlayer.Backpack:FindFirstChild("Hammer") then
                    ItemHandler(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
                end
                local CHAR = LocalPlayer.Character
                CHAR.Humanoid.Name = "1"
                local c = CHAR["1"]:Clone()
                c.Name = "Humanoid"
                c.Parent = CHAR
                CHAR["1"]:Destroy()
                Workspace.CurrentCamera.CameraSubject = CHAR
                CHAR.Animate.Disabled = true
                CHAR.Animate.Disabled = false
                CHAR.Humanoid.DisplayDistanceType = "None"
                local tool = LocalPlayer.Backpack:FindFirstChild("Hammer") or LocalPlayer.Backpack:FindFirstChild("M9")
                WhitelistItem(tool)
                tool.Parent = CHAR
                local STOP = 0
                repeat
                    STOP = STOP + 1
                    LocalPlayer.Character:SetPrimaryPartCFrame(Position)
                    Player.Character:SetPrimaryPartCFrame(LocalPlayer.Character.Head.CFrame * CFrame.new(0, 0, -0.75))
                    task.wait(0.03)
                until (not LocalPlayer.Character:FindFirstChild(tool.Name) or not LocalPlayer.Character or
                    not Player.Character or
                    STOP > 500) and
                    STOP > 3
                Loadchar()
                LoadPos()
            end
        )
    end
end

function LoopTeleport(Player, Position, All)
    PauseChecks = true
    States.Loopbring = true
    task.spawn(
        function()
            while task.wait() do
                pcall(
                    function()
                        SavePos()
                        LocalPlayer.Character:SetPrimaryPartCFrame(Position)
                        local CHAR = LocalPlayer.Character
                        CHAR.Humanoid.Name = "1"
                        local c = CHAR["1"]:Clone()
                        c.Name = "Humanoid"
                        c.Parent = CHAR
                        CHAR["1"]:Destroy()
                        Workspace.CurrentCamera.CameraSubject = CHAR
                        CHAR.Animate.Disabled = true
                        CHAR.Animate.Disabled = false
                        CHAR.Humanoid.DisplayDistanceType = "None"
                        CHAR.Humanoid.PlatformStand = true
                        local tool
                        local STOP = 0
                        local Finish = false
                        task.spawn(
                            function()
                                LocalPlayer.CharacterAdded:wait()
                                Finish = true
                            end
                        )
                        repeat
                            STOP = STOP + 1
                            task.wait(0.03)
                        until (not CHAR or Finish or not States.Loopbring)
                        LocalPlayer.Character.HumanoidRootPart.Anchored = false
                        --Loadchar();
                        if not States.Loopbring then
                            Loadchar()
                        end
                        LoadPos()
                    end
                )
                if not States.Loopbring or not Player or not Players:FindFirstChild(Player.Name) then
                    break
                end
            end
        end
    )

    while task.wait() do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if (not All and p == Player) or All == true then
                    ItemHandler(workspace.Prison_ITEMS.single.Hammer.ITEMPICKUP)
                    pcall(
                        function()
                            if
                                p.Character and p.Character.Humanoid and p.Character.Humanoid.Health > 0 and
                                    p.Character.Torso.Anchored == false
                             then
                                for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                                    LocalPlayer.Character.Humanoid:EquipTool(v)
                                    local Limit = 0
                                    repeat
                                        LocalPlayer.Character:SetPrimaryPartCFrame(Position)
                                        p.Character:SetPrimaryPartCFrame(
                                            LocalPlayer.Character.Head.CFrame * CFrame.new(0, 0, -0.75)
                                        )
                                        if not States.Loopbring or not Player or not Players:FindFirstChild(Player.Name) then
                                            break
                                        end
                                        task.wait(0.03)
                                    until v.Parent ~= LocalPlayer.Character or Limit > 500 or not p.Character or
                                        not p.Character.Humanoid or
                                        p.Character.Humanoid.Health <= 0 or
                                        p.Character.Torso.Anchored == true
                                    v:Destroy()
                                end
                            end
                        end
                    )
                end
            end
        end
        if not States.Loopbring or not Player or not Players:FindFirstChild(Player.Name) then
            break
        end
    end
    States.Loopbring = false
end

function TeleportPlayers(Player1, Player2)
    if Player1 == LocalPlayer then
        pcall(
            function()
                LocalPlayer.Character:SetPrimaryPartCFrame(Player2.Character.Head.CFrame)
            end
        )
    elseif Player2 == LocalPlayer then
        pcall(
            function()
                Teleport(Player1, LocalPlayer.Character.Head.CFrame)
            end
        )
    else
        pcall(
            function()
                SavePos()
                Loadchar()
                ItemHandler(workspace.Prison_ITEMS.single.Hammer.ITEMPICKUP)
                if LocalPlayer.Backpack:FindFirstChild("Hammer") then
                    ItemHandler(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
                end
                local CHAR = LocalPlayer.Character
                CHAR.Humanoid.Name = "1"
                local c = CHAR["1"]:Clone()
                c.Name = "Humanoid"
                c.Parent = CHAR
                CHAR["1"]:Destroy()
                Workspace.CurrentCamera.CameraSubject = CHAR
                CHAR.Animate.Disabled = true
                CHAR.Animate.Disabled = false
                CHAR.Humanoid.DisplayDistanceType = "None"
                local tool = LocalPlayer.Backpack:FindFirstChild("Hammer") or LocalPlayer.Backpack:FindFirstChild("M9")
                tool.Parent = CHAR
                local STOP = 0
                repeat
                    STOP = STOP + 1
                    LocalPlayer.Character:SetPrimaryPartCFrame(Player2.Character.Head.CFrame * CFrame.new(0, 0, -4))
                    Player1.Character:SetPrimaryPartCFrame(LocalPlayer.Character.Head.CFrame * CFrame.new(0, 0, -0.75))
                    task.wait(0.03)
                until (not LocalPlayer.Character:FindFirstChild("M9") and
                    not LocalPlayer.Character:FindFirstChild("Hammer") or
                    not LocalPlayer.Character.HumanoidRootPart or
                    not LocalPlayer.Character or
                    not Player1.Character or
                    not Player2.Character or
                    STOP > 500) and
                    STOP > 3
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                Loadchar()
                LoadPos()
            end
        )
    end
end

function BodyFling(Player)
    pcall(
        function()
            States.BodyFling = true
            SavePos()
            task.wait(1 / 2)
            local BT = Instance.new("BodyThrust")
            BT.Name = "Flinger"
            BT.Parent = LocalPlayer.Character.HumanoidRootPart
            BT.Force = Vector3.new(10500, 0, 10500)
            BT.Location = Player.Character.HumanoidRootPart.Position
            local BP = Instance.new("BodyPosition")
            BP.Name = "BP"
            BP.Parent = LocalPlayer.Character.HumanoidRootPart
            BP.D = 0
            BP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BP.P = 9e4
            while true do
                pcall(
                    function()
                        if Player.Character then
                            LocalPlayer.Character.Humanoid.Sit = false
                            BP.Position = Player.Character.HumanoidRootPart.Position
                            Camera.CameraSubject = Player.Character
                        end
                    end
                )
                pcall(
                    function()
                        if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BP") then
                            BP = Instance.new("BodyPosition")
                            BP.Name = "BP"
                            BP.Parent = LocalPlayer.Character.HumanoidRootPart
                            BP.D = 0
                            BP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            BP.P = 9e4
                        end
                    end
                )
                pcall(
                    function()
                        if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Flinger") then
                            BT = Instance.new("BodyThrust")
                            BT.Name = "Flinger"
                            BT.Parent = LocalPlayer.Character.HumanoidRootPart
                            BT.Force = Vector3.new(10500, 0, 10500)
                            BT.Location = Player.Character.HumanoidRootPart.Position
                        end
                    end
                )
                pcall(
                    function()
                        for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                            if child:IsA("BasePart") then
                                child.CustomPhysicalProperties = PhysicalProperties.new(2, 0.3, 0.5)
                            end
                        end
                    end
                )
                if not States.BodyFling or not Player or not Players:FindFirstChild(Player.Name) then
                    break
                end
                rService.RenderStepped:wait()
            end
            BT:Destroy()
            BP:Destroy()
            Loadchar()
            LoadPos()
            task.wait(1 / 2)
            Camera.CameraSubject = CurrentlyViewing.Player.Character or LocalPlayer.Character.Humanoid
            States.BodyFling = false
        end
    )
end

function GetPlayer(STRING, PLAYER)
    if STRING then
        if STRING:lower() == "me" then
            return PLAYER
        end
    else
        return PLAYER
    end
    local Player
    for i, v in pairs(Players:GetPlayers()) do
        pcall(
            function()
                local LowerName = v.Name:lower()
                local LowerDisplayName = v.DisplayName:lower()
                if LowerName:sub(1, #STRING) == STRING:lower() or LowerDisplayName:sub(1, #STRING) == STRING:lower() then
                    Player = v
                end
            end
        )
    end
    return Player
end

function KillPlayers(TEAM, Whitelist)
    local Events = {}

    for _, PLR in pairs(TEAM:GetPlayers()) do
        if PLR ~= LocalPlayer and PLR ~= Whitelist and CheckProtected(PLR, "killcmds") then
            if PLR.Character then
                if PLR.TeamColor == LocalPlayer.TeamColor and not States.AntiCriminal and States.AutoTeamChange then
                    SavePos()
                    Loadchar(BrickColor.random().Name)
                    LoadPos()
                end
                pcall(
                    function()
                        for i = 1, 15 do
                            Events[#Events + 1] = {
                                Hit = PLR.Character:FindFirstChildOfClass("Part"),
                                Cframe = CFrame.new(),
                                RayObject = Ray.new(Vector3.new(), Vector3.new()),
                                Distance = 0
                            }
                        end
                    end
                )
            end
        end
    end

    ItemHandler(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)

    pcall(
        function()
            local Gun =
                LocalPlayer.Backpack:FindFirstChild("Remington 870") or
                LocalPlayer.Character:FindFirstChild("Remington 870")
            if not Gun then
                ItemHandler(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
                Gun = LocalPlayer.Backpack:FindFirstChild("AK-47") or LocalPlayer.Character:FindFirstChild("AK-47")
            end
            WhitelistItem(Gun)
            task.spawn(
                function()
                    for i = 1, 30 do
                        rStorage.ReloadEvent:FireServer(Gun)
                        task.wait(1 / 2)
                    end
                end
            )
            rStorage.ShootEvent:FireServer(Events, Gun)
        end
    )
end

function Annoy(PLR)
    States.Annoy = true
    local Connection
    pcall(
        function()
            local SavedWalkSpeed = 24
            Teleport(LocalPlayer, PLR.Character.Head.CFrame * CFrame.new(0, 0, 1))
            Connection =
                PLR.CharacterAdded:Connect(
                function(CHAR)
                    local Head = CHAR:WaitForChild("Head", 1)
                    if Head then
                        Teleport(LocalPlayer, Head.CFrame * CFrame.new(0, 0, 1))
                    end
                end
            )
            task.spawn(
                function()
                    while true do
                        pcall(
                            function()
                                if LocalPlayer.Character and PLR.Character then
                                    local LPart = LocalPlayer.Character:FindFirstChildWhichIsA("BasePart")
                                    local VPart = PLR.Character:FindFirstChildWhichIsA("BasePart")
                                    if (LPart.Position - VPart.Position).Magnitude <= 15 then
                                        if PunchFunction and PLR.Character.Humanoid.Health > 0 then
                                            coroutine.wrap(PunchFunction)()
                                        end
                                    end
                                end
                            end
                        )
                        if not States.Annoy or not PLR then
                            break
                        end
                        task.wait(0.6)
                    end
                end
            )
            while task.wait(0.03) do
                pcall(
                    function()
                        if PLR.Character then
                            if PLR.Character.Humanoid.Health > 0 then
                                LocalPlayer.Character.Humanoid:MoveTo(PLR.Character.PrimaryPart.Position)
                                LocalPlayer.Character.Humanoid.WalkSpeed = SavedWalkSpeed + 2
                                LocalPlayer.Character.Humanoid.Sit = false
                                LocalPlayer.Character.Torso.Anchored = false
                            end
                        end
                    end
                )
                if not States.Annoy or not PLR then
                    break
                end
            end
        end
    )
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    States.Annoy = false
end

function Fling(Player, isSuperFling)
    pcall(
        function()
            if Player == LocalPlayer then
                BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                if isSuperFling == false then
                    BodyVelocity.Velocity = Vector3.new(500, 500, 500)
                elseif isSuperFling == true then
                    BodyVelocity.Velocity = Vector3.new(999, 999, 999)
                end
                task.wait(1 / 10)
                BodyVelocity:Destroy()
            else
                SavePos()
                Loadchar()
                ItemHandler(workspace.Prison_ITEMS.single.Hammer.ITEMPICKUP)
                if LocalPlayer.Backpack:FindFirstChild("Hammer") then
                    ItemHandler(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
                end
                local CHAR = LocalPlayer.Character
                CHAR.Humanoid.Name = "1"
                local c = CHAR["1"]:Clone()
                c.Name = "Humanoid"
                c.Parent = CHAR
                CHAR["1"]:Destroy()
                Workspace.CurrentCamera.CameraSubject = CHAR
                CHAR.Animate.Disabled = true
                task.wait(0.03)
                CHAR.Animate.Disabled = false
                CHAR.Humanoid.DisplayDistanceType = "None"
                local tool = LocalPlayer.Backpack:FindFirstChild("Hammer") or LocalPlayer.Backpack:FindFirstChild("M9")
                tool.Parent = CHAR
                local STOP = 0
                repeat
                    STOP = STOP + 1
                    LocalPlayer.Character:SetPrimaryPartCFrame(Player.Character.Head.CFrame * CFrame.new(0, 0, 0.75))
                    task.wait(0.03)
                until (not LocalPlayer.Character:FindFirstChild("M9") and
                    not LocalPlayer.Character:FindFirstChild("Hammer") or
                    not LocalPlayer.Character.HumanoidRootPart or
                    not Player.Character.HumanoidRootPart or
                    not LocalPlayer.Character or
                    not Player.Character or
                    STOP > 500) and
                    STOP > 3
                LocalPlayer.Character.HumanoidRootPart.Anchored = false

                local BodyVelocity = Instance.new("BodyVelocity", Player.Character.HumanoidRootPart)

                BodyVelocity.MaxForce = Vector3.new(9999999, 9999999, 9999999)
                if isSuperFling == false then
                    BodyVelocity.Velocity = Vector3.new(500, 500, 500)
                elseif isSuperFling == true then
                    BodyVelocity.Velocity = Vector3.new(999, 999, 999)
                end
                task.wait(1 / 10)
                BodyVelocity:Destroy()
                task.wait(1 / 5)
                Loadchar()
                LoadPos()
            end
        end
    )
end

function LagServer(Strength)
    States.LagServer = true
    local Events = {}
    for i = 1, 100 do
        Events[#Events + 1] = {
            Hit = workspace:FindFirstChildOfClass("Part"),
            Cframe = CFrame.new(),
            Distance = math.huge,
            RayObject = Ray.new(Vector3.new(), Vector3.new())
        }
    end
    while task.wait(0.03) do
        if not States.LagServer then
            break
        end
        task.wait(1 / 10)
        ItemHandler(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)
        pcall(
            function()
                local Gun = LocalPlayer.Backpack:FindFirstChild("Remington 870")
                for i = 1, Strength do
                    rStorage.ShootEvent:FireServer(Events, Gun)
                end
            end
        )
        task.wait(1)
    end
    States.LagServer = false
end

function SaveWayPoint(POS, Name)
    if not POS or not Name then
        return
    end
    SavedWaypoints[Name] = {X = POS.X, Y = POS.Y, Z = POS.Z}
    pcall(
        function()
            local Encoded = HttpService:JSONEncode(SavedWaypoints)
            writefile("WrathAdminSavedWayPoints.json", Encoded)
        end
    )
end

function ToBoolean(STRING)
    return STRING:lower() == "true"
end

function LogSpam(Message)
    local ChatMain = require(LocalPlayer.PlayerScripts.ChatScript.ChatMain)

    States.LogSpam = true

    local function GenerateString(Length)
        local Possible = "QWERTYUIOPASDFGKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890"
        local Characters = {}
        local Output = ""
        Possible:gsub(
            ".",
            function(v)
                table.insert(Characters, v)
            end
        )
        for i = 1, Length do
            local RandomChar = math.random(1, #Characters)
            Output = Output .. Characters[RandomChar]
        end
        return Output
    end

    while task.wait(0.03) do
        if Message then
            ChatMain.MessagePosted:fire(Message)
        else
            local Random = GenerateString(math.random(10, 20))
            ChatMain.MessagePosted:fire(Random)
        end
        if not States.LogSpam then
            break
        end
    end
end

function MeleeKill(PLR)
    if LocalPlayer.Character and PLR.Character then
        local MyHead = LocalPlayer.Character:FindFirstChild("Head")
        local TheirHead = PLR.Character:FindFirstChild("Head")
        if MyHead and TheirHead then
            LocalPlayer.Character:SetPrimaryPartCFrame(TheirHead.CFrame * CFrame.new(0, 0, 1))
            pcall(
                function()
                    LocalPlayer.Character.Humanoid.Sit = false
                end
            )
        end
    end
    task.wait(0.15)
    for i = 1, 30 do
        MeleeEvent(PLR)
    end
end

function FPSBoost()
    game.Lighting.Brightness = 30
    for i, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Anchored ~= true and not Players:GetPlayerFromCharacter(v.Parent) then
                v:Destroy()
            else
                v.Material = Enum.Material.Plastic
            end
            v:GetPropertyChangedSignal("Anchored"):Connect(
                function()
                    if v.Anchored ~= true then
                        v:Destroy()
                    end
                end
            )
        end
        if v:IsA("Decal") then
            v:Destroy()
        end
    end
    workspace.DescendantAdded:Connect(
        function(PART)
            if PART:IsA("BasePart") and not Players:GetPlayerFromCharacter(PART.Parent) then
                if PART.Anchored ~= true then
                    PART:Destroy()
                else
                    PART.Material = Enum.Material.Plastic
                end
                PART:GetPropertyChangedSignal("Anchored"):Connect(
                    function()
                        if PART.Anchored ~= true then
                            PART:Destroy()
                        end
                    end
                )
            end
            if PART:IsA("Decal") then
                PART:Destroy()
            end
        end
    )
end

function GetClosestPlayerToPosition(Position)
    local Max, Closest = math.huge
    for i, v in pairs(Players:GetPlayers()) do
        if v.Character then
            local Tool = v.Character:FindFirstChildOfClass("Tool") or v.Backpack:FindFirstChildOfClass("Tool")
            if Tool then
                local ShootPart = Tool:FindFirstChild("Muzzle")
                local PrimaryPart = v.Character.PrimaryPart
                if PrimaryPart and ShootPart then
                    local Distance = (ShootPart.Position - Position).Magnitude
                    if Distance < Max then
                        Max = Distance
                        Closest = v
                    end
                end
            end
        end
    end

    return Closest
end

function ClosestCharacter(MaxDistance)
    local Max, Closest = MaxDistance or math.huge
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local Head = game.FindFirstChild(v.Character, "Head")
            if Head then
                local Pos = Head.Position
                if LocalPlayer.Character.PrimaryPart then
                    local Distance = (Pos - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                    if Distance < Max then
                        Max = Distance
                        Closest = v.Character
                    end
                end
            end
        end
    end
    return Closest
end

function SpeedKill(Tables)
    local Events = {}

    for i, v in next, Tables do
        if v.Character then
            if v.TeamColor == LocalPlayer.TeamColor and not States.AntiCriminal and States.AutoTeamChange then
                SavePos()
                Loadchar(BrickColor.random().Name)
                LoadPos()
            end
            for i = 1, 10 do
                Events[#Events + 1] = {
                    Hit = v.Character:FindFirstChildOfClass("Part"),
                    Cframe = CFrame.new(),
                    RayObject = Ray.new(Vector3.new(), Vector3.new()),
                    Distance = 0
                }
            end
        end
    end

    ItemHandler(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)

    pcall(
        function()
            local Gun =
                LocalPlayer.Backpack:FindFirstChild("Remington 870") or
                LocalPlayer.Character:FindFirstChild("Remington 870")
            Gun.GunInterface:Destroy()
            Gun.Parent = LocalPlayer.Character
            WhitelistItem(Gun)

            rStorage.ShootEvent:FireServer(Events, Gun)

            LocalPlayer.Character["Remington 870"]:Destroy()
        end
    )
end

function CheckKeycode(Key)
    local Result
    pcall(
        function()
            Result = Enum.KeyCode[Key]
        end
    )
    return Result
end

function ArmorSpam(Num)
    States.ArmorSpam = true
    while task.wait() do
        for i = 1, Num do
            pcall(
                coroutine.wrap(
                    function()
                        workspace.Remote.ItemHandler:InvokeServer(
                            workspace.Prison_ITEMS.clothes["Riot Police"].ITEMPICKUP
                        )
                    end
                )
            )
        end
        if not States.ArmorSpam then
            break
        end
    end
    States.ArmorSpam = false
end

function UseCommand(MESSAGE)
    local Args = MESSAGE:split(" ")

    if not Args[1] then
        return
    end

    if Args[1] == "/e" then
        table.remove(Args, 1)
    end

    if Args[1] == "/w" then
        table.remove(Args, 1)
        if Args[2] then
            table.remove(Args, 1)
        end
    end

    if Args[1]:sub(1, 1) ~= Settings.Prefix then
        return
    end

    local CommandName = Args[1]:sub(2)

    local function CMD(NAME)
        return NAME == CommandName:lower()
    end

    --// Commands
    if CMD("cmds") then
        ToggleCmds()
        Notify("Success", "Toggled commands.", 2)
    end
    if CMD("output") or CMD("logs") then
        ToggleOutput()
        Notify("Success", "Toggled output / logs.", 2)
    end
    if CMD("bring") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            if LocalPlayer.Character then
                if LocalPlayer.Character.PrimaryPart then
                    Teleport(Player, LocalPlayer.Character.PrimaryPart.CFrame)
                    Notify("Success", "Brought " .. Player.Name .. ".")
                end
            end
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("goto") or CMD("to") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            if Player.Character then
                if Player.Character.PrimaryPart then
                    Teleport(LocalPlayer, Player.Character.PrimaryPart.CFrame)
                    Notify("Success", "Teleported to " .. Player.Name .. ".", 2)
                end
            end
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("nexus") or CMD("nex") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(888, 100, 2388))
            Notify("Success", "Teleported " .. Player.Name .. " to Nexus.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("rj") or CMD("rejoin") then
        Notify("Success", "Rejoining...", 2)
        getgenv().Rejoining = true
        Rejoin("Rejoin Detected")
    end
    if CMD("auto") then
        States.AutoRespawn = not States.AutoRespawn
        if LocalPlayer.Character then
            AutoRespawnCharacterAdded(LocalPlayer.Character)
        end
        pcall(
            function()
                if LocalPlayer.Character.Humanoid.Health <= 0 then
                    SavePos()
                    Loadchar()
                    LoadPos()
                end
            end
        )
        ChangeGuiToggle(States.AutoRespawn, "Auto-Respawn")
        Notify("Success", "Togged auto respawn to " .. tostring(States.AutoRespawn) .. ".")
    end
    if CMD("atc") or CMD("autoteamchange") then
        States.AutoTeamChange = not States.AutoTeamChange
        ChangeGuiToggle(States.AutoTeamChange, "Auto Team Change")
        Notify("Success", "Togged auto team change to " .. tostring(States.AutoTeamChange) .. ".")
    end
    if CMD("kill") then
        Args[2] = Args[2]:lower()
        local First, Rest = Args[2]:sub(1, 1):upper(), Args[2]:sub(2)
        local Team = First .. Rest

        if Args[2] == "all" then
            KillPlayers(Players)
            Notify("Success", "Killed all.", 2)
        elseif Teams:FindFirstChild(Team) then
            KillPlayers(Teams[Team])
            Notify("Success", "Killed " .. Team .. ".", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Kill({Player})
                Notify("Success", "Killed " .. Player.Name .. ".")
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("lk") then
        if Args[2] == "all" then
            States.KillAll = true
            Notify("Success", "Now loop-killing everyone.", 2)
        elseif Args[2] == "guards" or Args[2] == "g" then
            States.KillGuards = true
            Notify("Success", "Now loop-killing Guards.", 2)
        elseif Args[2] == "inmates" or Args[2] == "i" then
            States.KillInmates = true
            Notify("Success", "Now loop-killing Inmates.", 2)
        elseif Args[2] == "criminals" or Args[2] == "c" then
            States.KillCriminals = true
            Notify("Success", "Now loop-killing Criminals.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Loopkilling[Player.UserId] = Player
                Notify("Success", "Loop-killing " .. Player.Name .. ".")
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("unlk") then
        if Args[2] == "all" then
            States.KillAll = false
            States.KillGuards = false
            States.KillInmates = false
            States.KillCriminals = false
            Loopkilling = {}
            Notify("Success", "Unloop-killed everyone.", 2)
        elseif Args[2] == "guard" or Args[2] == "guards" then
            States.KillGuards = false
            for i, v in pairs(Teams.Guards:GetPlayers()) do
                Loopkilling[v.UserId] = nil
            end
            Notify("Success", "Unloop-killed Guards.", 2)
        elseif Args[2] == "inmates" or Args[2] == "inmate" then
            States.KillInmates = false
            for i, v in pairs(Teams.Inmates:GetPlayers()) do
                Loopkilling[v.UserId] = nil
            end
            Notify("Success", "Unloop-killed Inmates.", 2)
        elseif Args[2] == "criminals" or Args[2] == "crims" then
            States.KillCriminals = false
            for i, v in pairs(Teams.Criminals:GetPlayers()) do
                Loopkilling[v.UserId] = nil
            end
            Notify("Success", "Unloop-killed Criminals.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Loopkilling[Player.UserId] = nil
                Notify("Success", "Unloop-killed " .. Player.Name .. ".", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("clk") or CMD("clearloopkills") then
        States.KillAll = false
        States.KillGuards = false
        States.KillInmates = false
        States.KillCriminals = false
        States.MeleeAll = false
        States.SpeedKillAll = false
        States.SpeedKillGuards = false
        States.SpeedKillInmates = false
        States.SpeedKillCriminals = false
        MeleeKilling = {}
        Loopkilling = {}
        SpeedKilling = {}
        Notify("Success", "Cleared all loop-kills.", 2)
    end
    if CMD("view") then
        pcall(
            function()
                CurrentlyViewing.Connection:Disconnect()
            end
        )
        CurrentlyViewing = {Player = GetPlayer(Args[2], LocalPlayer), Connection = nil}
        if CurrentlyViewing.Player then
            local function ViewerAdded(CHAR)
                Camera.CameraSubject = CHAR
            end
            if CurrentlyViewing.Player.Character then
                ViewerAdded(CurrentlyViewing.Player.Character)
            end
            CurrentlyViewing.Connection = CurrentlyViewing.Player.CharacterAdded:Connect(ViewerAdded)
            Notify("Success", "Now viewing: " .. CurrentlyViewing.Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("unview") then
        pcall(
            function()
                CurrentlyViewing.Connection:Disconnect()
                CurrentlyViewing = nil
            end
        )
        if LocalPlayer.Character then
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
        Notify("Success", "Stopped viewing.", 2)
    end
    if CMD("gun") or CMD("guns") or CMD("allguns") then
        GiveGuns()
        Notify("Success", "Obtained all guns.", 2)
    end
    if CMD("team") or CMD("t") then
        -- :team 255 255 255 = white
        SavePos()
        if not Args[4] then
            if Args[2] == "inmates" or Args[2] == "i" then
                TeamEvent("Bright orange")
                Notify("Success", "Changed team to Inmates.", 2)
            elseif Args[2] == "guards" or Args[2] == "g" then
                Loadchar("Bright blue")
                Notify("Success", "Changed team to Guards.", 2)
            elseif Args[2] == "criminals" or Args[2] == "c" then
                Loadchar("Really red")
                Notify("Success", "Changed team to Criminals.", 2)
            elseif Args[2] == "neutral" then
                TeamEvent("Medium stone grey")
                Notify("Success", "Changed team to Neutral.", 2)
            elseif Args[2] == "random" or Args[2] == "r" then
                local RandomColor = BrickColor.random().Name
                Loadchar(RandomColor)
                Notify("Success", "Changed team to " .. RandomColor .. ".", 2)
            elseif CustomColors[Args[2]] then
                local R, G, B = CustomColors[Args[2]][1], CustomColors[Args[2]][2], CustomColors[Args[2]][3]
                Loadchar(Color3.fromRGB(R, G, B))
                Notify("Success", "Changed team to " .. Args[2] .. ".", 2)
            end
        else
            local R, G, B = tonumber(Args[2]), tonumber(Args[3]), tonumber(Args[4])
            if R and G and B then
                Loadchar(Color3.fromRGB(R, G, B))
                Notify(
                    "Success",
                    "Changed team to " .. tostring(R) .. ", " .. tostring(G) .. ", " .. tostring(B) .. ".",
                    2
                )
            end
        end
        LoadPos()
    end
    if CMD("aguns") then
        States.AutoGuns = true
        Notify("Success", "Enabled auto-guns", 2)
        GiveGuns()
    end
    if CMD("unaguns") then
        States.AutoGuns = false
        Notify("Success", "Disabled auto-guns", 2)
    end
    if CMD("shield") then
        task.wait(1 / 10)
        if CheckOwnedGamepass() then
            if Args[2] == "all" then
                for i, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer then
                        Give(v, "Riot Shield", true, "Bright blue")
                    end
                end
            elseif Args[2] == "guards" then
                for i, v in pairs(Teams.Guards:GetPlayers()) do
                    if v ~= LocalPlayer then
                        Give(v, "Riot Shield", true, "Bright blue")
                    end
                end
            elseif Args[2] == "inmates" then
                for i, v in pairs(Teams.Inmates:GetPlayers()) do
                    if v ~= LocalPlayer then
                        Give(v, "Riot Shield", true, "Bright blue")
                    end
                end
            elseif Args[2] == "criminals" then
                for i, v in pairs(Teams.Criminals:GetPlayers()) do
                    if v ~= LocalPlayer then
                        Give(v, "Riot Shield", true, "Bright blue")
                    end
                end
            else
                local Player = GetPlayer(Args[2], LocalPlayer)
                if Player then
                    Notify("Success", "Gave riot shield to " .. Player.Name .. ".", 2)
                    Give(Player, "Riot Shield", true, "Bright blue")
                else
                    Notify("Error", Args[2] .. " is not a valid player.", 2)
                end
            end
        else
            Notify("Error", "You don't own the gamepass.", 2)
        end
    end
    if CMD("giveshotty") or CMD("shotty") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            task.wait(1 / 10)
            Give(Player, "Remington 870", true, nil)
            Notify("Success", "Gave Remington 870 to " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("giveak") or CMD("ak") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            task.wait(1 / 10)
            Give(Player, "AK-47", true, nil)
            Notify("Success", "Gave AK-47 to " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("givem9") or CMD("m9") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            task.wait(1 / 10)
            Give(Player, "M9", true, nil)
            Notify("Success", "Gave M9 to " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("givem4") or CMD("m4") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            task.wait(1 / 10)
            if CheckOwnedGamepass() then
                Give(Player, "M4A1", true, nil)
                Notify("Success", "Gave M4A1 to " .. Player.Name .. ".", 2)
            else
                Notify("Error", "You don't own the gamepass.", 2)
            end
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("givehammer") or CMD("hammer") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            task.wait(1 / 10)
            Give(Player, "Hammer", false, nil)
            Notify("Success", "Gave Hammer to " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("giveknife") or CMD("knife") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            task.wait(1 / 10)
            Give(Player, "Crude Knife", false, nil)
            Notify("Success", "Gave Knife to " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("givekeycard") or CMD("keycard") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            task.wait(1 / 10)
            Keycard(Player)
            Notify("Success", "Gave Key card to " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("givehandcuffs") or CMD("handcuffs") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Notify("Success", "Gave handcuffs to " .. Player.Name .. ".", 2)
            Give(Player, "Handcuffs", false, "Bright blue", true)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("givetaser") or CMD("taser") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Notify("Success", "Gave taser to " .. Player.Name .. ".", 2)
            Give(Player, "Taser", false, "Bright blue", true)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("armor") then
        if CheckOwnedGamepass() then
            SavePos()
            local SavedTeam = LocalPlayer.TeamColor.Name
            if #Teams.Guards:GetChildren() > 8 then
                Loadchar("Bright blue")
            else
                TeamEvent("Bright blue")
            end
            ItemHandler(workspace.Prison_ITEMS.clothes["Riot Police"].ITEMPICKUP)
            if SavedTeam == "Bright orange" or SavedTeam == "Medium stone grey" then
                TeamEvent("Bright orange")
            end
            LoadPos()
            Notify("Success", "Obtained riot armor.", 2)
        else
            Notify("Error", "You don't own the gamepass.", 2)
        end
    end
    if CMD("sa") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Notify("Success", "Spam arresting: " .. Player.Name, 5)
            States.SpamArresting = true
            task.spawn(
                function()
                    while true do
                        if not States.SpamArresting or not Player or not Players:FindFirstChild(Player.Name) then
                            break
                        end
                        task.spawn(ArrestEvent, Player, 40)
                        task.wait(0.03)
                    end
                end
            )
            task.spawn(
                function()
                    while true do
                        if Player.TeamColor.Name ~= "Really red" and Player.TeamColor.Name ~= "Bright orange" then
                            pcall(
                                function()
                                    coroutine.wrap(firetouchinterest)(
                                        Player.Character.Head,
                                        game.Lighting:FindFirstChild("SpawnLocation"),
                                        0
                                    )
                                end
                            )
                        end
                        rService.Heartbeat:wait()
                    end
                end
            )
            while true do
                if not States.SpamArresting or not Player or not Players:FindFirstChild(Player.Name) then
                    break
                end
                if Player.TeamColor.Name ~= "Really red" then
                    if Player.TeamColor.Name == "Bright orange" then
                        if IllegalRegion(Player) then
                            pcall(
                                function()
                                    LocalPlayer.Character:SetPrimaryPartCFrame(
                                        Player.Character.Head.CFrame * CFrame.new(0, 0, 1)
                                    )
                                end
                            )
                        else
                            Teleport(Player, CFrame.new(984, 100, 2268))
                        end
                    else
                        Crim(Player, true)
                    end
                else
                    pcall(
                        function()
                            LocalPlayer.Character:SetPrimaryPartCFrame(
                                Player.Character.Head.CFrame * CFrame.new(0, 0, 1)
                            )
                        end
                    )
                end
                rService.Heartbeat:wait()
            end
            task.spawn(
                function()
                    while task.wait(0.03) do
                        for i, v in pairs(workspace:GetChildren()) do
                            if v.Name == "SpawnLocation" then
                                v.Parent = game.Lighting
                            end
                        end
                        if not workspace:FindFirstChild("SpawnLocation") then
                            break
                        end
                    end
                end
            )
            Notify("Success", "Finished spam arrest", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("unsa") or CMD("breaksa") then
        States.SpamArresting = false
        Notify("Success", "Now stopping spam arrest...", 2)
    end
    if CMD("arrest") then
        SavePos()
        local Player = GetPlayer(Args[2], LocalPlayer)
        local Times = tonumber(Args[3])
        Times = Times or 1
        if Player then
            Arrest(Player, Times)
            Notify("Success", "Arrested " .. Player.Name .. ".", 2)
        elseif Args[2] == "all" then
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and CheckProtected(v, "arrestcmds") then
                    if (v.TeamColor.Name == "Bright orange" and IllegalRegion(v)) or v.TeamColor.Name == "Really red" then
                        Arrest(v, Times)
                    end
                end
            end
            Notify("Success", "Arrested everyone.", 2)
        elseif not Player then
            Notify("Error", Args[2] .. " is not a valid player / team.", 2)
        end
        for i = 1, 10 do
            LoadPos()
            task.wait()
        end
    end
    if CMD("crim") then
        if Args[2] == "all" then
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.TeamColor.Name ~= "Really red" and CheckProtected(v, "tpcmds") then
                    Crim(v, false)
                end
            end
        elseif Args[2] == "inmates" then
            for i, v in pairs(Teams.Inmates:GetPlayers()) do
                if v ~= LocalPlayer and v.TeamColor.Name ~= "Really red" and CheckProtected(v, "tpcmds") then
                    Crim(v, false)
                end
            end
        elseif Args[2] == "guards" then
            for i, v in pairs(Teams.Guards:GetPlayers()) do
                if v ~= LocalPlayer and v.TeamColor.Name ~= "Really red" and CheckProtected(v, "tpcmds") then
                    Crim(v, false)
                end
            end
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Crim(Player, false)
                Notify("Success", "Changed " .. Player.Name .. "'s team to Criminal.", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("virus") or CMD("infect") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Infected[Player.UserId] = Player
            Notify("Success", "Infected " .. Player.Name .. ".", 2)
        elseif Args[2] == "all" then
            for i, v in pairs(Players:GetPlayers()) do
                Infected[v.UserId] = v
            end
            Notify("Success", "Started a pandemic.", 2)
        elseif not Player then
            Notify("Error", Args[2] .. " is not a valid player / team.", 2)
        else
            Args[2] = Args[2]:lower()
            local First, Rest = Args[2]:sub(1, 1):upper(), Args[2]:sub(2)
            local Team = First .. Rest
            local Success, Error =
                pcall(
                function()
                    for i, v in pairs(Teams[Team]:GetPlayers()) do
                        Infected[v.UserId] = v
                    end
                end
            )
            if Success then
                Notify("Success", "Infected everyone in the " .. Team .. " team.")
            end
        end
    end
    if CMD("unvirus") or CMD("rvirus") or CMD("cure") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Infected[Player.UserId] = nil
            Notify("Success", "Cured " .. Player.Name .. ".", 2)
        elseif Args[2] == "all" then
            Infected = {}
            Notify("Success", "Cured everyone.", 2)
        elseif not Player then
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("ka") or CMD("killaura") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            KillAuras[Player.UserId] = Player
            Notify("Success", "Gave " .. Player.Name .. " kill aura.", 2)
        elseif Args[2] == "all" then
            for i, v in pairs(Players:GetPlayers()) do
                KillAuras[v.UserId] = v
            end
            Notify("Success", "Gave everyone kill aura.", 2)
        elseif not Player then
            Notify("Error", Args[2] .. " is not a valid player / team.", 2)
        else
            Args[2] = Args[2]:lower()
            local First, Rest = Args[2]:sub(1, 1):upper(), Args[2]:sub(2)
            local Team = First .. Rest
            local Success, Error =
                pcall(
                function()
                    for i, v in pairs(Teams[Team]:GetPlayers()) do
                        KillAuras[v.UserId] = v
                    end
                end
            )
            if Success then
                Notify("Success", "Gave the " .. Team .. " kill aura.", 2)
            end
        end
    end
    if CMD("unka") or CMD("unkillaura") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            KillAuras[Player.UserId] = nil
            Notify("Success", "Removed " .. Player.Name .. "'s kill aura.", 2)
        elseif Args[2] == "all" then
            KillAuras = {}
            Notify("Success", "Removed everyone's kill aura.", 2)
        else
            Args[2] = Args[2]:lower()
            local First, Rest = Args[2]:sub(1, 1):upper(), Args[2]:sub(2)
            local Team = First .. Rest
            local Success, Error =
                pcall(
                function()
                    for i, v in pairs(Teams[Team]:GetPlayers()) do
                        KillAuras[v.UserId] = nil
                    end
                end
            )
            if Success then
                Notify("Success", "Removed the " .. Team .. "'s kill aura.", 2)
            end
        end
    end
    if CMD("clv") or CMD("clearvirus") then
        Infected = {}
        Notify("Success", "Cleared infected", 2)
    end
    if CMD("yard") or CMD("yar") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(791, 98, 2498))
            Notify("Success", "Teleported " .. Player.Name .. " to yard.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("back") or CMD("bac") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(984, 100, 2318))
            Notify("Success", "Teleported " .. Player.Name .. " to back nexus.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("armory") or CMD("arm") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(837, 100, 2266))
            Notify("Success", "Teleported " .. Player.Name .. " to armory.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("tower") or CMD("tow") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(823, 130, 2588))
            Notify("Success", "Teleported " .. Player.Name .. " to tower.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("base") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-943, 94, 2056))
            Notify("Success", "Teleported " .. Player.Name .. " to base.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("cafe") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(930, 100, 2289))
            Notify("Success", "Teleported " .. Player.Name .. " to cafe.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("kit") or CMD("kitchen") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(919, 100, 2230))
            Notify("Success", "Teleported " .. Player.Name .. " to kitchen.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("snack") or CMD("vending") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(949.114136, 101.051971, 2339.53491))
            Notify("Success", "Teleported " .. Player.Name .. " to vending machine.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("vent") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(934, 124, 2224, .05, -4, -1, 3.4, 1, -3.618, 0.99849242, 3.1288, 0.054))
            Notify("Success", "Teleported " .. Player.Name .. " to vent.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end

    if CMD("slide") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(506.08721923828, 624.0092773457, 3430.0368652344))
            Notify("Success", "Teleported " .. Player.Name .. " to slide.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("drop") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-50, -50, -100))
            Notify("Success", "Teleported " .. Player.Name .. " to drop.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("oob") or CMD("mountain") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(525.90008544922, 337.92767333984, 3348.3315429688))
            Notify("Success", "Teleported " .. Player.Name .. " to oob / mountain.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("ref") or CMD("fridge") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(869, 100.988, 2225.998))
            Notify("Success", "Teleported " .. Player.Name .. " to refrigerator.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("oven") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(915.3, 98.69, 2210.097))
            Notify("Success", "Teleported " .. Player.Name .. " to oven.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end

    if CMD("chillout") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-329, 70, 1829))
            Notify("Success", "Teleported " .. Player.Name .. " to chillout place.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end

    if CMD("base2") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-932, 100, 1992))
            Notify("Success", "Teleported " .. Player.Name .. " to base 2.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end

    if CMD("base3") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-926, 99, 1916))
            Notify("Success", "Teleported " .. Player.Name .. " to base 3.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end

    if CMD("sewer") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(916.799, 82.279, 2270.599))
            Notify("Success", "Teleported " .. Player.Name .. " to sewer.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end

    if CMD("container") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(266.54, 70.3, 2358.106))
            Notify("Success", "Teleported " .. Player.Name .. " to container.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end

    if CMD("escape") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(318.416748, 75.5779572, 2220.01953))
            Notify("Success", "Teleported " .. Player.Name .. " to escape.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("secretroom") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(697, 97.492, 2364))
            Notify("Success", "Teleported " .. Player.Name .. " to secret room.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("undermap") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(
                Player,
                CFrame.new(
                    800.317993,
                    10.8322506,
                    1473.46497,
                    -0.999664009,
                    -3.23824279e-05,
                    -0.025924176,
                    -3.24961984e-05,
                    1,
                    3.96724363e-06,
                    0.025924176,
                    4.80833751e-06,
                    -0.999664009
                )
            )
            Notify("Success", "Teleported " .. Player.Name .. " to secret spot under map.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("toilet") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(959.131958, 96.6899796, 2444.74927))
            Notify("Success", "Teleported " .. Player.Name .. " to toilet.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("trash") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(365.445374, 10.7605114, 1100.21265))
            Notify("Success", "Teleported " .. Player.Name .. " to dumpster.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("policecar") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(615.645264, 98.2000275, 2514.97485))
            Notify("Success", "Teleported " .. Player.Name .. " to police car spawner.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("busstop") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-376.442291, 54.2000923, 1723.72534))
            Notify("Success", "Teleported " .. Player.Name .. " to bus stop.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("store") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(434.462921, 11.4253635, 1183.47156))
            Notify("Success", "Teleported " .. Player.Name .. " to store.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("bridge") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-81.0300827, 11.099329, 1311.87549))
            Notify("Success", "Teleported " .. Player.Name .. " to bridge.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("station") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-512.839172, 54.3937874, 1666.99426))
            Notify("Success", "Teleported " .. Player.Name .. " to gas station.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("hiddenplace") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(-568.503418, 10.8399124, 1414.12463))
            Notify("Success", "Teleported " .. Player.Name .. " to hidden place.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("roof") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(827.423523, 118.990005, 2329.62598))
            Notify("Success", "Teleported " .. Player.Name .. " to roof.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("gate") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(503.799866, 102.03994, 2252.01831))
            Notify("Success", "Teleported " .. Player.Name .. " to gate.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("cel") or CMD("cells") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(917, 100, 2444))
            Notify("Success", "Teleported " .. Player.Name .. " to prison cells area.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("re") then
        SavePos()
        Loadchar()
        LoadPos()
    end
    if CMD("anticrim") or CMD("ac") then
        States.AntiCriminal = not States.AntiCriminal
        ChangeGuiToggle(States.AntiCriminal, "Anti-Criminal")
        Notify("Success", "Toggled anti-crim to " .. tostring(States.AntiCriminal) .. ".", 2)
    end
    if CMD("af") or CMD("autofire") then
        if LocalPlayer.Character then
            local Tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if Tool then
                if Tool:FindFirstChild("GunStates") then
                    EditStat(Tool, "AutoFire", true)
                    Notify("Success", "Enabled autofire on: " .. Tool.Name .. ".", 2)
                else
                    Notify("Success", "You aren't holding a gun.", 2)
                end
            else
                Notify("Error", "Unable to find gun (you must equip it).", 2)
            end
        end
    end
    if CMD("ab") or CMD("antibring") then
        States.AntiBring = not States.AntiBring
        ChangeGuiToggle(States.AntiBring, "Anti-Bring")
        Notify("Success", "Toggled anti-bring to " .. tostring(States.AntiBring) .. ".", 2)
    end
    if CMD("nodoors") then
        local Success, Error =
            pcall(
            function()
                workspace:FindFirstChild("Doors").Parent = game.Lighting
                workspace:FindFirstChild("Prison_Cellblock"):FindFirstChild("doors").Parent = game.Lighting
            end
        )
        if Success then
            Notify("Success", "Removed doors.", 2)
        end
    end
    if CMD("doors") or CMD("redoors") then
        local Success, Error =
            pcall(
            function()
                game.Lighting:FindFirstChild("Doors").Parent = workspace
                game.Lighting:FindFirstChild("doors").Parent = workspace
            end
        )
        if Success then
            Notify("Success", "Restored doors.", 2)
        end
    end
    if CMD("aa") or CMD("arrestaura") then
        States.ArrestAura = not States.ArrestAura
        Notify("Success", "Toggled arrest aura to " .. tostring(States.ArrestAura) .. ".", 2)
    end
    if CMD("antifling") or CMD("afling") then
        States.AntiFling = not States.AntiFling
        ChangeGuiToggle(States.AntiFling, "Anti-Fling")
        Notify("Success", "Toggled anti-fling to " .. tostring(States.AntiFling) .. ".", 2)
    end
    if CMD("annoy") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player and not States.Annoy then
            Notify("Success", "Annoying " .. Player.Name .. ".", 2)
            coroutine.wrap(Annoy)(Player)
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("unannoy") then
        States.Annoy = false
        Notify("Success", "Stopped annoying.", 2)
    end
    if CMD("def") or CMD("defenses") then
        Notify("Success", "Enabled all defenses.", 2)
        for i, v in pairs(getconnections(rStorage.ReplicateEvent.OnClientEvent)) do
            v:Disable()
        end
        States.AntiBring = true
        States.AntiFling = true
        States.AntiCriminal = true
        States.AntiPunch = true
        States.AntiCrash = true
        States.ShootBack = false
        States.TaseBack = false
        ChangeGuiToggle(States.AntiBring, "Anti-Bring")
        ChangeGuiToggle(States.AntiFling, "Anti-Fling")
        ChangeGuiToggle(States.AntiCriminal, "Anti-Criminal")
        ChangeGuiToggle(States.AntiPunch, "Anti-Punch")
        ChangeGuiToggle(States.AntiCrash, "Anti-Crash")
        ChangeGuiToggle(false, "Shoot Back")
        ChangeGuiToggle(false, "Tase Back")
        if #Teams.Guards:GetPlayers() >= 8 then
            SavePos()
            Loadchar("Bright blue")
            LoadPos()
        else
            TeamEvent("Bright blue")
        end
    end
    if CMD("undef") or CMD("undefenses") then
        Notify("Success", "Disabled all defenses.", 2)
        for i, v in pairs(getconnections(rStorage.ReplicateEvent.OnClientEvent)) do
            v:Enable()
        end
        States.AntiBring = false
        States.AntiFling = false
        States.AntiCriminal = false
        States.AntiPunch = false
        States.AntiCrash = false
        ChangeGuiToggle(States.AntiBring, "Anti-Bring")
        ChangeGuiToggle(States.AntiFling, "Anti-Fling")
        ChangeGuiToggle(States.AntiCriminal, "Anti-Criminal")
        ChangeGuiToggle(States.AntiPunch, "Anti-Punch")
        ChangeGuiToggle(States.AntiCrash, "Anti-Crash")
    end
    if CMD("protect") or CMD("p") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Protected[Player.UserId] = Player
            Notify("Success", "Protected " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("unprotect") or CMD("up") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Protected[Player.UserId] = nil
            Notify("Success", "Removed " .. Player.Name .. "'s protection.", 2)
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("clp") or CMD("clearprotected") then
        Protected = {}
        Notify("Success", "Cleared protected.", 2)
    end
    if CMD("nowalls") then
        local Success, Error =
            pcall(
            function()
                for i, v in next, Walls do
                    v.Parent = game.Lighting
                end
            end
        )
        if Success then
            Notify("Success", "Removed walls.", 2)
        end
    end
    if CMD("walls") then
        local Success, Error =
            pcall(
            function()
                for i, v in next, Walls do
                    v.Parent = workspace
                end
            end
        )
        if Success then
            Notify("Success", "Restored walls.", 2)
        end
    end
    if CMD("fling") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Fling(Player, false)
            Notify("Success", "Flung " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("sfling") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Fling(Player, true)
            Notify("Success", "Super flung " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("lag") then
        if not States.LagServer then
            local Strength = tonumber(Args[2]) or 10
            Notify("Success", "Lagging server with strength: " .. Args[2] .. ".", 2)
            coroutine.wrap(LagServer)(Strength)
        else
            Notify("Error", "You are already lagging the server - use unlag and try again.", 2)
        end
    end
    if CMD("unlag") then
        States.LagServer = false
        Notify("Success", "Stopped lagging server.", 2)
    end
    if CMD("rip") or CMD("crash") then
        local Events = {}
        task.wait(1 / 10)
        for i, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                for i = 1, 15 do
                    local origin, destination = LocalPlayer.Character.HumanoidRootPart.Position, v.Position
                    local distance, ray =
                        (origin - destination).Magnitude,
                        Ray.new(origin, (destination - origin).unit * 9e9)
                    local cf = CFrame.new(destination, origin) * CFrame.new(0, 0, -distance / 2)
                    Events[#Events + 1] = {
                        Hit = workspace:FindFirstChildOfClass("Part"),
                        Cframe = cf,
                        Distance = distance,
                        RayObject = ray
                    }
                end
            end
        end
        task.spawn(
            function()
                while task.wait() do
                    if LocalPlayer.Character then
                        task.spawn(
                            function()
                                ItemHandler(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
                            end
                        )
                        local Gun =
                            LocalPlayer.Backpack:FindFirstChild("AK-47") or
                            LocalPlayer.Character:FindFirstChild("AK-47")
                        if Gun then
                            rStorage.ShootEvent:FireServer(Events, Gun)
                        end
                    end
                end
            end
        )
    end
    if CMD("timeout") or CMD("spike") then
        local Events = {}
        task.wait(1 / 10)
        for i = 1, 100 do
            local origin, destination =
                LocalPlayer.Character.HumanoidRootPart.Position,
                workspace:FindFirstChildOfClass("Part").Position
            local distance, ray = (origin - destination).Magnitude, Ray.new(origin, (destination - origin).unit * 9e9)
            local cf = CFrame.new(destination, origin) * CFrame.new(0, 0, -distance / 2)
            Events[#Events + 1] = {
                Hit = v,
                Cframe = cf,
                Distance = distance,
                RayObject = ray
            }
        end
        task.spawn(
            function()
                while task.wait(0.03) do
                    if LocalPlayer.Character then
                        task.spawn(
                            function()
                                ItemHandler(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
                            end
                        )
                        pcall(
                            function()
                                local Gun =
                                    LocalPlayer.Backpack:FindFirstChild("AK-47") or
                                    LocalPlayer.Character:FindFirstChild("AK-47")
                                if Gun then
                                    rStorage.ShootEvent:FireServer(Events, Gun)
                                end
                            end
                        )
                    end
                end
            end
        )
    end
    if CMD("cars") or CMD("car") then
        SavePos()
        for i, v in pairs(workspace.Prison_ITEMS.buttons:GetDescendants()) do
            if v.Name == "Car Spawner" and v.ClassName == "Part" then
                workspace.Remote.ItemHandler:InvokeServer(v)
            end
        end
        task.wait(1 / 2)
        pcall(
            function()
                local SavedPosition = LocalPlayer.Character.Head.CFrame
                local TargetCar
                for i, v in pairs(workspace.CarContainer:GetChildren()) do
                    if v.Body.VehicleSeat.Occupant == nil then
                        TargetCar = v
                    end
                end
                --print(TargetCar)
                TargetCar.Body.VehicleSeat:Sit(LocalPlayer.Character.Humanoid)
                task.wait(1 / 5)
                TargetCar:MoveTo(SavedPosition.p)
                task.wait(1 / 5)
                TargetCar.Body.VehicleSeat:Sit(LocalPlayer.Character.Humanoid)
            end
        )
        LoadPos()
    end
    if CMD("ia") or CMD("infammo") then
        local Tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if Tool then
            if Tool:FindFirstChild("GunStates") then
                Notify("Success", "Enabled infinite ammo.", 2)
                local Stats = require(Tool.GunStates)
                Stats.MaxAmmo = math.huge
                Stats.CurrentAmmo = math.huge
                Stats.AmmoPerClip = math.huge
                Stats.StoredAmmo = math.huge
                AmmoGuns[#AmmoGuns + 1] = Tool
            else
                Notify("Error", "You aren't holding a gun.", 2)
            end
        else
            Notify("Success", "You must equip a tool.", 2)
        end
    end
    if CMD("aia") or CMD("autoinfammo") then
        States.AutoInfiniteAmmo = not States.AutoInfiniteAmmo
        Notify("Success", "Toggled auto inf ammo to " .. tostring(States.AutoInfiniteAmmo) .. ".", 2)
    end
    if CMD("aaf") or CMD("autoaf") then
        States.AutoAutoFire = not States.AutoAutoFire
        Notify("Success", "Toggled auto auto-fire to " .. tostring(States.AutoAutoFire) .. ".", 2)
    end
    if CMD("tp") then
        local Player, Player2 = GetPlayer(Args[2], LocalPlayer), GetPlayer(Args[3], LocalPlayer)
        if Player and Player2 then
            if Player ~= Player2 then
                if Player2.Character then
                    local Head = Player2.Character:FindFirstChild("Head")
                    if Head then
                        TeleportPlayers(Player, Player2)
                        Notify("Success", "Teleported " .. Player.Name .. " to " .. Player2.Name .. ".")
                    end
                end
            else
                Notify("Error", "You cannot do two of the same players.", 2)
            end
        else
            Notify("Error", "Not valid player(s).", 2)
        end
    end
    if CMD("clwp") or CMD("clearwaypoints") then
        SavedWaypoints = {}
        pcall(
            function()
                delfile("WrathAdminSavedWayPoints.json")
            end
        )
        Notify("Success", "Cleared waypoints", 2)
    end
    if CMD("wp") or CMD("setwaypoint") then
        pcall(
            function()
                if Args[2] then
                    SaveWayPoint(LocalPlayer.Character.Head.Position, Args[2])
                    Notify("Success", "Created waypoint: " .. Args[2], 2)
                end
            end
        )
    end
    if CMD("tw") or CMD("towaypoint") then
        local Saved = SavedWaypoints[Args[2]]
        if Saved then
            Teleport(LocalPlayer, CFrame.new(Saved.X, Saved.Y, Saved.Z))
            Notify("Success", "Teleported to waypoint: " .. Args[2], 2)
        else
            Notify("Error", "That is not a valid waypoint.", 2)
        end
    end
    if CMD("dwp") or CMD("deletewaypoint") then
        local Saved = SavedWaypoints[Args[2]]
        if Saved then
            SavedWaypoints[Args[2]] = nil
            pcall(
                function()
                    writefile("WrathAdminSavedWayPoints.json", HttpService:JSONEncode(SavedWaypoints))
                end
            )
            Notify("Success", "Deleted waypoint: " .. Args[2], 2)
        else
            Notify("Error", "That is not a valid waypoint.", 2)
        end
    end
    if CMD("admin") or CMD("rank") then
        if Args[2] == "all" then
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer then
                    Admins[v.UserId] = v
                end
            end
            Chat("!!! EVERYONE HAS ADMIN COMMANDS - say .cmds for a list of commands. !!!")
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Admins[Player.UserId] = Player
                Chat(
                    "/w " ..
                        Player.Name ..
                            " You have admin commands - say " .. Settings.Prefix .. "cmds to get a list of commands."
                )
                Notify("Success", "Gave " .. Player.Name .. " admin commands.", 2)
            else
                Notify("Error", Args[2] .. " isn't a valid player.", 2)
            end
        end
    end
    if CMD("unadmin") or CMD("unrank") then
        if Args[2] == "all" then
            Admins = {}
            Chat("!!! Everyone has been unranked. !!!")
            Notify("Success", "Removed everyone's admin commands.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Admins[Player.UserId] = nil
                Chat("/w " .. Player.Name .. " You have been unranked.")
                Notify("Success", "Removed " .. Player.Name .. "'s admin commands.", 2)
            else
                Notify("Error", Args[2] .. " isn't a valid player.", 2)
            end
        end
    end
    if CMD("cla") or CMD("clearadmins") then
        Admins = {}
        Notify("Success", "Cleared admins.", 2)
    end
    if CMD("void") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(0, 9e9, 0))
            Notify("Success", "Teleported " .. Player.Name .. " to the void.", 2)
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("trap") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Trapped[Player.UserId] = Player
            Notify(
                "Success",
                "Trapped " .. Player.Name .. ". Type " .. Settings.Prefix .. "untrap [plr] to free them.",
                2
            )
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("untrap") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Trapped[Player.UserId] = nil
            Teleport(Player, CFrame.new(888, 100, 2388))
            Notify("Success", "Untrapped " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("getinv") or CMD("getinvis") then
        print("====== INVISIBLE PLAYERS ======")
        for _, CHAR in pairs(workspace:GetChildren()) do
            if Players:FindFirstChild(CHAR.Name) then
                local Head = CHAR:FindFirstChild("Head")
                if Head then
                    if Head.Position.Y > 5000 or Head.Position.X > 99999 then
                        print(CHAR.Name .. " (" .. Players:FindFirstChild(CHAR.Name).DisplayName .. ")")
                    end
                end
            end
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see invisible players.", 2)
    end
    if CMD("getf") or CMD("getflings") then
        print("====== INVISIBLE FLINGERS ======")
        local ValidParts = {}
        for _, CHAR in pairs(workspace:GetChildren()) do
            if Players:FindFirstChild(CHAR.Name) then
                for _, object in pairs(CHAR:GetChildren()) do
                    ValidParts[object.Name] = object
                end
                if not ValidParts["Torso"] and not ValidParts["Head"] then
                    print(CHAR.Name .. " (" .. Players:FindFirstChild(CHAR.Name).DisplayName .. ")")
                end
                ValidParts = {}
            end
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see invisible flingers.", 2)
    end
    if CMD("geta") or CMD("getarmorspammers") then
        print("====== ARMOR SPAMMERS ======")
        for i, v in pairs(ArmorSpamFlags) do
            if v > 50 and Players:FindFirstChild(i) then
                print(i .. " (" .. Players:FindFirstChild(i).DisplayName .. ")")
            end
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see armor spammers.", 2)
    end
    if CMD("getlk") or CMD("getloopkills") then
        print("====== LOOPKILLING ======")
        for i, v in pairs(Loopkilling) do
            print(v.Name .. " (" .. v.DisplayName .. ")")
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see who are being loopkilled.", 2)
    end
    if CMD("getp") or CMD("getprotected") then
        print("====== PROTECTED ======")
        for i, v in pairs(Protected) do
            print(v.Name .. " (" .. v.DisplayName .. ")")
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see protected.", 2)
    end
    if CMD("bfling") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            if not States.BodyFling then
                coroutine.wrap(BodyFling)(Player)
                Notify("Success", "Body flung " .. Player.Name .. ".", 2)
            else
                Notify("Error", "You are already body flinging someone.", 2)
            end
        else
            Notify("Error", Args[2] .. " isn't a valid player.", 2)
        end
    end
    if CMD("psettings") or CMD("ps") then
        local Setting, Value = Args[2], ToBoolean(Args[3])
        if Setting and Value ~= nil then
            ProtectedSettings[Setting] = Value
            Notify("Success", "Set " .. Args[2] .. " to: " .. Args[3] .. ". (Protected Settings)", 2)
        end
        ChangeImmunityToggle(ProtectedSettings.killcmds, "Kill Commands")
        ChangeImmunityToggle(ProtectedSettings.tpcmds, "Teleport Commands")
        ChangeImmunityToggle(ProtectedSettings.arrestcmds, "Arrest Commands")
        ChangeImmunityToggle(ProtectedSettings.othercmds, "Other Commands")
    end
    if CMD("unbfling") then
        States.BodyFling = false
        Notify("Success", "Stopped body fling.", 2)
    end
    if CMD("getadmins") then
        print("====== ADMINS ======")
        for i, v in next, Admins do
            print(v.Name .. " (" .. v.DisplayName .. ")")
        end
        Notify("Success", "Type /console or F9 to see admins.", 2)
        print("====== END ======")
    end
    if CMD("getwpnames") or CMD("getwaypointnames") then
        print("====== WAYPOINTS ======")
        for i, v in next, SavedWaypoints do
            print(i .. ":", v.X, v.Y, v.Z)
        end
        Notify("Success", "Type /console or F9 to see waypoints.", 2)
        print("====== END ======")
    end
    if CMD("as") or CMD("asettings") then
        local Setting, Value = Args[2], ToBoolean(Args[3])
        if Setting and Value ~= nil then
            AdminSettings[Setting] = Value
            Notify("Success", "Set " .. Args[2] .. " to: " .. Args[3] .. ". (Admin Settings)", 2)
        end
        ChangeAdminGuiToggle(AdminSettings.killcmds, "Kill Commands")
        ChangeAdminGuiToggle(AdminSettings.tpcmds, "Teleport Commands")
        ChangeAdminGuiToggle(AdminSettings.arrestcmds, "Arrest Commands")
        ChangeAdminGuiToggle(AdminSettings.othercmds, "Other Commands")
    end
    if CMD("antipunch") or CMD("ap") then
        States.AntiPunch = not States.AntiPunch
        ChangeGuiToggle(States.AntiPunch, "Anti-Punch")
        Notify("Success", "Toggled anti-punch to " .. tostring(States.AntiPunch) .. ".", 2)
    end
    if CMD("exit") then
        Notify("Success", "Unloading....", 2)
        States = {}
        UnloadScript()
        getgenv().WrathLoaded = false
    end
    if CMD("ls") or CMD("logspam") then
        for i, v in next, Args do
            if i > 2 then
                Args[2] = Args[2] .. " " .. Args[i]
            end
        end
        local Message = Args[2]
        Notify("Success", "Now log spamming.", 2)
        coroutine.wrap(LogSpam)(Message)
    end
    if CMD("unls") or CMD("unlogspam") then
        Notify("Success", "Stopped spamming.", 2)
        States.LogSpam = false
    end
    if CMD("prefix") then
        local Prefix = Args[2]
        if Prefix then
            Settings.Prefix = Prefix
            Notify("Success", "Prefix was changed to: " .. Prefix, 2)
        end
    end
    if CMD("mkill") then
        SavePos()
        if Args[2] == "all" then
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                    MeleeKill(v)
                end
            end
            Notify("Success", "Melee killed everyone.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                MeleeKill(Player)
                Notify("Success", "Melee killed " .. Player.Name .. ".", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
        LoadPos()
    end
    if CMD("vkill") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Teleport(Player, CFrame.new(9e9, 9e9, 100))
            Notify("Success", "Void killed " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("getps") or CMD("getprotectedsettings") then
        print("====== PROTECTED SETTINGS ======")
        for i, v in pairs(ProtectedSettings) do
            print(i, v)
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see protected settings.", 2)
    end
    if CMD("getas") or CMD("getadminsettings") then
        print("====== ADMIN SETTINGS ======")
        for i, v in pairs(AdminSettings) do
            print(i, v)
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see admin settings.", 2)
    end
    if CMD("getv") or CMD("getinfected") then
        print("====== INFECTED PLAYERS ======")
        for i, v in pairs(Infected) do
            print(v.Name .. " (" .. v.DisplayName .. ")")
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see infected players.", 2)
    end
    if CMD("getk") or CMD("getkillaura") then
        print("====== KILL AURAS ======")
        for i, v in pairs(KillAuras) do
            print(v.Name .. " (" .. v.DisplayName .. ")")
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see kill auras.", 2)
    end
    if CMD("clka") or CMD("clearkillaura") then
        KillAuras = {}
        Notify("Success", "Cleared kill auras", 2)
    end
    if CMD("fpsboost") or CMD("antilag") or CMD("boost") then
        Notify("Loading...", "FPS boost", 2)
        FPSBoost()
    end
    if CMD("tase") then
        if Args[2] == "all" then
            Tase(Players:GetPlayers())
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Tase({Player})
                Notify("Success", "Tased " .. Player.Name .. ".", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("ta") or CMD("taseaura") then
        if Args[2] == "all" then
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                    TaseAuras[v.UserId] = v
                end
            end
            Notify("Success", "Gave everyone tase aura.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                TaseAuras[Player.UserId] = Player
                Notify("Success", "Gave " .. Player.Name .. " tase aura.", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("unta") or CMD("untaseaura") then
        if Args[2] == "all" then
            TaseAuras = {}
            Notify("Success", "Removed everyone's tase aura.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                TaseAuras[Player.UserId] = nil
                Notify("Success", "Removed " .. Player.Name .. "'s tase aura.", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("lt") then
        if Args[2] == "all" then
            States.TaseAll = true
            Notify("Success", "Loop-tasing everyone.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                LoopTasing[Player.UserId] = Player
                Notify("Success", "Loop-tasing " .. Player.Name .. ".", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("unlt") then
        if Args[2] == "all" then
            States.TaseAll = false
            LoopTasing = {}
            Notify("Success", "Stopped loop-tasing everyone.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                LoopTasing[Player.UserId] = nil
                Notify("Success", "Stopped Loop-tasing " .. Player.Name .. ".", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("clt") or CMD("cleartase") then
        LoopTasing = {}
        Notify("Success", "Cleared loop tase.", 2)
    end
    if CMD("ma") or CMD("meleeaura") then
        States.MeleeAura = not States.MeleeAura
        Notify("Success", "Toggled melee aura to " .. tostring(States.MeleeAura) .. ".", 2)
    end
    if CMD("getlt") or CMD("getlooptase") then
        print("====== LOOP TASING ======")
        for i, v in pairs(LoopTasing) do
            print(v.Name .. " (" .. v.DisplayName .. ")")
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see loop tasing.", 2)
    end
    if CMD("getmlk") or CMD("getmeleeloopkill") then
        print("====== LOOP MELEE KILLING ======")
        for i, v in pairs(MeleeKilling) do
            print(v.Name .. " (" .. v.DisplayName .. ")")
        end
        print("====== END ======")
        Notify("Success", "Type /console or F9 to see loop melee killing.", 2)
    end
    if CMD("mlk") then
        if Args[2] == "all" then
            States.MeleeAll = true
            Notify("Success", "Melee loop-killing all.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                MeleeKilling[Player.UserId] = Player
                Notify("Success", "Melee loop-killing " .. Player.Name .. ".")
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("unmlk") then
        if Args[2] == "all" then
            States.MeleeAll = false
            MeleeKilling = {}
            Notify("Success", "Stopped melee loop-killing all.", 2)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                MeleeKilling[Player.UserId] = nil
                Notify("Success", "Stopped melee loop-killing " .. Player.Name .. ".")
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("slk") or CMD("speedloopkill") then
        if Args[2] == "all" then
            States.SpeedKillAll = true
        elseif Args[2] == "guards" or Args[2] == "g" then
            States.SpeedKillGuards = true
        elseif Args[2] == "inmates" or Args[2] == "i" then
            States.SpeedKillInmates = true
        elseif Args[2] == "criminals" or Args[2] == "c" then
            States.SpeedKillCriminals = true
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                SpeedKilling[Player.UserId] = Player
                Notify("Success", "Speed loop-killing " .. Player.Name .. ".", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("unslk") or CMD("unspeedloopkill") then
        if Args[2] == "all" then
            SpeedKilling = {}
            States.SpeedKillAll = false
        elseif Args[2] == "guards" or Args[2] == "g" then
            States.SpeedKillGuards = false
        elseif Args[2] == "inmates" or Args[2] == "i" then
            States.SpeedKillInmates = false
        elseif Args[2] == "criminals" or Args[2] == "c" then
            States.SpeedKillCriminals = false
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                SpeedKilling[Player.UserId] = nil
                Notify("Success", "Stopped speed loop-killing " .. Player.Name .. ".", 2)
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("god") then
        SavePos()
        States.GodMode = true
        Notify("Success", "Turned on god mode.", 2)
    end
    if CMD("ungod") then
        States.GodMode = false
        Notify("Success", "Turned off god mode.", 2)
    end
    if CMD("clogs") or CMD("combatlogs") then
        if not States.AntiCrash then
            States.CombatLogs = not States.CombatLogs
            Notify("Success", "Toggled combat logs to " .. tostring(States.CombatLogs) .. ".", 2)
        else
            Notify(
                "Error",
                "Disable anticrash first! (" .. Settings.Prefix .. "acrash / " .. Settings.Prefix .. "anticrash).",
                2
            )
        end
    end
    if CMD("shootback") or CMD("sb") then
        if not States.AntiCrash then
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                if Player == LocalPlayer then
                    States.ShootBack = not States.ShootBack
                    ChangeGuiToggle(States.ShootBack, "Shoot Back")
                    Notify("Success", "Toggled shoot back to " .. tostring(States.ShootBack) .. ".", 2)
                else
                    if not AntiShoots[Player.UserId] then
                        AntiShoots[Player.UserId] = Player
                        Notify(
                            "Success",
                            "Gave shoot back to " ..
                                Player.Name .. ". Type " .. Settings.Prefix .. "sb [plr] to disable.",
                            2
                        )
                    else
                        AntiShoots[Player.UserId] = nil
                        Notify("Success", "Removed shoot back from " .. Player.Name .. ".", 2)
                    end
                end
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        else
            Notify(
                "Error",
                "Disable anticrash first! (" .. Settings.Prefix .. "acrash / " .. Settings.Prefix .. "anticrash).",
                2
            )
        end
    end
    if CMD("tb") or CMD("taseback") then
        if not States.AntiCrash then
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                if Player == LocalPlayer then
                    States.TaseBack = not States.TaseBack
                    ChangeGuiToggle(States.TaseBack, "Tase Back")
                    Notify(
                        "Success",
                        "Toggled tase back to " ..
                            tostring(States.TaseBack) .. ". Type " .. Settings.Prefix .. "tb [plr] to disable.",
                        2
                    )
                else
                    if not TaseBacks[Player.UserId] then
                        TaseBacks[Player.UserId] = Player
                        Notify("Success", "Gave tase back to " .. Player.Name .. ".", 2)
                    else
                        TaseBacks[Player.UserId] = nil
                        Notify("Success", "Removed tase back from " .. Player.Name .. ".", 2)
                    end
                end
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        else
            Notify(
                "Error",
                "Disable anticrash first! (" .. Settings.Prefix .. "acrash / " .. Settings.Prefix .. "anticrash).",
                2
            )
        end
    end
    if CMD("clsb") or CMD("clearshootback") then
        AntiShoots = {}
        Notify("Success", "Cleared shoot backs.", 2)
    end
    if CMD("cltb") or CMD("cleartaseback") then
        TaseBacks = {}
        Notify("Success", "Cleared tase backs.", 2)
    end
    if CMD("clop") then
        Onepunch = {}
        Notify("Success", "Cleared one punch.", 2)
    end
    if CMD("clos") or CMD("clearoneshot") then
        Oneshots = {}
        Notify("Success", "Cleared one shot.", 2)
    end
    if CMD("getstates") or CMD("gets") then
        print("====== STATES ======")
        for i, v in next, States do
            print(i, v)
        end
        print("====== END ======")
        Notify("Success", "Type /console or press F9 to see states.", 2)
    end
    if CMD("ffire") or CMD("friendlyfire") then
        States.FriendlyFire = not States.FriendlyFire
        Info.FriendlyFireOldTeam = LocalPlayer.TeamColor.Name
        Notify("Success", "Toggled friendly fire to " .. tostring(States.FriendlyFire) .. ".", 2)
    end
    if CMD("acrash") or CMD("anticrash") then
        States.AntiCrash = not States.AntiCrash
        ChangeGuiToggle(States.AntiCrash, "Anti-Crash")
        Notify("Success", "Toggled anti crash to " .. tostring(States.AntiCrash) .. ".", 2)
        if States.AntiCrash then
            States.ShootBack = false
            States.TaseBack = false
            ChangeGuiToggle(false, "Shoot Back")
            ChangeGuiToggle(false, "Tase Back")
            for i, v in pairs(getconnections(rStorage.ReplicateEvent.OnClientEvent)) do
                v:Disable()
            end
        else
            for i, v in pairs(getconnections(rStorage.ReplicateEvent.OnClientEvent)) do
                v:Enable()
            end
        end
    end
    if CMD("getd") or CMD("getdef") then
        print("====== DEFENSES ======")
        print("AntiShoot", States.ShootBack)
        print("AntiBring", States.AntiBring)
        print("AntiFling", States.AntiFling)
        print("AntiPunch", States.AntiPunch)
        print("AntiCrash", States.AntiCrash)
        print("AntiCriminal", States.AntiCriminal)
        print("====== END ======")
    end
    if CMD("nuke") or CMD("kamikaze") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Nukes[Player.UserId] = Player
            Chat("!!! " .. Player.DisplayName .. " has turned into a nuke - if they die everyone dies !!!")
            Notify("Success", "Turned " .. Player.Name .. " into a nuke.", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("defuse") or CMD("unnuke") then
        local Player = GetPlayer(Args[2], LocalPlayer)
        if Player then
            Nukes[Player.UserId] = nil
            Notify("Success", "Removed nuke from " .. Player.Name .. ".", 2)
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("btools") then
        local tool1 = Instance.new("HopperBin", LocalPlayer.Backpack)
        local tool2 = Instance.new("HopperBin", LocalPlayer.Backpack)
        local tool3 = Instance.new("HopperBin", LocalPlayer.Backpack)
        local tool4 = Instance.new("HopperBin", LocalPlayer.Backpack)
        local tool5 = Instance.new("HopperBin", LocalPlayer.Backpack)
        tool1.BinType = "Clone"
        tool2.BinType = "GameTool"
        tool3.BinType = "Hammer"
        tool4.BinType = "Script"
        tool5.BinType = "Grab"
        Notify("Success", "Obtained btools", 2)
    end
    if CMD("gui") or CMD("guis") then
        ToggleGuis()
    end
    if CMD("bindgui") or CMD("guikeybind") then
        local Bind = Args[2]
        if Bind then
            if CheckKeycode(Bind) then
                Settings.ToggleGui = Bind
                Notify("Success", "Changed GUI bind to " .. Bind .. ".", 2)
            else
                Notify("Error", "That is not a valid keybind. If it is a letter make sure its capitalised.")
            end
        else
            Notify("Error", "Specify a keybind.", 2)
        end
    end
    if CMD("noclip") then
        States.NoClip = true
        Notify("Success", "Enabled no-clip. Use " .. Settings.Prefix .. "clip to disable.", 2)
    end
    if CMD("clip") then
        States.NoClip = false
        Notify("Success", "Disabled no-clip.", 2)
    end
    if CMD("ff") or CMD("forcefield") then
        States.Forcefield = true
        SavePos()
        Notify("Success", "Enabled force field", 2)
    end
    if CMD("unff") or CMD("unforcefield") then
        States.Forcefield = false
        Notify("Success", "Disabled force field", 2)
    end
    if CMD("pa") or CMD("punchaura") then
        States.PunchAura = not States.PunchAura
        Notify("Success", "Toggled punch aura to " .. tostring(States.PunchAura) .. ".", 2)
    end
    if CMD("sp") or CMD("spampunch") then
        States.SpamPunch = not States.SpamPunch
        Notify("Success", "Toggled spam punch to " .. tostring(States.SpamPunch) .. ".", 2)
    end
    if CMD("op") or CMD("onepunch") then
        local Player = GetPlayer(Args[2], LocalPlayer)

        if Player then
            if Player == LocalPlayer then
                States.OnePunch = not States.OnePunch
                Notify("Success", "Toggled one punch to " .. tostring(States.OnePunch) .. ".", 2)
            else
                if not Onepunch[Player.UserId] then
                    Onepunch[Player.UserId] = Player
                    Notify(
                        "Success",
                        "Added one punch to " .. Player.Name .. ". Type " .. Settings.Prefix .. "op [plr] to disable.",
                        2
                    )
                else
                    Onepunch[Player.UserId] = nil
                    Notify("Success", "Removed one punch from " .. Player.Name .. ".", 2)
                end
            end
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("os") or CMD("oneshot") then
        local Player = GetPlayer(Args[2], LocalPlayer)

        if Player then
            if Player == LocalPlayer then
                States.OneShot = not States.OneShot
                Notify("Success", "Toggled one shot to " .. tostring(States.OneShot) .. ".", 2)
            else
                if not States.AntiCrash then
                    if not Oneshots[Player.UserId] then
                        Oneshots[Player.UserId] = Player
                        Notify(
                            "Success",
                            "Added one shot to " ..
                                Player.Name .. ". Type " .. Settings.Prefix .. "os [plr] to disable.",
                            2
                        )
                    else
                        Oneshots[Player.UserId] = nil
                        Notify("Success", "Removed one shot from " .. Player.Name .. ".", 2)
                    end
                else
                    Notify(
                        "Error",
                        "Disable anticrash first! (" ..
                            Settings.Prefix .. "acrash / " .. Settings.Prefix .. "anticrash).",
                        2
                    )
                end
            end
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("ctp") or CMD("clicktp") then
        local Player = GetPlayer(Args[2], LocalPlayer)

        if Player then
            if Player == LocalPlayer then
                States.ClickTeleport = not States.ClickTeleport
                Notify("Success", "Toggled click tp to " .. tostring(States.ClickTeleport) .. ". (CTRL)", 2)
            else
                if not States.AntiCrash then
                    if not ClickTeleports[Player.UserId] then
                        ClickTeleports[Player.UserId] = Player
                        Notify(
                            "Success",
                            "Added click tp to " ..
                                Player.Name .. ". Type " .. Settings.Prefix .. "ctp [plr] to disable.",
                            2
                        )
                    else
                        ClickTeleports[Player.UserId] = nil
                        Notify("Success", "Removed click tp from " .. Player.Name .. ".", 2)
                    end
                else
                    Notify(
                        "Error",
                        "Disable anticrash first! (" ..
                            Settings.Prefix .. "acrash / " .. Settings.Prefix .. "anticrash).",
                        2
                    )
                end
            end
        else
            Notify("Error", Args[2] .. " is not a valid player.", 2)
        end
    end
    if CMD("clctp") then
        ClickTeleports = {}
        Notify("Success", "Cleared click teleports.", 2)
    end
    if CMD("shop") or CMD("serverhop") then
        local FoundServers = {}
        for i, v in pairs(
            HttpService:JSONDecode(
                game:HttpGetAsync(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                )
            ).data
        ) do
            if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                FoundServers[#FoundServers + 1] = v.id
            end
        end

        if #FoundServers > 0 then
            Notify("Success", "Server hopping...", 2)
    local telepoitserveice = game:GetService("TeleportService")
    telepoitserveice:TeleportToPlaceInstance(game.PlaceId, FoundServers[math.random(1, #FoundServers)])
        else
            Notify("Error", "Couldn't find a server to join.", 2)
        end
    end
    if CMD("copyteam") or CMD("ct") then
        if not States.CopyingTeam then
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player and Player ~= LocalPlayer then
                States.CopyingTeam = {Player = Player}
                States.CopyingTeam.Connection =
                    Player:GetPropertyChangedSignal("TeamColor"):Connect(
                    function()
                        if not next(Loopkilling) or not next(SpeedKilling) or not next(LoopTasing) then
                            local NewTeam = Player.TeamColor.Name
                            SavePos()
                            if NewTeam == "Bright orange" or NewTeam == "Medium stone grey" then
                                TeamEvent(NewTeam)
                            else
                                if NewTeam == "Bright blue" then
                                    if #Teams.Guards:GetPlayers() >= 8 then
                                        Loadchar(NewTeam)
                                    else
                                        TeamEvent(NewTeam)
                                    end
                                else
                                    Loadchar(NewTeam)
                                end
                            end
                            LoadPos()
                        end
                    end
                )
                if Player.TeamColor ~= LocalPlayer.TeamColor then
                    SavePos()
                    Loadchar(Player.TeamColor.Name)
                    LoadPos()
                end
                Notify(
                    "Success",
                    "Copying team of " .. Player.Name .. ". Type " .. Settings.Prefix .. "ct [plr] to disable.",
                    2
                )
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        else
            Notify("Success", "Disabled copy team.", 2)
            States.CopyingTeam.Connection:Disconnect()
            States.CopyingTeam = nil
        end
    end
    if CMD("gs") or CMD("gunspin") then
        task.spawn(
            function()
                States.SpinningGuns = true
                local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()
                if Character then
                    GiveGuns()
                    local speed = 10
                    local radius = 10
                    local finish

                    if Args[2] and tonumber(Args[2]) then
                        radius = tonumber(Args[2])
                    end
                    if Args[3] and tonumber(Args[3]) then
                        speed = tonumber(Args[3])
                    end
                    local spinguns = {
                        ["AK-47"] = CFrame.new(-radius, 0, 0),
                        ["Remington 870"] = CFrame.new(radius, 0, 0),
                        ["M9"] = CFrame.new(-raduis, 0, 0),
                        ["M4A1"] = CFrame.new(radius, 0, 0)
                    }

                    for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if spinguns[v.Name] then
                            v.Grip = spinguns[v.Name]
                            v.Parent = Character
                        end
                    end

                    task.spawn(
                        function()
                            LocalPlayer.CharacterAdded:wait()
                            finish = true
                        end
                    )

                    task.wait(0.1)

                    repeat
                        for i, v in pairs(Character:GetChildren()) do
                            if spinguns[v.Name] then
                                v.Grip = v.Grip * CFrame.Angles(0, math.rad(speed), 0)
                                v.Parent = LocalPlayer.Backpack
                                v.Parent = Character
                            end
                        end
                        game:GetService("RunService").RenderStepped:wait()
                    until finish == true
                end
            end
        )
        Notify("Success", "Spinning guns (respawn / reset to disable)", 2)
    end
    if CMD("sc") or CMD("softcrash") then
        local Events = {}
        for i = 1, 100000 do
            local origin, destination =
                LocalPlayer.Character.HumanoidRootPart.Position,
                workspace:FindFirstChildOfClass("Part").Position
            local distance, ray = (origin - destination).Magnitude, Ray.new(origin, (destination - origin).unit * 9e9)
            local cf = CFrame.new(destination, origin) * CFrame.new(0, 0, -distance / 2)
            Events[#Events + 1] = {
                Hit = v,
                Cframe = cf,
                Distance = distance,
                RayObject = Ray.new(Vector3.new(), Vector3.new())
            }
        end
        ItemHandler(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
        local Gun = LocalPlayer.Character:FindFirstChild("AK-47") or LocalPlayer.Backpack:FindFirstChild("AK-47")
        rStorage.ShootEvent:FireServer(Events, Gun)
        rStorage.ReloadEvent:FireServer(Gun)
        Notify("Success", "Soft-crashed server.", 2)
    end
    if CMD("lb") or CMD("loopbring") then
        if Args[2] == "all" then
            Notify("Success", "Loop-bringing all.", 2)
            pcall(LoopTeleport, LocalPlayer, LocalPlayer.Character.Head.CFrame, true)
        else
            local Player = GetPlayer(Args[2], LocalPlayer)
            if Player then
                Notify("Success", "Loop-bringing " .. Player.Name .. ".", 2)
                pcall(
                    function()
                        LoopTeleport(Player, LocalPlayer.Character.Head.CFrame)
                    end
                )
            else
                Notify("Error", Args[2] .. " is not a valid player.", 2)
            end
        end
    end
    if CMD("unlb") then
        States.Loopbring = false
        Notify("Success", "Stopped loop bringing.", 2)
    end
    if CMD("cltr") then
        Trapped = {}
        Notify("Success", "Untrapped all", 2)
    end
    if CMD("lpunch") or CMD("loudpunch") then
        States.LoudPunch = not States.LoudPunch
        Notify("Success", "Toggled loud punch to " .. tostring(States.LoudPunch) .. ".", 2)
    end
    if CMD("sarmor") or CMD("spamarmor") then
        if CheckOwnedGamepass() then
            States.SpamArmor = true
            local Amount = Args[2] or 10
            local Num = tonumber(Args[2])
            if Num then
                Notify("Success", "Armor spamming.", 2)
                SavePos()
                Loadchar("Bright blue")
                LoadPos()
                task.spawn(ArmorSpam, Num)
            end
        else
            Notify("Error", "You don't have the riot gamepass", 2)
        end
    end
    if CMD("unsarmor") or CMD("unspamarmor") then
        States.ArmorSpam = false
        Notify("Success", "Stopped armor spamming.", 2)
    end
end

function RandomPlayer()
    local PlayersTable = Players:GetPlayers()
    local RandomIndex = math.random(1, #PlayersTable)
    return PlayersTable[RandomIndex]
end

function RandomTeam()
    local Teams = {"guards", "inmates", "criminals"}
    return Teams[math.random(1, #Teams)]
end

--// Ranked Commands:
function UseRankedCommands(MESSAGE, Admin)
    if Admin == LocalPlayer then
        return
    end
    local Args = MESSAGE:split(" ")

    if not Args[1] then
        return
    end

    if Args[1] == "/e" then
        table.remove(Args, 1)
    end

    if Args[1] == "/w" then
        table.remove(Args, 1)
        if Args[2] then
            table.remove(Args, 1)
        end
    end

    if Args[1]:sub(1, 1) ~= Settings.Prefix then
        return
    end

    local CommandName = Args[1]:sub(2)
    local PF = Settings.Prefix

    local function CMD2(NAME)
        return NAME == CommandName:lower()
    end

    local function WarnProtected(Admin, Player, CMD)
        Chat("/w " .. Admin.Name .. " " .. Player.Name .. " is protected from that command!")
        Chat("/w " .. Player.Name .. " " .. Admin.Name .. " tried to use " .. Settings.Prefix .. CMD .. " on you.")
    end

    local function WarnDisabled(CMD)
        Chat("/w " .. Admin.Name .. " " .. Settings.Prefix .. CMD .. " is disabled right now.")
    end

    local function NotAValidPlayer(CMD)
        Chat(
            "/w " ..
                Admin.Name ..
                    " " ..
                        Args[2] ..
                            " is not a valid player. Example - " ..
                                PF .. CMD .. " " .. RandomPlayer().Name:lower() .. " or " .. PF .. CMD .. " me"
        )
    end

    if CMD2("cmds") or CMD2("cmd") then
        Chat(
            "/w " ..
                Admin.Name ..
                    " " ..
                        PF ..
                            "kill [plr,inmates,guards,criminals,all] " ..
                                PF ..
                                    "lk [plr] " ..
                                        PF ..
                                            "unlk [plr] " ..
                                                PF ..
                                                    "arrest [plr] " ..
                                                        PF ..
                                                            "crim [plr] " ..
                                                                PF ..
                                                                    "fling [plr] " ..
                                                                        PF ..
                                                                            "sfling [plr] " ..
                                                                                PF ..
                                                                                    "tase [plr,all] " ..
                                                                                        PF .. "ctp [plr]"
        )
        Chat(
            "/w " ..
                Admin.Name ..
                    " " ..
                        PF ..
                            "keycard [plr] " ..
                                PF ..
                                    "shield [plr] " ..
                                        PF ..
                                            "shotty [plr] " ..
                                                PF ..
                                                    "m9 [plr] " ..
                                                        PF ..
                                                            "m4 [plr] " ..
                                                                PF ..
                                                                    "ak [plr] " ..
                                                                        PF ..
                                                                            "hammer [plr] " ..
                                                                                PF ..
                                                                                    "knife [plr] " ..
                                                                                        PF ..
                                                                                            "handcuffs [plr] " ..
                                                                                                PF .. "taser [plr]"
        )
        Chat(
            "/w " ..
                Admin.Name ..
                    " " ..
                        PF ..
                            "nexus [plr] " ..
                                PF ..
                                    "cafe [plr] " ..
                                        PF ..
                                            "tower [plr] " ..
                                                PF ..
                                                    "yard [plr] " ..
                                                        PF ..
                                                            "cells [plr] " ..
                                                                PF ..
                                                                    "back [plr] " ..
                                                                        PF ..
                                                                            "base [plr] " ..
                                                                                PF ..
                                                                                    "crim [plr] " ..
                                                                                        PF ..
                                                                                            "bring [plr] " ..
                                                                                                PF .. "oneshot [plr]"
        )
        Chat(
            "/w " ..
                Admin.Name ..
                    " " ..
                        PF ..
                            "virus [plr] " ..
                                PF ..
                                    "unvirus [plr] " ..
                                        PF ..
                                            "ka [plr] " ..
                                                PF ..
                                                    "unka [plr] " ..
                                                        PF ..
                                                            "trap [plr] " ..
                                                                PF ..
                                                                    "untrap [plr] " ..
                                                                        PF ..
                                                                            "void [plr] " ..
                                                                                PF ..
                                                                                    "armory [plr] " ..
                                                                                        PF ..
                                                                                            "goto [plr] " ..
                                                                                                PF .. "onepunch [plr]"
        )
    end
    if CMD2("kill") then
        if AdminSettings.killcmds == true then
            if Args[2] == "all" then
                KillPlayers(Players, Admin)
            elseif Args[2] == "inmates" then
                KillPlayers(Teams.Inmates, Admin)
            elseif Args[2] == "guards" then
                KillPlayers(Teams.Guards, Admin)
            elseif Args[2] == "criminals" then
                KillPlayers(Teams.Criminals, Admin)
            else
                local Player = GetPlayer(Args[2], Admin)
                if Player then
                    if CheckProtected(Player, "killcmds") or Player == Admin then
                        AddToQueue(
                            function()
                                Kill({Player})
                            end
                        )
                    else
                        WarnProtected(Admin, Player, "kill")
                    end
                else
                    Chat(
                        "/w " ..
                            Admin.Name ..
                                " " ..
                                    Args[2] ..
                                        " is not a valid player. Example - " ..
                                            PF ..
                                                "kill " ..
                                                    RandomPlayer().Name:lower() ..
                                                        " or " ..
                                                            PF .. "kill " .. RandomTeam() .. " or " .. PF .. "kill all"
                    )
                end
            end
        else
            WarnDisabled("kill")
        end
    end
    if CMD2("tase") then
        if AdminSettings.killcmds == true then
            if Args[2] == "all" then
                Tase(Players:GetPlayers())
            else
                local Player = GetPlayer(Args[2], Admin)
                if Player then
                    if CheckProtected(Player, "killcmds") or Player == Admin then
                        AddToQueue(
                            function()
                                Tase({Player})
                            end
                        )
                    else
                        WarnProtected(Admin, Player, "tase")
                    end
                else
                    Chat(
                        "/w " ..
                            Admin.Name ..
                                " " ..
                                    Args[2] ..
                                        " is not a valid player. Example - " ..
                                            PF .. "tase " .. RandomPlayer().Name:lower() .. " or " .. PF .. "tase all"
                    )
                end
            end
        else
            WarnDisabled("tase")
        end
    end
    if CMD2("lk") then
        if AdminSettings.killcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "killcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Loopkilling[Player.UserId] = Player
                        end
                    )
                else
                    WarnProtected(Admin, Player, "lk")
                end
            else
                NotAValidPlayer("lk")
            end
        else
            WarnDisabled("lk")
        end
    end
    if CMD2("unlk") then
        local Player = GetPlayer(Args[2], Admin)
        if Player then
            AddToQueue(
                function()
                    Loopkilling[Player.UserId] = nil
                end
            )
        else
            NotAValidPlayer("unlk")
        end
    end
    if CMD2("arrest") then
        if AdminSettings.arrestcmds == true then
            SavePos()
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "arrestcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Arrest(Player, 1)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "arrest")
                end
            else
                NotAValidPlayer("arrest")
            end
            task.wait(0.15)
            for i = 1, 10 do
                LoadPos()
            end
        else
            WarnDisabled("arrest")
        end
    end
    if CMD2("crim") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Crim(Player, false)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "crim")
                end
            else
                NotAValidPlayer("crim")
            end
        else
            WarnDisabled("crim")
        end
    end
    if CMD2("fling") then
        if AdminSettings.othercmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "othercmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Fling(Player, false)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "fling")
                end
            else
                NotAValidPlayer("fling")
            end
        else
            WarnDisabled("fling")
        end
    end
    if CMD2("sfling") then
        if AdminSettings.othercmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "othercmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Fling(Player, true)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "sfling")
                end
            else
                NotAValidPlayer("sfling")
            end
        else
            WarnDisabled("sfling")
        end
    end
    if CMD2("keycard") or CMD2("key") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Keycard(Player)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "keycard")
                end
            else
                NotAValidPlayer("keycard")
            end
        else
            WarnDisabled("keycard")
        end
    end
    if CMD2("handcuffs") or CMD2("cuffs") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Give(Player, "Handcuffs", false, "Bright blue", true)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "handcuffs")
                end
            else
                NotAValidPlayer("handcuffs")
            end
        else
            WarnDisabled("handcuffs")
        end
    end
    if CMD2("taser") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Give(Player, "Taser", false, "Bright blue", true)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "taser")
                end
            else
                NotAValidPlayer("taser")
            end
        else
            WarnDisabled("taser")
        end
    end
    if CMD2("shield") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    if CheckOwnedGamepass() then
                        AddToQueue(
                            function()
                                Give(Player, "Riot Shield", true, "Bright blue")
                            end
                        )
                    else
                        Chat(
                            "/w " .. Admin.Name .. " I cannot use this command because I don't have the riot gamepass."
                        )
                    end
                else
                    WarnProtected(Admin, Player, "shield")
                end
            else
                NotAValidPlayer("shield")
            end
        else
            WarnDisabled("shield")
        end
    end
    if CMD2("shotty") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Give(Player, "Remington 870", true)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "shotty")
                end
            else
                NotAValidPlayer("shotty")
            end
        else
            WarnDisabled("shotty")
        end
    end
    if CMD2("m9") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Give(Player, "M9", true)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "m9")
                end
            else
                NotAValidPlayer("m9")
            end
        else
            WarnDisabled("m9")
        end
    end
    if CMD2("ak") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Give(Player, "AK-47", true)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "ak")
                end
            else
                NotAValidPlayer("ak")
            end
        else
            WarnDisabled("ak")
        end
    end
    if CMD2("m4") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    if CheckOwnedGamepass() then
                        AddToQueue(
                            function()
                                Give(Player, "M4A1", true)
                            end
                        )
                    else
                        Chat(
                            "/w " .. Admin.Name .. " I cannot use this command because I don't have the riot gamepass."
                        )
                    end
                else
                    WarnProtected(Admin, Player, "m4")
                end
            else
                NotAValidPlayer("m4")
            end
        else
            WarnDisabled("m4")
        end
    end
    if CMD2("hammer") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Give(Player, "Hammer", false)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "hammer")
                end
            else
                NotAValidPlayer("hammer")
            end
        else
            WarnDisabled("hammer")
        end
    end
    if CMD2("knife") then
        if AdminSettings.givecmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "givecmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Give(Player, "Crude Knife", false)
                        end
                    )
                else
                    WarnProtected(Admin, Player, "knife")
                end
            else
                NotAValidPlayer("knife")
            end
        else
            WarnDisabled("knife")
        end
    end
    if CMD2("nexus") or CMD2("nex") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(888, 100, 2388))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "nexus")
                end
            else
                NotAValidPlayer("nexus")
            end
        else
            WarnDisabled("nexus")
        end
    end
    if CMD2("tower") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(823, 130, 2588))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "tower")
                end
            else
                NotAValidPlayer("tower")
            end
        else
            WarnDisabled("tower")
        end
    end
    if CMD2("back") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(984, 100, 2318))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "back")
                end
            else
                NotAValidPlayer("back")
            end
        else
            WarnDisabled("back")
        end
    end
    if CMD2("base") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-943, 94, 2056))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "base")
                end
            else
                NotAValidPlayer("base")
            end
        else
            WarnDisabled("base")
        end
    end
    if CMD2("armory") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(837, 100, 2266))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "armory")
                end
            else
                NotAValidPlayer("armory")
            end
        else
            WarnDisabled("armory")
        end
    end
    if CMD2("yard") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(791, 98, 2498))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "yard")
                end
            else
                NotAValidPlayer("yard")
            end
        else
            WarnDisabled("yard")
        end
    end
    if CMD2("cells") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(917, 100, 2444))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cells")
                end
            else
                NotAValidPlayer("cells")
            end
        else
            WarnDisabled("cells")
        end
    end
    if CMD2("snack") or CMD("vending") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(949.114136, 101.051971, 2339.5349))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("vent") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(942.60162353516, 121.9900894165, 2213.0822753906))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("slide") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(506.08721923828, 624.0092773457, 3430.0368652344))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("oob") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(525.90008544922, 337.92767333984, 3348.3315429688))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("fridge") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(869, 100.988, 2225.998))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("oven") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(915.3, 98.69, 2210.097))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end

    if CMD2("chillout") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-329, 70, 1829))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end

    if CMD2("base2") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-889.788, 110.087, 2055.04))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end

    if CMD2("base3") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-933.704, 105.93, 2058.404))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end

    if CMD2("sewer") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(916.799, 82.279, 2270.599))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("container") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(266.54, 70.3, 2358.106))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("escape") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(318.416748, 75.5779572, 2220.01953))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("secretroom") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(697, 97.492, 2364))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("undermap") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(
                                Player,
                                CFrame.new(
                                    800.317993,
                                    10.8322506,
                                    1473.46497,
                                    -0.999664009,
                                    -3.23824279e-05,
                                    -0.025924176,
                                    -3.24961984e-05,
                                    1,
                                    3.96724363e-06,
                                    0.025924176,
                                    4.80833751e-06,
                                    -0.999664009
                                )
                            )
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("toilet") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(959.131958, 96.6899796, 2444.74927))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("trash") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(365.445374, 10.7605114, 1100.21265))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("policecar") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(615.645264, 98.2000275, 2514.97485))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("busstop") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-376.442291, 54.2000923, 1723.72534))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("store") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(434.462921, 11.4253635, 1183.47156))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("bridge") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-81.0300827, 11.099329, 1311.87549))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("station") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-512.839172, 54.3937874, 1666.99426))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("hiddenplace") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(-568.503418, 10.8399124, 1414.12463))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("roof") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(827.423523, 118.990005, 2329.62598))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("gate") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(503.799866, 102.03994, 2252.01831))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cant bring")
                end
            else
                NotAValidPlayer("cant bring")
            end
        else
            WarnDisabled()
        end
    end
    if CMD2("cafe") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(930, 100, 2289))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "cafe")
                end
            else
                NotAValidPlayer("cafe")
            end
        else
            WarnDisabled("cafe")
        end
    end
    if CMD2("ka") then
        if AdminSettings.killcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "killcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            KillAuras[Player.UserId] = Player
                        end
                    )
                else
                    WarnProtected(Admin, Player, "ka")
                end
            else
                NotAValidPlayer("ka")
            end
        else
            WarnDisabled("ka")
        end
    end
    if CMD2("unka") then
        local Player = GetPlayer(Args[2], Admin)
        if Player then
            AddToQueue(
                function()
                    KillAuras[Player.UserId] = nil
                end
            )
        else
            NotAValidPlayer("unka")
        end
    end
    if CMD2("virus") then
        if AdminSettings.killcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "killcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Infected[Player.UserId] = Player
                        end
                    )
                else
                    WarnProtected(Admin, Player, "virus")
                end
            else
                NotAValidPlayer("virus")
            end
        else
            WarnDisabled("virus")
        end
    end
    if CMD2("unvirus") then
        local Player = GetPlayer(Args[2], Admin)
        if Player then
            AddToQueue(
                function()
                    Infected[Player.UserId] = nil
                end
            )
        else
            NotAValidPlayer("virus")
        end
    end
    if CMD2("trap") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Trapped[Player.UserId] = Player
                        end
                    )
                else
                    WarnProtected(Admin, Player, "trap")
                end
            else
                NotAValidPlayer("trap")
            end
        else
            WarnDisabled("trap")
        end
    end
    if CMD2("untrap") then
        local Player = GetPlayer(Args[2], Admin)
        if Player then
            if CheckProtected(Player, "tpcmds") or Player == Admin then
                AddToQueue(
                    function()
                        Trapped[Player.UserId] = nil
                    end
                )
            else
                WarnProtected(Admin, Player, "untrap")
            end
        else
            NotAValidPlayer("untrap")
        end
    end
    if CMD2("void") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            Teleport(Player, CFrame.new(0, 9e9, 0))
                        end
                    )
                else
                    WarnProtected(Admin, Player, "void")
                end
            else
                NotAValidPlayer("void")
            end
        else
            WarnDisabled("void")
        end
    end
    if CMD2("ctp") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            if not States.AntiCrash then
                                if not ClickTeleports[Player.UserId] then
                                    ClickTeleports[Player.UserId] = Player
                                    Chat(
                                        "/w " ..
                                            Player.Name ..
                                                " Enabled click teleport for " ..
                                                    Player.Name ..
                                                        " - shoot anywhere with a gun to teleport (type " ..
                                                            PF .. "ctp " .. Player.Name .. " to disable)."
                                    )
                                else
                                    ClickTeleports[Player.UserId] = nil
                                    Chat("/w " .. Player.Name .. " Disabled click teleport for " .. Player.Name .. ".")
                                end
                            else
                                Chat("/w " .. Player.Name .. " I cannot do that right now.")
                            end
                        end
                    )
                else
                    WarnProtected(Admin, Player, "ctp")
                end
            else
                NotAValidPlayer("ctp")
            end
        else
            WarnDisabled("ctp")
        end
    end
    if CMD2("oneshot") then
        if AdminSettings.killcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "killcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            if not States.AntiCrash then
                                if not Oneshots[Player.UserId] then
                                    Oneshots[Player.UserId] = Player
                                    Chat(
                                        "/w " ..
                                            Player.Name ..
                                                " Enabled one shot for " ..
                                                    Player.Name ..
                                                        " (type " .. PF .. "oneshot " .. Player.Name .. " to disable)."
                                    )
                                else
                                    Oneshots[Player.UserId] = nil
                                    Chat("/w " .. Player.Name .. " Disabled one shot for " .. Player.Name .. ".")
                                end
                            else
                                Chat("/w " .. Player.Name .. " I cannot do that right now.")
                            end
                        end
                    )
                else
                    WarnProtected(Admin, Player, "oneshot")
                end
            else
                NotAValidPlayer("oneshot")
            end
        else
            WarnDisabled("oneshot")
        end
    end

    --// Player removed / added:
    local function PlayerRemoving(PLR)
        if CurrentlyViewing then
            if CurrentlyViewing.Player == PLR then
                CurrentlyViewing = nil
                pcall(
                    function()
                        Camera.CameraSubject = LocalPlayer.Character.Humanoid
                    end
                )
            end
        end
        if ArmorSpamFlags[PLR.Name] then
            ArmorSpamFlags[PLR.Name] = nil
        end
    end
    if CMD2("onepunch") then
        if AdminSettings.killcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "killcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            if not States.AntiCrash then
                                if not Onepunch[Player.UserId] then
                                    Onepunch[Player.UserId] = Player
                                    Chat(
                                        "/w " ..
                                            Player.Name ..
                                                " Enabled one punch for " ..
                                                    Player.Name ..
                                                        " (type " .. PF .. "onepunch " .. Player.Name .. " to disable)."
                                    )
                                else
                                    Onepunch[Player.UserId] = nil
                                    Chat("/w " .. Player.Name .. " Disabled one punch for " .. Player.Name .. ".")
                                end
                            else
                                Chat("/w " .. Player.Name .. " I cannot do that right now.")
                            end
                        end
                    )
                else
                    WarnProtected(Admin, Player, "onepunch")
                end
            else
                NotAValidPlayer("onepunch")
            end
        else
            WarnDisabled("onepunch")
        end
    end
    if CMD2("bring") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            pcall(
                                function()
                                    TeleportPlayers(Player, Admin)
                                end
                            )
                        end
                    )
                else
                    WarnProtected(Admin, Player, "bring")
                end
            else
                NotAValidPlayer("bring")
            end
        else
            WarnDisabled("void")
        end
    end
    if CMD2("goto") then
        if AdminSettings.tpcmds == true then
            local Player = GetPlayer(Args[2], Admin)
            if Player then
                if CheckProtected(Player, "tpcmds") or Player == Admin then
                    AddToQueue(
                        function()
                            pcall(
                                function()
                                    TeleportPlayers(Admin, Player)
                                end
                            )
                        end
                    )
                else
                    WarnProtected(Admin, Player, "goto")
                end
            else
                NotAValidPlayer("goto")
            end
        else
            WarnDisabled("goto")
        end
    end
end

local function PlayerAdded(PLR)
    if Loopkilling[PLR.UserId] then
        Loopkilling[PLR.UserId] = PLR
    end
    if LoopTasing[PLR.UserId] then
        LoopTasing[PLR.UserId] = PLR
    end
    if MeleeKilling[PLR.UserId] then
        MeleeKilling[PLR.UserId] = PLR
    end
    if Admins[PLR.UserId] then
        Admins[PLR.UserId] = PLR
    end
    if Protected[PLR.UserId] then
        Protected[PLR.UserId] = PLR
    end
    if SpeedKilling[PLR.UserId] then
        SpeedKilling[PLR.UserId] = PLR
    end
    PLR.Chatted:Connect(
        function(Message)
            if Admins[PLR.UserId] then
                UseRankedCommands(Message, PLR)
            end
        end
    )
end

for i, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        v.Chatted:Connect(
            function(Message)
                if Admins[v.UserId] then
                    UseRankedCommands(Message, v)
                end
            end
        )
    end
end

--// Connections:
LocalPlayer.Chatted:Connect(UseCommand)

LocalPlayer.CharacterAdded:Connect(AutoRespawnCharacterAdded)

LocalPlayer.CharacterAdded:Connect(
    function(CHAR)
        local Humanoid = CHAR:WaitForChild("Humanoid", 1)
        if Humanoid then
            LocalViewerAdded()
            Humanoid.Died:Connect(
                function()
                    pcall(
                        function()
                            Camera.CameraSubject = CurrentlyViewing.Player.Character
                        end
                    )
                end
            )
        end
    end
)

LocalPlayer.CharacterAdded:Connect(
    function(CHAR)
        if States.AutoGuns then
            GiveGuns()
        end
        pcall(
            function()
                WhitelistItem(LocalPlayer.Backpack:FindFirstChild("M9"))
                WhitelistItem(LocalPlayer.Backpack:FindFirstChild("Handcuffs"))
                WhitelistItem(LocalPlayer.Backpack:FindFirstChild("Taser"))
            end
        )
    end
)

LocalPlayer.CharacterAdded:Connect(
    function(CHAR)
        if not Info.StopRespawnLag then
            local ClientInputHandler = CHAR:WaitForChild("ClientInputHandler", 1)
            if ClientInputHandler then
                --[[YieldUntilScriptLoaded(ClientInputHandler);
      --local PF;]]
                PunchFunction = nil
                Info.PunchFunction = nil
                task.wait(1)
                for i, v in pairs(getgc()) do
                    if type(v) == "function" and getfenv(v).script == ClientInputHandler then
                        --local isPunchFunction = false;
                        for i2, v2 in pairs(getupvalues(v)) do
                            if tostring(v2) == "fight_left" then
                                PunchFunction = v
                                break
                            end
                        end
                        if PunchFunction then
                            break
                        end
                    end
                end
                if PunchFunction then
                    --PunchFunction = v;

                    --// hookin it
                    local Old = PunchFunction
                    PunchFunction = function(...)
                        if States.OnePunch then
                            local Character
                            if States.PunchAura then
                                Character = ClosestCharacter(20)
                            else
                                Character = ClosestCharacter(5)
                            end
                            if Character then
                                for i = 1, 15 do
                                    MeleeEvent(Players:GetPlayerFromCharacter(Character))
                                end
                            end
                        end
                        return Old(...)
                    end
                    Info.PunchFunction = PunchFunction
                end
            end
        end
    end
)

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

--// Trapped Players:
task.spawn(
    function()
        while task.wait(0.03) do
            if next(Trapped) then
                for i, v in next, Trapped do
                    pcall(
                        function()
                            if
                                (v.Character.HumanoidRootPart.Position - Vector3.new(-297, 54, 2004)).Magnitude > 80 and
                                    v.Character.Torso.Anchored ~= true and
                                    v.Character.Humanoid.Health > 0
                             then
                                Teleport(v, CFrame.new(-297, 54, 2004))
                                task.wait(2)
                            end
                        end
                    )
                end
            end
        end
    end
)

--// Loopkills:
task.spawn(
    function()
        while task.wait(1 / 5) do
            if next(Loopkilling) then
                local LKPlayers = {}
                for i, v in next, Loopkilling do
                    if v.Character then
                        local Humanoid = v.Character:FindFirstChild("Humanoid")
                        local ForceField = v.Character:FindFirstChild("ForceField")
                        if Humanoid and Humanoid.Health > 0 and not ForceField then
                            LKPlayers[#LKPlayers + 1] = v
                        end
                    end
                end
                if next(LKPlayers) then
                    Kill(LKPlayers)
                end
            end
        end
    end
)

--// Speed Kills:
task.spawn(
    function()
        while true do
            if next(SpeedKilling) then
                local SpeedKillPlayers = {}
                for i, v in next, SpeedKilling do
                    if v.Character and CheckProtected(v, "killcmds") then
                        SpeedKillPlayers[#SpeedKillPlayers + 1] = v
                    end
                end
                if next(SpeedKillPlayers) then
                    --task.spawn(SpeedKill, SpeedKillPlayers);
                    SpeedKill(SpeedKillPlayers)
                end
            end
            task.wait(0.03)
        end
    end
)

--// Melee Kills:
task.spawn(
    function()
        while task.wait(0.03) do
            if next(MeleeKilling) then
                local DoSavePos = false
                SavePos()
                for i, v in next, MeleeKilling do
                    if v.Character and CheckProtected(v, "killcmds") then
                        local Humanoid = v.Character:FindFirstChild("Humanoid")
                        local ForceField = v.Character:FindFirstChild("ForceField")
                        if Humanoid and Humanoid.Health > 0 and not ForceField then
                            MeleeKill(v)
                            DoSavePos = true
                        end
                    end
                end
                if DoSavePos then
                    LoadPos()
                end
            end
        end
    end
)

--// Melee Kill All:
task.spawn(
    function()
        while task.wait(0.03) do
            if States.MeleeAll then
                if next(Players:GetPlayers()) then
                    local DoSavePos = false
                    SavePos()
                    for i, v in pairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer then
                            if v.Character and not MeleeKilling[v.UserId] and CheckProtected(v, "killcmds") then
                                local Humanoid = v.Character:FindFirstChild("Humanoid")
                                local ForceField = v.Character:FindFirstChild("ForceField")
                                if Humanoid and Humanoid.Health > 0 and not ForceField then
                                    MeleeKill(v)
                                    DoSavePos = true
                                end
                            end
                        end
                    end
                    if DoSavePos then
                        LoadPos()
                    end
                end
            end
        end
    end
)

--// Nukes:
task.spawn(
    function()
        while task.wait(0.03) do
            if next(Nukes) then
                for i, v in next, Nukes do
                    if v.Character then
                        local Humanoid = v.Character:FindFirstChildWhichIsA("Humanoid")
                        if Humanoid then
                            if Humanoid.Health <= 0 then
                                Chat(
                                    "!!! THE NUKE (" ..
                                        v.DisplayName .. ") HAS BEEN ACTIVATED - EVERYONE WILL DIE IN 5 SECONDS !!!"
                                )
                                task.wait(1)
                                Chat("4...")
                                task.wait(1)
                                Chat("3...")
                                task.wait(1)
                                Chat("2...")
                                task.wait(1)
                                Chat("1...")
                                task.wait(1)
                                local PTable = Players:GetPlayers()
                                for _, x in next, Nukes do
                                    for i, y in next, PTable do
                                        if y == x then
                                            table.remove(PTable, i)
                                        end
                                        if not CheckProtected(y, "killcmds") then
                                            table.remove(PTable, i)
                                        end
                                    end
                                end
                                Kill(PTable)
                            end
                        end
                    end
                end
            end
        end
    end
)

--// Loop tase:
task.spawn(
    function()
        while task.wait(1 / 5) do
            if next(LoopTasing) then
                local TPlayers = {}
                for i, v in next, LoopTasing do
                    if v.Character then
                        local Humanoid = v.Character:FindFirstChild("Humanoid")
                        local Team = v.TeamColor.Name
                        if Humanoid and Humanoid.Health > 0 and Team ~= "Bright blue" then
                            TPlayers[#TPlayers + 1] = v
                        end
                    end
                end
                if next(TPlayers) then
                    Tase(TPlayers)
                end
            end
        end
    end
)

--// Virus
task.spawn(
    function()
        while task.wait(1 / 3) do
            if next(Infected) then
                local VirusPlayers = {}
                for i, v in next, Infected do
                    if v.Character then
                        local Humanoid = v.Character:FindFirstChild("Humanoid")
                        local ForceField = v.Character:FindFirstChild("ForceField")
                        local PrimaryPart = v.Character:FindFirstChildWhichIsA("BasePart")
                        if PrimaryPart and Humanoid and Humanoid.Health > 0 and not ForceField then
                            for _, plr in pairs(Players:GetPlayers()) do
                                if CheckProtected(plr, "killcmds") then
                                    if plr.Character and plr ~= LocalPlayer and plr ~= v then
                                        local VPart = plr.Character:FindFirstChildWhichIsA("BasePart")
                                        local PHum = plr.Character:FindFirstChild("Humanoid")
                                        local FF = plr.Character:FindFirstChild("ForceField")
                                        if VPart and PHum and not FF then
                                            if
                                                PHum.Health > 0 and
                                                    (PrimaryPart.Position - VPart.Position).Magnitude <= 6
                                             then
                                                VirusPlayers[#VirusPlayers + 1] = plr
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if next(VirusPlayers) then
                    Kill(VirusPlayers)
                end
            end
        end
    end
)

--// Kill Aura
task.spawn(
    function()
        while task.wait(1 / 3) do
            if next(KillAuras) then
                local InAura = {}
                for i, v in next, KillAuras do
                    if v.Character then
                        local Humanoid = v.Character:FindFirstChild("Humanoid")
                        local ForceField = v.Character:FindFirstChild("ForceField")
                        local PrimaryPart = v.Character:FindFirstChildWhichIsA("BasePart")
                        if PrimaryPart and Humanoid and Humanoid.Health > 0 and not ForceField then
                            for _, plr in pairs(Players:GetPlayers()) do
                                if CheckProtected(plr, "killcmds") then
                                    if plr.Character and plr ~= LocalPlayer and plr ~= v then
                                        local VPart = plr.Character:FindFirstChildWhichIsA("BasePart")
                                        local PHum = plr.Character:FindFirstChild("Humanoid")
                                        local FF = plr.Character:FindFirstChild("ForceField")
                                        if VPart and PHum and not FF then
                                            if
                                                PHum.Health > 0 and
                                                    (PrimaryPart.Position - VPart.Position).Magnitude <= 20
                                             then
                                                InAura[#InAura + 1] = plr
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if next(InAura) then
                    Kill(InAura)
                end
            end
        end
    end
)

--// Tase Aura
task.spawn(
    function()
        while task.wait(1 / 3) do
            if next(TaseAuras) then
                local InAura = {}
                for i, v in next, TaseAuras do
                    if v.Character then
                        local Humanoid = v.Character:FindFirstChild("Humanoid")
                        local ForceField = v.Character:FindFirstChild("ForceField")
                        local PrimaryPart = v.Character:FindFirstChildWhichIsA("BasePart")
                        if PrimaryPart and Humanoid and Humanoid.Health > 0 and not ForceField then
                            for _, plr in pairs(Players:GetPlayers()) do
                                if CheckProtected(plr, "killcmds") then
                                    if plr.Character and plr ~= LocalPlayer and plr ~= v then
                                        local VPart = plr.Character:FindFirstChild("HumanoidRootPart")
                                        local VTorso = plr.Character:FindFirstChild("Torso")
                                        local PHum = plr.Character:FindFirstChild("Humanoid")
                                        local FF = plr.Character:FindFirstChild("ForceField")
                                        if VPart and PHum and VTorso and not FF then
                                            if
                                                PHum.Health > 0 and
                                                    (PrimaryPart.Position - VPart.Position).Magnitude <= 20
                                             then
                                                if (VPart.Position - VTorso.Position).Magnitude <= 1 then
                                                    InAura[#InAura + 1] = plr
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if next(InAura) then
                    Tase(InAura)
                end
            end
        end
    end
)

--// Arrest Aura:
task.spawn(
    function()
        while task.wait(0.03) do
            if States.ArrestAura then
                for i, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and CheckProtected(v, "arrestcmds") then
                        if LocalPlayer.Character and v.Character then
                            local LHead, VHead =
                                LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"),
                                v.Character:FindFirstChildWhichIsA("BasePart")
                            if LHead and VHead then
                                if (LHead.Position - VHead.Position).Magnitude <= 50 then
                                    ArrestEvent(v)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
)

--// Melee Aura:
task.spawn(
    function()
        while task.wait(0.03) do
            if States.MeleeAura then
                for i, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                        if LocalPlayer.Character and v.Character then
                            local LHead, VHead =
                                LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"),
                                v.Character:FindFirstChildWhichIsA("BasePart")
                            if LHead and VHead then
                                if (LHead.Position - VHead.Position).Magnitude <= 50 then
                                    for i = 1, 5 do
                                        MeleeEvent(v)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
)

local function OnePunchF(Player)
    local function CharacterAdded(Char)
        if Char then
            local Humanoid = Char:WaitForChild("Humanoid", 1)
            local RootPart = Char:WaitForChild("HumanoidRootPart", 1)
            local PrimaryPart = Char:WaitForChild("Head", 1)
            if Humanoid and RootPart and PrimaryPart then
                Humanoid.AnimationPlayed:Connect(
                    function(Track)
                        if Onepunch[Player.UserId] then
                            if
                                Track.Animation.AnimationId == "rbxassetid://484200742" or
                                    Track.Animation.AnimationId == "rbxassetid://484926359"
                             then
                                for i, v in pairs(Players:GetPlayers()) do
                                    if v ~= Player and v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                                        if v.Character then
                                            pcall(
                                                function()
                                                    local VPart = v.Character.PrimaryPart
                                                    local PPart = PrimaryPart
                                                    local Angle =
                                                        math.deg(
                                                        math.acos(
                                                            Char.HumanoidRootPart.CFrame.LookVector.unit:Dot(
                                                                (VPart.Position - PPart.Position).unit
                                                            )
                                                        )
                                                    )
                                                    if Angle < 50 and (PPart.Position - VPart.Position).Magnitude <= 10 then
                                                        Kill({v})
                                                    end
                                                end
                                            )
                                        end
                                    end
                                end
                            end
                        end
                    end
                )
            end
        end
    end

    CharacterAdded(Player.Character)

    Player.CharacterAdded:Connect(CharacterAdded)
end

for i, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        OnePunchF(v)
    end
end

Players.PlayerAdded:Connect(OnePunchF)

--// NoClip:
rService.Stepped:Connect(
    function()
        if States.NoClip then
            if LocalPlayer.Character then
                for i, v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end
)

--// Team kill:
task.spawn(
    function()
        while task.wait(0.75) do
            if States.KillAll then
                KillPlayers(Players)
            end
            if States.KillInmates then
                KillPlayers(Teams.Inmates)
            end
            if States.KillGuards then
                KillPlayers(Teams.Guards)
            end
            if States.KillCriminals then
                KillPlayers(Teams.Criminals)
            end
            if States.TaseAll then
                Tase(Players:GetPlayers())
            end
        end
    end
)

--// Team SpeedKill:
task.spawn(
    function()
        while task.wait(0.03) do
            local SpeedKillPlayers = {}
            if States.SpeedKillAll then
                for i, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                        SpeedKillPlayers[#SpeedKillPlayers + 1] = v
                    end
                end
            end
            if States.SpeedKillInmates then
                for i, v in pairs(Teams.Inmates:GetPlayers()) do
                    if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                        SpeedKillPlayers[#SpeedKillPlayers + 1] = v
                    end
                end
            end
            if States.SpeedKillGuards then
                for i, v in pairs(Teams.Guards:GetPlayers()) do
                    if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                        SpeedKillPlayers[#SpeedKillPlayers + 1] = v
                    end
                end
            end
            if States.SpeedKillCriminals then
                for i, v in pairs(Teams.Criminals:GetPlayers()) do
                    if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                        SpeedKillPlayers[#SpeedKillPlayers + 1] = v
                    end
                end
            end
            if next(SpeedKillPlayers) then
                SpeedKill(SpeedKillPlayers)
            end
        end
    end
)

--// Reset Armor Spam Flags:
local function ResetArmorSpamFlags(PLR)
    ArmorSpamFlags[PLR.Name] = 0
end

for i, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        ResetArmorSpamFlags(v)
        v.CharacterAdded:Connect(ResetArmorSpamFlags)
    end
end

Players.PlayerAdded:Connect(
    function(PLR)
        PLR.CharacterAdded:Connect(ResetArmorSpamFlags)
    end
)

--// Anti Punch

local function AntiPunchPlayerAdded(PLR)
    PLR.CharacterAdded:Connect(
        function(Char)
            if Char then
                local Humanoid = Char:WaitForChild("Humanoid", 1)
                if Humanoid then
                    Humanoid.AnimationPlayed:Connect(
                        function(AnimationTrack)
                            if States.AntiPunch and CheckProtected(PLR, "killcmds") then
                                if
                                    AnimationTrack.Animation.AnimationId == "rbxassetid://484200742" or
                                        AnimationTrack.Animation.AnimationId == "rbxassetid://484926359" or
                                        AnimationTrack.Animation.AnimationId == "rbxassetid://275012308"
                                 then
                                    pcall(
                                        function()
                                            local VPos = Char:FindFirstChildOfClass("Part").Position
                                            local LPos = LocalPlayer.Character.HumanoidRootPart.Position
                                            local Angle =
                                                math.deg(
                                                math.acos(
                                                    Char.HumanoidRootPart.CFrame.LookVector.unit:Dot((LPos - VPos).unit)
                                                )
                                            )
                                            if Angle < 65 and (LPos - VPos).Magnitude <= 7 then
                                                for i = 1, 15 do
                                                    MeleeEvent(PLR)
                                                end
                                            end
                                        end
                                    )
                                end
                            end
                        end
                    )
                end
            end
        end
    )
end

for i, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        if v.Character then
            AntiPunchPlayerAdded(v)
            local Humanoid = v.Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then
                Humanoid.AnimationPlayed:Connect(
                    function(AnimationTrack)
                        if States.AntiPunch and CheckProtected(v, "killcmds") then
                            if
                                AnimationTrack.Animation.AnimationId == "rbxassetid://484200742" or
                                    AnimationTrack.Animation.AnimationId == "rbxassetid://484926359" or
                                    v.Character:FindFirstChild("Hammer") or
                                    v.Character:FindFirstChild("Crude Knife")
                             then
                                pcall(
                                    function()
                                        local VPos = v.Character:FindFirstChildOfClass("Part").Position
                                        local LPos = LocalPlayer.Character.HumanoidRootPart.Position
                                        local Angle =
                                            math.deg(
                                            math.acos(
                                                v.Character.HumanoidRootPart.CFrame.LookVector.unit:Dot(
                                                    (LPos - VPos).unit
                                                )
                                            )
                                        )
                                        if Angle < 50 and (LPos - VPos).Magnitude <= 7 then
                                            for i = 1, 15 do
                                                MeleeEvent(v)
                                            end
                                        end
                                    end
                                )
                            end
                        end
                    end
                )
            end
        end
    end
end

Players.PlayerAdded:Connect(AntiPunchPlayerAdded)

task.spawn(
    function()
        while task.wait(0.0003) do
            if States.GodMode and not States.GivingKeycard then
                if LocalPlayer.Character then
                    local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if Hum then
                        LoadPos()
                        local Fake = Hum:Clone()
                        Hum:Destroy()
                        Fake.Parent = LocalPlayer.Character
                        pcall(
                            function()
                                LocalPlayer.Character.Animate.Disabled = true
                                LocalPlayer.Character.Animate.Disabled = false
                                Camera.CameraSubject = CurrentlyViewing.Player.Character
                            end
                        )
                        LocalPlayer.CharacterRemoving:wait()
                        SavePos()
                    end
                end
            end
        end
    end
)

--// Forcefield:
task.spawn(
    function()
        while rService.RenderStepped:wait() do
            if States.Forcefield then
                if LocalPlayer.Character then
                    Loadchar("Really red")
                    TeamEvent("Medium stone grey")
                    LoadPos()
                    task.wait(9)
                    SavePos()
                end
            end
        end
    end
)

--// One Punch:
UserInputService.InputBegan:Connect(
    function(INPUT)
        if States.OnePunch and INPUT.UserInputType == Enum.UserInputType.Keyboard and INPUT.KeyCode == Enum.KeyCode.F then
            if not States.PunchAura then
                for i, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and CheckProtected(v, "killcmds") then
                        if v.Character then
                            pcall(
                                function()
                                    local VPart = v.Character.PrimaryPart
                                    local PPart = LocalPlayer.Character.PrimaryPart
                                    local Angle =
                                        math.deg(
                                        math.acos(
                                            LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector.unit:Dot(
                                                (VPart.Position - PPart.Position).unit
                                            )
                                        )
                                    )
                                    if Angle < 50 and (PPart.Position - VPart.Position).Magnitude <= 7 then
                                        for i = 1, 15 do
                                            MeleeEvent(v)
                                        end
                                    end
                                end
                            )
                        end
                    end
                end
            else
                local Character = ClosestCharacter(20)
                if Character then
                    for i = 1, 15 do
                        MeleeEvent(Players:GetPlayerFromCharacter(Character))
                    end
                end
            end
        end
    end
)

--// Anti Armor Spam:
task.spawn(
    function()
        while task.wait(0.03) do
            for i, v in pairs(Players:GetPlayers()) do
                if v.Character then
                    for _, object in pairs(v.Character:GetChildren()) do
                        if object.Name == "vest" then
                            object:Destroy()
                            if not ArmorSpamFlags[v.Name] then
                                ArmorSpamFlags[v.Name] = 1
                            else
                                ArmorSpamFlags[v.Name] = ArmorSpamFlags[v.Name] + 1
                            end
                        end
                    end
                end
            end
        end
    end
)

--- Anti Bring ---
LocalPlayer.CharacterAdded:Connect(
    function(CHAR)
        CHAR.ChildAdded:Connect(
            function(ITEM)
                if States.AntiBring then
                    if ITEM:IsA("Tool") then
                        if not CheckWhitelisted(ITEM) then
                            ITEM:Destroy()
                            pcall(
                                function()
                                    SavePos(POS)
                                    local char = game.Players.LocalPlayer.character
                                    local char1 = char:clone()
                                    char:destroy()
                                    char1 = char
                                    ITEM:Destroy()
                                    wait(6)
                                    LoadPos()
                                end
                            )
                        end
                    end
                end
            end
        )
    end
)

--// Anti Arrest Lag:
Info.Arrest = 0
task.spawn(
    function()
        while task.wait(0.03) do
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character then
                    local Head = v.Character:FindFirstChild("Head")
                    if Head then
                        for _, object in pairs(Head:GetChildren()) do
                            if object.Name == "handcuffedGui" then
                                object:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
)

--// Anti Void:
task.spawn(
    function()
        while task.wait(0.03) do
            if LocalPlayer.Character then
                if LocalPlayer.Character.PrimaryPart then
                    if LocalPlayer.Character.PrimaryPart.Position.Y < 1 then
                        Teleport(LocalPlayer, CFrame.new(888, 100, 2388))
                        pcall(
                            function()
                                for i, v in pairs(LocalPlayer.Character:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.Velocity = Vector3.new()
                                    end
                                end
                            end
                        )
                    end
                end
            end
        end
    end
)

--// Inf Ammo Auto Reload:
task.spawn(
    function()
        while task.wait(1) do
            if next(AmmoGuns) then
                for i, v in next, AmmoGuns do
                    rStorage.ReloadEvent:FireServer(v)
                end
            end
        end
    end
)

--// Spam Punch:
task.spawn(
    function()
        while task.wait(0.03) do
            if States.SpamPunch and PunchFunction then
                if UserInputService:IsKeyDown(Enum.KeyCode.F) then
                    coroutine.wrap(PunchFunction)()
                end
            end
        end
    end
)

--// Anti Fling:
rService.Stepped:Connect(
    function()
        if States.AntiFling then
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer then
                    if v.Character then
                        for _, object in pairs(v.Character:GetChildren()) do
                            if object:IsA("BasePart") then
                                object.CanCollide = false
                            end
                            if object:IsA("Accessory") then
                                pcall(
                                    function()
                                        object.Handle.CanCollide = false
                                    end
                                )
                            end
                        end
                    end
                end
            end
        end
    end
)

--// Anti Spam Arrest
LocalPlayer.CharacterAdded:Connect(
    function(CHAR)
        if not Info.StopRespawnLag then
            local ClientInputHandler = CHAR:WaitForChild("ClientInputHandler", 1)
            if ClientInputHandler then
                --YieldUntilScriptLoaded(ClientInputHandler);
                task.wait(1)
                pcall(
                    function()
                        local Senv = getsenv(ClientInputHandler)
                        local OldMT = Senv.cs
                        Senv.cs =
                            setmetatable(
                            {},
                            {
                                __newindex = function(Table, Index, Value)
                                    if Index == "isArrested" and Value == true then
                                        pcall(
                                            function()
                                                Loadchar("Bright blue")
                                                LoadPos()
                                                HasBeenArrested = true
                                            end
                                        )
                                    end
                                    if Index == "isFighting" then
                                        Value = false
                                    end
                                    if Index == "isCrouching" then
                                        Info.Crouching = Value
                                    end
                                    OldMT[Index] = Value
                                end,
                                __index = OldMT
                            }
                        )
                    end
                )
            end
            --// Anti Tase:
            task.spawn(
                function()
                    task.wait(1)
                    for i, v in pairs(getconnections(workspace.Remote.tazePlayer.OnClientEvent)) do
                        v:Disable()
                    end
                end
            )
        end
    end
)

--[[local ClientInputHandler = game:GetService("StarterPlayer").StarterCharacterScripts.ClientInputHandler
if ClientInputHandler then
--YieldUntilScriptLoaded(ClientInputHandler);
local Senv = getsenv(ClientInputHandler);
local OldMT = Senv.cs;
Senv.cs = setmetatable({},{
__newindex = function(Table, Index, Value)
if Index == "isArrested" and Value == true then
   pcall(function()
   LocalPlayer.Character:Destroy();
   Loadchar("Bright blue");
   LoadPos();
   HasBeenArrested = true;
   end);
   end;
   if Index == "isFighting" then
      Value = false;
   end
   if Index == "isCrouching" then
      Info.Crouching = Value;
      end;
      OldMT[Index] = Value;
      end;
      __index = OldMT;
   });

   --// Anti Tase:
   task.spawn(function()
   task.wait(1);
   for i,v in pairs(getconnections(workspace.Remote.tazePlayer.OnClientEvent)) do
      v:Disable();
      end;
      end);
      end;]]
task.spawn(
    function()
        while rService.Heartbeat:wait() do
            pcall(
                function()
                    if LocalPlayer.Character.Head:FindFirstChild("handcuffedGui") then
                        Loadchar("Bright blue")
                        LoadPos()
                        HasBeenArrested = true
                    end
                end
            )
        end
    end
)

--// Auto Anti Spam Arrest
Info.LastArrestTime = 0
Info.LastNotifiedArrest = 0
Info.Arrested = 0
LocalPlayer.CharacterAdded:Connect(
    function(Char)
        local Head = Char:WaitForChild("Head", 1)
        if Head then
            Head.ChildAdded:Connect(
                function(Child)
                    if Child.Name == "handcuffedGui" then
                        if tick() - Info.LastArrestTime <= 0.1 then
                            Info.Arrested = Info.Arrested + 1
                            Info.LastArrestTime = tick()
                        else
                            Info.Arrested = 0
                            Info.LastArrestTime = tick()
                        end
                        if Info.Arrested >= 2 then
                            if tick() - Info.LastNotifiedArrest >= 5 then
                                Notify(
                                    "Success",
                                    "Wrath Admin has detected a spam arrest exploit and turned on anti-criminal + anti-bring.",
                                    5
                                )
                                Info.LastNotifiedArrest = tick()
                            end
                            ChangeGuiToggle(true, "Anti-Criminal")
                            ChangeGuiToggle(true, "Anti-Bring")
                            Loadchar("Bright blue")
                            States.AntiCriminal = true
                            States.AntiBring = true
                        end
                        coroutine.wrap(
                            function()
                                task.wait()
                                Child:Destroy()
                            end
                        )()
                    --print(Info.Arrested)
                    end
                end
            )
        end
    end
)

Info.LastRespawnTime = 0
LocalPlayer.CharacterAdded:Connect(
    function(Char)
        if tick() - Info.LastRespawnTime <= 0.5 then
            Info.StopRespawnLag = true
        else
            Info.StopRespawnLag = false
        end
        Info.LastRespawnTime = tick()
    end
)

--// Anti Crash:
task.spawn(
    function()
        for i, v in pairs(getconnections(rStorage:WaitForChild("ReplicateEvent").OnClientEvent)) do
            v:Enable()
        end
    end
)
local KillDebounce = 0.2
local TeleportDebounce = 0.5
local CurrentTime = 0
local TeleportTime = 0

--// Get Player Hit
function GetPlayerHit(Part)
    for i, v in pairs(Players:GetPlayers()) do
        if v.Character:IsAncestorOf(Part) then
            return v
        end
    end
end

--// Combat Logs:
local function OnReplicateEvent(Args)
    --[[if States.CombatLogs then
         print("=== SHOT GUN ===");
         end;]]
    local Count = 0
    if not States.AntiCrash then
        pcall(
            function()
                for i, v in next, Args do
                    if Count <= 5 then
                        local Hit, Distance, Cframe, RayObject = v.Hit, v.Distance, v.Cframe, v.RayObject
                        if Hit and Distance and Cframe then
                            if Cframe ~= CFrame.new() then
                                local PlayerHit, WhoShot = GetPlayerHit(Hit) --Players:GetPlayerFromCharacter(Hit.Parent);

                                local CalculatedCFrame = Cframe * CFrame.new(0, 0, -Distance / 2)

                                local Success, Error =
                                    pcall(
                                    function()
                                        WhoShot = GetClosestPlayerToPosition(CalculatedCFrame.p)
                                    end
                                )

                                local ShotWith = WhoShot.Character:FindFirstChildOfClass("Tool")

                                if Success and WhoShot then
                                    local Hit, HitPosition = workspace:FindPartOnRay(RayObject, WhoShot.Character)

                                    if States.CombatLogs then
                                        if PlayerHit then
                                            print("Bullet -- " .. tostring(i))
                                            print("Shot From:", WhoShot, "(" .. tostring(WhoShot.Team) .. ")")
                                            if PlayerHit then
                                                print("Hit Player:", PlayerHit, "(" .. tostring(PlayerHit.Team) .. ")")
                                            else
                                                print("Hit Part:", Hit)
                                            end
                                            print("Shot With:", ShotWith)
                                            print("Distance:", Distance)
                                        end
                                    end
                                    if States.ShootBack then
                                        if PlayerHit then
                                            if PlayerHit == LocalPlayer then
                                                if
                                                    CheckProtected(WhoShot, "killcmds") and
                                                        WhoShot.TeamColor ~= LocalPlayer.TeamColor
                                                 then
                                                    if tick() - CurrentTime >= KillDebounce then
                                                        CurrentTime = tick()
                                                        if LocalPlayer.Character.Humanoid.Health <= 0 then
                                                            LocalPlayer.CharacterAdded:wait()
                                                        end
                                                        Kill({WhoShot})
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if States.TaseBack then
                                        if PlayerHit then
                                            if PlayerHit == LocalPlayer and PlayerHit.TeamColor.Name ~= "Bright blue" then
                                                if CheckProtected(WhoShot, "killcmds") then
                                                    if tick() - CurrentTime >= KillDebounce then
                                                        CurrentTime = tick()
                                                        Tase({WhoShot})
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if PlayerHit and WhoShot then
                                        if Oneshots[WhoShot.UserId] then
                                            if
                                                CheckProtected(PlayerHit, "killcmds") and
                                                    WhoShot.TeamColor ~= PlayerHit.TeamColor
                                             then
                                                if tick() - CurrentTime >= KillDebounce then
                                                    CurrentTime = tick()
                                                    Kill({PlayerHit})
                                                end
                                            end
                                        end
                                        if AntiShoots[PlayerHit.UserId] then
                                            if
                                                CheckProtected(WhoShot, "killcmds") and
                                                    WhoShot.TeamColor ~= PlayerHit.TeamColor
                                             then
                                                if tick() - CurrentTime >= KillDebounce then
                                                    CurrentTime = tick()
                                                    Kill({WhoShot})
                                                end
                                            end
                                        end
                                        if TaseBacks[PlayerHit.UserId] then
                                            if
                                                CheckProtected(WhoShot, "killcmds") and
                                                    WhoShot.TeamColor.Name ~= "Bright blue"
                                             then
                                                if tick() - CurrentTime >= KillDebounce then
                                                    CurrentTime = tick()
                                                    Tase({WhoShot})
                                                end
                                            end
                                        end
                                    end
                                    if Hit and HitPosition and WhoShot then
                                        if ClickTeleports[WhoShot.UserId] then
                                            if tick() - CurrentTime >= TeleportDebounce then
                                                CurrentTime = tick()
                                                Teleport(WhoShot, CFrame.new(HitPosition) * CFrame.new(0, 2, 0))
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        Count = Count + 1
                    end
                end
            end
        )
    end
    --[[if States.CombatLogs then
         print("=== END ===");
         end;]]
end

task.spawn(
    function()
        rStorage:WaitForChild("ReplicateEvent").OnClientEvent:Connect(OnReplicateEvent)
    end
)
--// Friendly Fire + Disable Gun Animations

local DebounceTime = 0

MT.__namecall =
    newcclosure(
    loadstring(
        [[
      local __Namecall, States, Info, Players, ClosestCharacter, LocalPlayer, MeleeEvent, DebounceTime, rStorage = ...
      return function(Self, ...)
      local Args = {...}
      local Method = getnamecallmethod();

      if States.FriendlyFire and Method == "FireServer" and tostring(Self) == "ShootEvent" then
         local ValidPlayer = Players.GetPlayerFromCharacter(Players, Args[1][1].Hit.Parent) or Players.GetPlayerFromCharacter(Players, Args[1][1].Hit);
         if ValidPlayer then
            task.spawn(function()
            if Info.FriendlyFireOldTeam == "Bright orange" or Info.FriendlyFireOldTeam == "Bright blue" then
               workspace.Remote.TeamEvent:FireServer("Medium stone grey");
               task.wait(0.03);
               workspace.Remote.TeamEvent:FireServer(Info.FriendlyFireOldTeam);
               end;
               end)
               end;
               end;
               if States.OneShot and Method == "FireServer" and tostring(Self) == "ShootEvent" then
                  local ValidPlayer = Players.GetPlayerFromCharacter(Players, Args[1][1].Hit.Parent) or Players.GetPlayerFromCharacter(Players, Args[1][1].Hit);
                  if ValidPlayer then
                     if ValidPlayer.TeamColor ~= LocalPlayer.TeamColor then
                        coroutine.wrap(Kill)({ValidPlayer});
                        end;
                        end;
                        end;
                        if States.PunchAura and not Info.Crouching then
                           if Method == "FindPartOnRay" and tostring(getfenv(0).script) ~= "GunInterface" and tostring(getfenv(0).script) ~= "TaserInterface" then
                              if LocalPlayer.Character then
                                 if LocalPlayer.Character.PrimaryPart then
                                    local Character = ClosestCharacter(math.huge);
                                    if Character then
                                       if game.FindFirstChild(Character, "Head") then
                                          return Character.Head, Character.Head.Position;
                                          end;
                                          end;
                                          end;
                                          end;
                                          end;
                                          end;
                                          if States.LoudPunch then
                                             if Method == "FireServer" and tostring(Self) == "meleeEvent" then
                                                pcall(function()
                                                for i,v in pairs(Workspace:GetChildren()) do
                                                   if game.Players:FindFirstChild(v.Name) then
                                                      s = v.Head.punchSound
                                                      s.Volume = math.huge
                                                      game:GetService("ReplicatedStorage").SoundEvent:FireServer(s)
                                                   end
                                                end
                                                end)
                                                end;
                                             end
                                             return __Namecall(Self, unpack(Args));
                                             end;
                                             ]]
    )(__Namecall, States, Info, Players, ClosestCharacter, LocalPlayer, MeleeEvent, DebounceTime, rStorage)
)

--// Anti Trip:
LocalPlayer.CharacterAdded:Connect(
    function(CHAR)
        local Humanoid = CHAR:WaitForChild("Humanoid", 1)
        if Humanoid then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end
)

--// Auto Gun Mods:
LocalPlayer.CharacterAdded:Connect(
    function(CHAR)
        CHAR.ChildAdded:Connect(
            function(Tool)
                ModGun(Tool)
            end
        )
    end
)

--// Metatable Hooks:
MT.__index =
    newcclosure(
    loadstring(
        [[
                                             local IndexMT = ...
                                             return function(Table, Index)
                                             if tostring(Table) == "Status" then
                                                if tostring(Index) == "isBadGuard" or tostring(Index) == "toolIsEquipped" then
                                                   return false;
                                                   end;
                                                   if tostring(Index) == "playerCell" then
                                                      return nil;
                                                   end
                                                   end;
                                                   if tostring(Table) == "Humanoid" and Index == "PlatformStand" then
                                                      return false;
                                                      end;
                                                      return IndexMT(Table, Index)
                                                      end;
                                                      ]]
    )(IndexMT)
)

--// INF stamina:
MT.__newindex =
    newcclosure(
    loadstring(
        [[
                                                      local NewIndex = ...
                                                      return function(Table, Index, Value)
                                                      if tostring(Table) == "Humanoid" and Index == "Jump" and not Value then
                                                         return
                                                         end;

                                                         return NewIndex(Table, Index, Value);
                                                         end;
                                                         ]]
    )(NewIndex)
)

loadstring(
    [[
                                                         local TooltipModule = ...
                                                         local OldUpdate = TooltipModule.update
                                                         OldUpdate = hookfunction(TooltipModule.update, function(Message)
                                                         if Message == "You don't have enough stamina!" then
                                                            return
                                                            end;
                                                            return OldUpdate(Message)
                                                            end);
                                                            ]]
)(TooltipModule)

--// Anti Criminal:
--[[LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
                                                            if tostring(LocalPlayer.Team) ~= "Guards" and #Teams.Guards:GetPlayers() >= 8 and not States.SpamArresting and not States.Forcefield and States.AntiCriminal then
                                                               SavePos();
                                                               Loadchar("Bright blue")
                                                               LoadPos();
                                                               end;
                                                               end);]]

-- Anti Crim Anti Criminal Anticrim Anticriminal 

local isplayerteam = tostring(LocalPlayer.Team)
rService.Heartbeat:Connect(
    function()
        if States.AntiCriminal then
            if isplayerteam == "Really red" or "Criminals" or "bright orange" or "Inmates" or "Neutral" then
                States.GodMode = true
                TeamEvent("Bright blue")
                States.GodMode = false
            elseif isplayerteam ~= "Bright blue" or "Guards" then
                States.GodMode = true
                TeamEvent("Bright blue")
                States.GodMode = false
            end
        end
    end
)

--// Command Queue
task.spawn(
    function()
        while task.wait(0.03) do
            for i, Command in next, CommandQueue do
                if next(CommandQueue) then
                    Command()
                    table.remove(CommandQueue, i)
                    task.wait(1)
                end
            end
        end
    end
)

--// Chat Queue:
task.spawn(
    function()
        while task.wait(0.03) do
            for i, Chat in next, ChatQueue do
                if next(ChatQueue) then
                    Chat()
                    table.remove(ChatQueue, i)
                    task.wait(1)
                end
            end
        end
    end
)

--// Command Bar:
-- Gui
local WrathCommandBar = Instance.new("ScreenGui")
local Bar = Instance.new("Frame")
local StartLine = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")

WrathCommandBar.Name = "WrathCommandBar"
WrathCommandBar.Parent = game.CoreGui
WrathCommandBar.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Bar.Name = "Bar"
Bar.Parent = WrathCommandBar
Bar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Bar.BackgroundTransparency = 0.500
Bar.BorderSizePixel = 0
Bar.Position = UDim2.new(1.49011612e-08, 0, 0.934272289, 0)
Bar.Size = UDim2.new(1, 0, 0.0657276958, 0)

StartLine.Name = "StartLine"
StartLine.Parent = Bar
StartLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StartLine.BackgroundTransparency = 1.000
StartLine.Size = UDim2.new(0.0509554148, 0, 1, 0)
StartLine.Font = Enum.Font.Code
StartLine.Text = ">"
StartLine.TextColor3 = Color3.fromRGB(255, 255, 255)
StartLine.TextScaled = true
StartLine.TextSize = 1.000
StartLine.TextWrapped = true

TextBox.Parent = Bar
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundTransparency = 1.000
TextBox.BorderColor3 = Color3.fromRGB(27, 42, 53)
TextBox.Position = UDim2.new(0.0509554148, 0, 0, 0)
TextBox.Size = UDim2.new(0.949044585, 0, 1, 0)
TextBox.Font = Enum.Font.Code
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextScaled = true
TextBox.TextSize = 14.000
TextBox.TextWrapped = true
TextBox.ClearTextOnFocus = false
TextBox.TextXAlignment = Enum.TextXAlignment.Left

Bar.Position = UDim2.new(0, 0, 1, 0)

UserInputService.InputBegan:Connect(
    function(INPUT, CHATTING)
        if CHATTING then
            return
        end
        if INPUT.UserInputType == Enum.UserInputType.Keyboard and INPUT.KeyCode == Enum.KeyCode[OpenCommandBarKey] then
            TextBox.Text = ""
            Bar:TweenPosition(UDim2.new(0, 0, 0.900, 0), "Out", "Quad", 0.2, true)
            task.wait(0.03)
            TextBox:CaptureFocus()
        end
    end
)

TextBox.FocusLost:Connect(
    function()
        Bar:TweenPosition(UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.2, true)
        coroutine.wrap(UseCommand)(Settings.Prefix .. TextBox.Text)
        task.wait(1 / 5)
        TextBox.Text = ""
    end
)

--// GUI
local function makeDraggable(obj)
    --// Original code by Tiffblocks, edited so that it has a cool tween to it.
    local gui = obj

    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        local EndPos =
            UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        local Tween = TweenService:Create(gui, TweenInfo.new(0.2), {Position = EndPos})
        Tween:Play()
    end

    gui.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position

                input.Changed:Connect(
                    function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end
                )
            end
        end
    )

    gui.InputChanged:Connect(
        function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch
             then
                dragInput = input
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end
    )
end

-------------------------- :::COMMAND GUI::: -------------------------------

-------------------------- :::COMMAND GUI::: -------------------------------

-------------------------- :::COMMAND GUI::: -------------------------------

-------------------------- :::COMMAND GUI::: -------------------------------
-- Instances:

local MainGuiObjects = {
    WrathAdminGuiMain = Instance.new("ScreenGui"),
    Stats = Instance.new("Frame"),
    TemplateTopbar = Instance.new("Frame"),
    TemplateTopbarRound = Instance.new("UICorner"),
    TemplateTitle = Instance.new("TextLabel"),
    PlayerListRound = Instance.new("UICorner"),
    StatesListFrame = Instance.new("ScrollingFrame"),
    UIListLayout = Instance.new("UIListLayout"),
    Stat = Instance.new("TextButton"),
    UICorner = Instance.new("UICorner"),
    TextLabel = Instance.new("TextLabel"),
    Stat_2 = Instance.new("TextButton"),
    UICorner_2 = Instance.new("UICorner"),
    TextLabel_2 = Instance.new("TextLabel"),
    Stat_3 = Instance.new("TextButton"),
    UICorner_3 = Instance.new("UICorner"),
    TextLabel_3 = Instance.new("TextLabel"),
    GetPlayers = Instance.new("Frame"),
    TemplateTopbar_2 = Instance.new("Frame"),
    TemplateTopbarRound_2 = Instance.new("UICorner"),
    TemplateTitle_2 = Instance.new("TextLabel"),
    PlayerListRound_2 = Instance.new("UICorner"),
    GetPlayersContent = Instance.new("ScrollingFrame"),
    TextButton = Instance.new("TextButton"),
    UICorner_4 = Instance.new("UICorner"),
    TextButton_2 = Instance.new("TextButton"),
    UICorner_5 = Instance.new("UICorner"),
    TextButton_3 = Instance.new("TextButton"),
    UICorner_6 = Instance.new("UICorner"),
    TextButton_4 = Instance.new("TextButton"),
    UICorner_7 = Instance.new("UICorner"),
    TextButton_5 = Instance.new("TextButton"),
    UICorner_8 = Instance.new("UICorner"),
    TextButton_6 = Instance.new("TextButton"),
    UICorner_9 = Instance.new("UICorner"),
    TextButton_7 = Instance.new("TextButton"),
    UICorner_10 = Instance.new("UICorner"),
    TextButton_8 = Instance.new("TextButton"),
    UICorner_11 = Instance.new("UICorner"),
    UIListLayout_2 = Instance.new("UIListLayout"),
    TextButton_9 = Instance.new("TextButton"),
    UICorner_12 = Instance.new("UICorner"),
    PlayerList = Instance.new("Frame"),
    ListTopbar = Instance.new("Frame"),
    ListTopbarRound = Instance.new("UICorner"),
    ListTitle = Instance.new("TextLabel"),
    PlayerListFrame = Instance.new("ScrollingFrame"),
    UIListLayout_3 = Instance.new("UIListLayout"),
    TextButton_10 = Instance.new("TextButton"),
    UICorner_13 = Instance.new("UICorner"),
    PlayerListRound_3 = Instance.new("UICorner"),
    Toggles = Instance.new("Frame"),
    TogglesTopbar = Instance.new("Frame"),
    TemplateTopbarRound_3 = Instance.new("UICorner"),
    TogglesTitle = Instance.new("TextLabel"),
    PlayerListRound_4 = Instance.new("UICorner"),
    TogglesListFrame = Instance.new("ScrollingFrame"),
    UIListLayout_4 = Instance.new("UIListLayout"),
    Toggle = Instance.new("TextButton"),
    UICorner_14 = Instance.new("UICorner"),
    TextLabel_4 = Instance.new("TextLabel"),
    Toggle_2 = Instance.new("TextButton"),
    UICorner_15 = Instance.new("UICorner"),
    TextLabel_5 = Instance.new("TextLabel"),
    Toggle_3 = Instance.new("TextButton"),
    UICorner_16 = Instance.new("UICorner"),
    TextLabel_6 = Instance.new("TextLabel"),
    Toggle_4 = Instance.new("TextButton"),
    UICorner_17 = Instance.new("UICorner"),
    TextLabel_7 = Instance.new("TextLabel"),
    Toggle_5 = Instance.new("TextButton"),
    UICorner_18 = Instance.new("UICorner"),
    TextLabel_8 = Instance.new("TextLabel"),
    Toggle_6 = Instance.new("TextButton"),
    UICorner_19 = Instance.new("UICorner"),
    TextLabel_9 = Instance.new("TextLabel"),
    ImmunitySettings = Instance.new("Frame"),
    ImmunityTopbar = Instance.new("Frame"),
    TemplateTopbarRound_4 = Instance.new("UICorner"),
    TogglesTitle_2 = Instance.new("TextLabel"),
    PlayerListRound_5 = Instance.new("UICorner"),
    ImmunityListFrame = Instance.new("ScrollingFrame"),
    UIListLayout_5 = Instance.new("UIListLayout"),
    Toggle_7 = Instance.new("TextButton"),
    UICorner_20 = Instance.new("UICorner"),
    TextLabel_10 = Instance.new("TextLabel"),
    Toggle_8 = Instance.new("TextButton"),
    UICorner_21 = Instance.new("UICorner"),
    TextLabel_11 = Instance.new("TextLabel"),
    Toggle_9 = Instance.new("TextButton"),
    UICorner_22 = Instance.new("UICorner"),
    TextLabel_12 = Instance.new("TextLabel"),
    Toggle_10 = Instance.new("TextButton"),
    UICorner_23 = Instance.new("UICorner"),
    TextLabel_13 = Instance.new("TextLabel"),
    Toggle_11 = Instance.new("TextButton"),
    UICorner_24 = Instance.new("UICorner"),
    TextLabel_14 = Instance.new("TextLabel"),
    Toggle_12 = Instance.new("TextButton"),
    UICorner_25 = Instance.new("UICorner"),
    TextLabel_15 = Instance.new("TextLabel"),
    AdminSettings = Instance.new("Frame"),
    AdminTopbar = Instance.new("Frame"),
    TemplateTopbarRound_5 = Instance.new("UICorner"),
    TogglesTitle_3 = Instance.new("TextLabel"),
    PlayerListRound_6 = Instance.new("UICorner"),
    AdminListFrame = Instance.new("ScrollingFrame"),
    UIListLayout_6 = Instance.new("UIListLayout"),
    Toggle_13 = Instance.new("TextButton"),
    UICorner_26 = Instance.new("UICorner"),
    TextLabel_16 = Instance.new("TextLabel"),
    Toggle_14 = Instance.new("TextButton"),
    UICorner_27 = Instance.new("UICorner"),
    TextLabel_17 = Instance.new("TextLabel"),
    Toggle_15 = Instance.new("TextButton"),
    UICorner_28 = Instance.new("UICorner"),
    TextLabel_18 = Instance.new("TextLabel"),
    Toggle_16 = Instance.new("TextButton"),
    UICorner_29 = Instance.new("UICorner"),
    TextLabel_19 = Instance.new("TextLabel"),
    Toggle_17 = Instance.new("TextButton"),
    UICorner_30 = Instance.new("UICorner"),
    TextLabel_20 = Instance.new("TextLabel"),
    Commands = Instance.new("Frame"),
    CommandsTopbar = Instance.new("Frame"),
    TemplateTopbarRound_6 = Instance.new("UICorner"),
    TogglesTitle_4 = Instance.new("TextLabel"),
    PlayerListRound_7 = Instance.new("UICorner"),
    CommandsListFrame = Instance.new("ScrollingFrame"),
    UIListLayout_7 = Instance.new("UIListLayout"),
    Command = Instance.new("TextButton"),
    UICorner_31 = Instance.new("UICorner"),
    Output = Instance.new("Frame"),
    TemplateTopbar_3 = Instance.new("Frame"),
    TemplateTopbarRound_7 = Instance.new("UICorner"),
    TemplateTitle_3 = Instance.new("TextLabel"),
    PlayerListRound_8 = Instance.new("UICorner"),
    OutputListFrame = Instance.new("ScrollingFrame"),
    UIListLayout_8 = Instance.new("UIListLayout"),
    Log = Instance.new("TextButton"),
    UICorner_32 = Instance.new("UICorner")
}

--Properties:

MainGuiObjects.WrathAdminGuiMain.Name = "WrathAdminGuiMain"
MainGuiObjects.WrathAdminGuiMain.Parent = CoreGui
MainGuiObjects.WrathAdminGuiMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainGuiObjects.Stats.Name = "Stats"
MainGuiObjects.Stats.Parent = MainGuiObjects.WrathAdminGuiMain
MainGuiObjects.Stats.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.Stats.BorderSizePixel = 0
MainGuiObjects.Stats.Position = UDim2.new(0.280947268, 81, 0.657276988, -223)
MainGuiObjects.Stats.Size = UDim2.new(0, 242, 0, 164)
makeDraggable(MainGuiObjects.Stats)

MainGuiObjects.TemplateTopbar.Name = "TemplateTopbar"
MainGuiObjects.TemplateTopbar.Parent = MainGuiObjects.Stats
MainGuiObjects.TemplateTopbar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TemplateTopbar.BorderSizePixel = 0
MainGuiObjects.TemplateTopbar.Size = UDim2.new(0, 242, 0, 31)

MainGuiObjects.TemplateTopbarRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TemplateTopbarRound.Name = "TemplateTopbarRound"
MainGuiObjects.TemplateTopbarRound.Parent = MainGuiObjects.TemplateTopbar

MainGuiObjects.TemplateTitle.Name = "TemplateTitle"
MainGuiObjects.TemplateTitle.Parent = MainGuiObjects.TemplateTopbar
MainGuiObjects.TemplateTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TemplateTitle.BackgroundTransparency = 1.000
MainGuiObjects.TemplateTitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TemplateTitle.Size = UDim2.new(0, 242, 0, 31)
MainGuiObjects.TemplateTitle.Font = Enum.Font.Code
MainGuiObjects.TemplateTitle.Text = "Stats"
MainGuiObjects.TemplateTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TemplateTitle.TextSize = 31.000

MainGuiObjects.PlayerListRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound.Parent = MainGuiObjects.Stats

MainGuiObjects.StatesListFrame.Name = "StatesListFrame"
MainGuiObjects.StatesListFrame.Parent = MainGuiObjects.Stats
MainGuiObjects.StatesListFrame.Active = true
MainGuiObjects.StatesListFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.StatesListFrame.BorderSizePixel = 0
MainGuiObjects.StatesListFrame.Position = UDim2.new(0.02892562, 0, 0.248236686, 0)
MainGuiObjects.StatesListFrame.Size = UDim2.new(0, 225, 0, 114)
MainGuiObjects.StatesListFrame.ScrollBarThickness = 1

MainGuiObjects.UIListLayout.Parent = MainGuiObjects.StatesListFrame
MainGuiObjects.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MainGuiObjects.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout.Padding = UDim.new(0, 5)

MainGuiObjects.Stat.Name = "Stat"
MainGuiObjects.Stat.Parent = MainGuiObjects.StatesListFrame
MainGuiObjects.Stat.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Stat.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Stat.BorderSizePixel = 0
MainGuiObjects.Stat.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Stat.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Stat.Font = Enum.Font.Code
MainGuiObjects.Stat.Text = " Ping"
MainGuiObjects.Stat.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Stat.TextSize = 14.000
MainGuiObjects.Stat.TextXAlignment = Enum.TextXAlignment.Left

MainGuiObjects.UICorner.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner.Parent = MainGuiObjects.Stat

MainGuiObjects.TextLabel.Parent = MainGuiObjects.Stat
MainGuiObjects.TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel.Font = Enum.Font.Code
MainGuiObjects.TextLabel.Text = "100"
MainGuiObjects.TextLabel.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel.TextSize = 14.000
MainGuiObjects.TextLabel.TextXAlignment = Enum.TextXAlignment.Right

MainGuiObjects.Stat_2.Name = "Stat"
MainGuiObjects.Stat_2.Parent = MainGuiObjects.StatesListFrame
MainGuiObjects.Stat_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Stat_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Stat_2.BorderSizePixel = 0
MainGuiObjects.Stat_2.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Stat_2.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Stat_2.Font = Enum.Font.Code
MainGuiObjects.Stat_2.Text = " FPS"
MainGuiObjects.Stat_2.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Stat_2.TextSize = 14.000
MainGuiObjects.Stat_2.TextXAlignment = Enum.TextXAlignment.Left

MainGuiObjects.UICorner_2.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_2.Parent = MainGuiObjects.Stat_2

MainGuiObjects.TextLabel_2.Parent = MainGuiObjects.Stat_2
MainGuiObjects.TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_2.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_2.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_2.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_2.Font = Enum.Font.Code
MainGuiObjects.TextLabel_2.Text = ""
MainGuiObjects.TextLabel_2.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_2.TextSize = 14.000
MainGuiObjects.TextLabel_2.TextXAlignment = Enum.TextXAlignment.Right

------------ MEASURE PING + FPS --------------
task.spawn(
    function()
        while task.wait(0.03) do
            local Ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() or "nil"
            local FPS = math.floor(1 / rService.RenderStepped:wait())
            MainGuiObjects.TextLabel.Text = "  " .. Ping:split(" ")[1]
            MainGuiObjects.TextLabel_2.Text = "  " .. FPS
        end
    end
)

MainGuiObjects.Stat_3.Name = "Stat"
MainGuiObjects.Stat_3.Parent = MainGuiObjects.StatesListFrame
MainGuiObjects.Stat_3.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Stat_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Stat_3.BorderSizePixel = 0
MainGuiObjects.Stat_3.Position = UDim2.new(-0.00444444455, 0, 0.00902553741, 0)
MainGuiObjects.Stat_3.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Stat_3.Font = Enum.Font.Code
MainGuiObjects.Stat_3.Text = " Run Time"
MainGuiObjects.Stat_3.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Stat_3.TextSize = 14.000
MainGuiObjects.Stat_3.TextXAlignment = Enum.TextXAlignment.Left

MainGuiObjects.UICorner_3.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_3.Parent = MainGuiObjects.Stat_3

MainGuiObjects.TextLabel_3.Parent = MainGuiObjects.Stat_3
MainGuiObjects.TextLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_3.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_3.Position = UDim2.new(0.715555549, 0, 0, 0)
MainGuiObjects.TextLabel_3.Size = UDim2.new(0, 64, 0, 25)
MainGuiObjects.TextLabel_3.Font = Enum.Font.Code
MainGuiObjects.TextLabel_3.Text = "0:00:00"
MainGuiObjects.TextLabel_3.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_3.TextSize = 14.000
MainGuiObjects.TextLabel_3.TextXAlignment = Enum.TextXAlignment.Right

--------- RUN TIME --------
task.spawn(
    function()
        while task.wait(0.03) do
            MainGuiObjects.TextLabel_3.Text = tostring(math.floor(tick() - ExecutionTime))
        end
    end
)

MainGuiObjects.GetPlayers.Name = "GetPlayers"
MainGuiObjects.GetPlayers.Parent = MainGuiObjects.WrathAdminGuiMain
MainGuiObjects.GetPlayers.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.GetPlayers.BorderSizePixel = 0
MainGuiObjects.GetPlayers.Position = UDim2.new(0.0118407542, 744, 0.017214397, 334)
MainGuiObjects.GetPlayers.Size = UDim2.new(0, 242, 0, 361)
makeDraggable(MainGuiObjects.GetPlayers)

MainGuiObjects.TemplateTopbar_2.Name = "TemplateTopbar"
MainGuiObjects.TemplateTopbar_2.Parent = MainGuiObjects.GetPlayers
MainGuiObjects.TemplateTopbar_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TemplateTopbar_2.BorderSizePixel = 0
MainGuiObjects.TemplateTopbar_2.Size = UDim2.new(0, 242, 0, 31)

MainGuiObjects.TemplateTopbarRound_2.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TemplateTopbarRound_2.Name = "TemplateTopbarRound"
MainGuiObjects.TemplateTopbarRound_2.Parent = MainGuiObjects.TemplateTopbar_2

MainGuiObjects.TemplateTitle_2.Name = "TemplateTitle"
MainGuiObjects.TemplateTitle_2.Parent = MainGuiObjects.TemplateTopbar_2
MainGuiObjects.TemplateTitle_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TemplateTitle_2.BackgroundTransparency = 1.000
MainGuiObjects.TemplateTitle_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TemplateTitle_2.Size = UDim2.new(0, 242, 0, 31)
MainGuiObjects.TemplateTitle_2.Font = Enum.Font.Code
MainGuiObjects.TemplateTitle_2.Text = "Get Players"
MainGuiObjects.TemplateTitle_2.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TemplateTitle_2.TextSize = 31.000

MainGuiObjects.PlayerListRound_2.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound_2.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound_2.Parent = MainGuiObjects.GetPlayers

MainGuiObjects.GetPlayersContent.Name = "StatesListFrame"
MainGuiObjects.GetPlayersContent.Parent = MainGuiObjects.GetPlayers
MainGuiObjects.GetPlayersContent.Active = true
MainGuiObjects.GetPlayersContent.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.GetPlayersContent.BorderSizePixel = 0
MainGuiObjects.GetPlayersContent.Position = UDim2.new(0.0495867766, 0, 0.112239599, 0)
MainGuiObjects.GetPlayersContent.Size = UDim2.new(0, 218, 0, 286)
MainGuiObjects.GetPlayersContent.ScrollBarThickness = 1

MainGuiObjects.TextButton.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton.BorderSizePixel = 0
MainGuiObjects.TextButton.Position = UDim2.new(0.0495867766, 0, 0.132604286, 0)
MainGuiObjects.TextButton.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton.Font = Enum.Font.Code
MainGuiObjects.TextButton.Text = "Armor Spammers"
MainGuiObjects.TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton.TextSize = 14.000

MainGuiObjects.UICorner_4.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_4.Parent = MainGuiObjects.TextButton

MainGuiObjects.TextButton_2.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_2.BorderSizePixel = 0
MainGuiObjects.TextButton_2.Position = UDim2.new(0.0495867766, 0, 0.207450449, 0)
MainGuiObjects.TextButton_2.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_2.Font = Enum.Font.Code
MainGuiObjects.TextButton_2.Text = "Admins"
MainGuiObjects.TextButton_2.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_2.TextSize = 14.000

MainGuiObjects.UICorner_5.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_5.Parent = MainGuiObjects.TextButton_2

MainGuiObjects.TextButton_3.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_3.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_3.BorderSizePixel = 0
MainGuiObjects.TextButton_3.Position = UDim2.new(0.0495867766, 0, 0.287764877, 0)
MainGuiObjects.TextButton_3.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_3.Font = Enum.Font.Code
MainGuiObjects.TextButton_3.Text = "Invisible"
MainGuiObjects.TextButton_3.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_3.TextSize = 14.000

MainGuiObjects.UICorner_6.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_6.Parent = MainGuiObjects.TextButton_3

MainGuiObjects.TextButton_4.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_4.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_4.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_4.BorderSizePixel = 0
MainGuiObjects.TextButton_4.Position = UDim2.new(0.0495867766, 0, 0.366712272, 0)
MainGuiObjects.TextButton_4.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_4.Font = Enum.Font.Code
MainGuiObjects.TextButton_4.Text = "Kill Auras"
MainGuiObjects.TextButton_4.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_4.TextSize = 14.000

MainGuiObjects.UICorner_7.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_7.Parent = MainGuiObjects.TextButton_4

MainGuiObjects.TextButton_5.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_5.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_5.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_5.BorderSizePixel = 0
MainGuiObjects.TextButton_5.Position = UDim2.new(0.0495867766, 0, 0.450444341, 0)
MainGuiObjects.TextButton_5.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_5.Font = Enum.Font.Code
MainGuiObjects.TextButton_5.Text = "Tase Auras"
MainGuiObjects.TextButton_5.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_5.TextSize = 14.000

MainGuiObjects.UICorner_8.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_8.Parent = MainGuiObjects.TextButton_5

MainGuiObjects.TextButton_6.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_6.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_6.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_6.BorderSizePixel = 0
MainGuiObjects.TextButton_6.Position = UDim2.new(0.0495867766, 0, 0.627477825, 0)
MainGuiObjects.TextButton_6.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_6.Font = Enum.Font.Code
MainGuiObjects.TextButton_6.Text = "Loop Killing"
MainGuiObjects.TextButton_6.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_6.TextSize = 14.000

MainGuiObjects.UICorner_9.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_9.Parent = MainGuiObjects.TextButton_6

MainGuiObjects.TextButton_7.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_7.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_7.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_7.BorderSizePixel = 0
MainGuiObjects.TextButton_7.Position = UDim2.new(0.0495867766, 0, 0.739917994, 0)
MainGuiObjects.TextButton_7.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_7.Font = Enum.Font.Code
MainGuiObjects.TextButton_7.Text = "Loop Tasing"
MainGuiObjects.TextButton_7.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_7.TextSize = 14.000

MainGuiObjects.UICorner_10.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_10.Parent = MainGuiObjects.TextButton_7

MainGuiObjects.TextButton_8.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_8.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_8.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_8.BorderSizePixel = 0
MainGuiObjects.TextButton_8.Position = UDim2.new(0.0495867766, 0, 0.835611761, 0)
MainGuiObjects.TextButton_8.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_8.Font = Enum.Font.Code
MainGuiObjects.TextButton_8.Text = "Infected"
MainGuiObjects.TextButton_8.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_8.TextSize = 14.000

MainGuiObjects.UICorner_11.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_11.Parent = MainGuiObjects.TextButton_8

MainGuiObjects.UIListLayout_2.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout_2.Padding = UDim.new(0, 5)

MainGuiObjects.TextButton_9.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.TextButton_9.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TextButton_9.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TextButton_9.BorderSizePixel = 0
MainGuiObjects.TextButton_9.Position = UDim2.new(0.0495867766, 0, 0.835611761, 0)
MainGuiObjects.TextButton_9.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.TextButton_9.Font = Enum.Font.Code
MainGuiObjects.TextButton_9.Text = "Protected"
MainGuiObjects.TextButton_9.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextButton_9.TextSize = 14.000

--last minute psuedo code :(
MainGuiObjects.GetFlingers = Instance.new("TextButton")
MainGuiObjects.GetFlingers.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.GetFlingers.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.GetFlingers.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.GetFlingers.BorderSizePixel = 0
MainGuiObjects.GetFlingers.Position = UDim2.new(0.0495867766, 0, 0.835611761, 0)
MainGuiObjects.GetFlingers.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.GetFlingers.Font = Enum.Font.Code
MainGuiObjects.GetFlingers.Text = "Invisible Flingers"
MainGuiObjects.GetFlingers.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.GetFlingers.TextSize = 14.000

MainGuiObjects.GFRound = Instance.new("UICorner")
MainGuiObjects.GFRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.GFRound.Parent = MainGuiObjects.GetFlingers

MainGuiObjects.GetAntiShoots = Instance.new("TextButton")
MainGuiObjects.GetAntiShoots.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.GetAntiShoots.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.GetAntiShoots.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.GetAntiShoots.BorderSizePixel = 0
MainGuiObjects.GetAntiShoots.Position = UDim2.new(0.0495867766, 0, 0.835611761, 0)
MainGuiObjects.GetAntiShoots.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.GetAntiShoots.Font = Enum.Font.Code
MainGuiObjects.GetAntiShoots.Text = "Shoot Back"
MainGuiObjects.GetAntiShoots.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.GetAntiShoots.TextSize = 14.000

MainGuiObjects.GSRound = Instance.new("UICorner")
MainGuiObjects.GSRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.GSRound.Parent = MainGuiObjects.GetAntiShoots

MainGuiObjects.GetTaseBack = Instance.new("TextButton")
MainGuiObjects.GetTaseBack.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.GetTaseBack.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.GetTaseBack.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.GetTaseBack.BorderSizePixel = 0
MainGuiObjects.GetTaseBack.Position = UDim2.new(0.0495867766, 0, 0.835611761, 0)
MainGuiObjects.GetTaseBack.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.GetTaseBack.Font = Enum.Font.Code
MainGuiObjects.GetTaseBack.Text = "Tase Back"
MainGuiObjects.GetTaseBack.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.GetTaseBack.TextSize = 14.000

MainGuiObjects.TBRound = Instance.new("UICorner")
MainGuiObjects.TBRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TBRound.Parent = MainGuiObjects.GetTaseBack

MainGuiObjects.GetClickTeleports = Instance.new("TextButton")
MainGuiObjects.GetClickTeleports.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.GetClickTeleports.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.GetClickTeleports.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.GetClickTeleports.BorderSizePixel = 0
MainGuiObjects.GetClickTeleports.Position = UDim2.new(0.0495867766, 0, 0.835611761, 0)
MainGuiObjects.GetClickTeleports.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.GetClickTeleports.Font = Enum.Font.Code
MainGuiObjects.GetClickTeleports.Text = "Click Teleport"
MainGuiObjects.GetClickTeleports.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.GetClickTeleports.TextSize = 14.000

MainGuiObjects.GCTPRound = Instance.new("UICorner")
MainGuiObjects.GCTPRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.GCTPRound.Parent = MainGuiObjects.GetClickTeleports

MainGuiObjects.GetOnePunchers = Instance.new("TextButton")
MainGuiObjects.GetOnePunchers.Parent = MainGuiObjects.GetPlayersContent
MainGuiObjects.GetOnePunchers.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.GetOnePunchers.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.GetOnePunchers.BorderSizePixel = 0
MainGuiObjects.GetOnePunchers.Position = UDim2.new(0.0495867766, 0, 0.835611761, 0)
MainGuiObjects.GetOnePunchers.Size = UDim2.new(0, 218, 0, 26)
MainGuiObjects.GetOnePunchers.Font = Enum.Font.Code
MainGuiObjects.GetOnePunchers.Text = "One Punch"
MainGuiObjects.GetOnePunchers.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.GetOnePunchers.TextSize = 14.000

MainGuiObjects.GOPRound = Instance.new("UICorner")
MainGuiObjects.GOPRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.GOPRound.Parent = MainGuiObjects.GetOnePunchers

MainGuiObjects.UICorner_12.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_12.Parent = MainGuiObjects.TextButton_9

MainGuiObjects.PlayerList.Name = "PlayerList"
MainGuiObjects.PlayerList.Parent = MainGuiObjects.GetPlayers
MainGuiObjects.PlayerList.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.PlayerList.BorderSizePixel = 0
MainGuiObjects.PlayerList.ClipsDescendants = true
MainGuiObjects.PlayerList.Position = UDim2.new(1.03321803, 0, -0.00102038682, 0)
MainGuiObjects.PlayerList.Size = UDim2.new(0, 186, 0, 195)
MainGuiObjects.PlayerList.Visible = false

MainGuiObjects.ListTopbar.Name = "ListTopbar"
MainGuiObjects.ListTopbar.Parent = MainGuiObjects.PlayerList
MainGuiObjects.ListTopbar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.ListTopbar.BorderSizePixel = 0
MainGuiObjects.ListTopbar.Size = UDim2.new(0, 186, 0, 31)

MainGuiObjects.ListTopbarRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.ListTopbarRound.Name = "ListTopbarRound"
MainGuiObjects.ListTopbarRound.Parent = MainGuiObjects.ListTopbar

MainGuiObjects.ListTitle.Name = "ListTitle"
MainGuiObjects.ListTitle.Parent = MainGuiObjects.ListTopbar
MainGuiObjects.ListTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.ListTitle.BackgroundTransparency = 1.000
MainGuiObjects.ListTitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.ListTitle.Size = UDim2.new(0, 186, 0, 31)
MainGuiObjects.ListTitle.Font = Enum.Font.Code
MainGuiObjects.ListTitle.Text = ""
MainGuiObjects.ListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.ListTitle.TextSize = 23.000

MainGuiObjects.PlayerListFrame.Name = "PlayerListFrame"
MainGuiObjects.PlayerListFrame.Parent = MainGuiObjects.ListTopbar
MainGuiObjects.PlayerListFrame.Active = true
MainGuiObjects.PlayerListFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.PlayerListFrame.BorderSizePixel = 0
MainGuiObjects.PlayerListFrame.Position = UDim2.new(0.049586799, 0, 1.20932424, 0)
MainGuiObjects.PlayerListFrame.Size = UDim2.new(0, 167, 0, 145)
MainGuiObjects.PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainGuiObjects.PlayerListFrame.ScrollBarThickness = 1

function ToggleGuis()
    for i, v in pairs(MainGuiObjects.WrathAdminGuiMain:GetChildren()) do
        if v.Name ~= "Commands" and v.Name ~= "Output" then
            v.Visible = not v.Visible
        end
    end
end

function ToggleCmds()
    MainGuiObjects.Commands.Visible = not MainGuiObjects.Commands.Visible
end

function ToggleOutput()
    MainGuiObjects.Output.Visible = not MainGuiObjects.Output.Visible
end

local function ShowPlayers(Name, Table)
    for i, v in pairs(MainGuiObjects.PlayerListFrame:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
    if MainGuiObjects.ListTitle.Text == Name then
        MainGuiObjects.PlayerList.Visible = not MainGuiObjects.PlayerList.Visible
    else
        MainGuiObjects.ListTitle.Text = Name
        MainGuiObjects.PlayerList.Visible = true
    end
    for i, v in next, Table do
        if Players:FindFirstChild(v.Name) then
            local TextButton_10 = Instance.new("TextButton")
            TextButton_10.Parent = MainGuiObjects.PlayerListFrame
            TextButton_10.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            TextButton_10.BorderColor3 = Color3.fromRGB(27, 42, 53)
            TextButton_10.BorderSizePixel = 0
            TextButton_10.Position = UDim2.new(0, 0, 1.10570937e-07, 0)
            TextButton_10.Size = UDim2.new(0, 167, 0, 25)
            TextButton_10.Font = Enum.Font.Code
            TextButton_10.TextScaled = true
            if v.DisplayName ~= v.Name then
                TextButton_10.Text = v.Name .. " (" .. v.DisplayName .. ")"
            else
                TextButton_10.Text = v.Name
            end
            TextButton_10.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextButton_10.TextSize = 14.000
            TextButton_10.MouseButton1Click:Connect(
                function()
                    if CurrentlyViewing and CurrentlyViewing.Player then
                        if CurrentlyViewing.Player.Name == v.Name then
                            UseCommand(Settings.Prefix .. "unview")
                        else
                            UseCommand(Settings.Prefix .. "view " .. v.Name)
                        end
                    else
                        UseCommand(Settings.Prefix .. "view " .. v.Name)
                    end
                end
            )
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 5)
            Corner.Parent = TextButton_10
            MainGuiObjects.PlayerListFrame.CanvasSize =
                UDim2.new(0, 0, 0, MainGuiObjects.UIListLayout_3.AbsoluteContentSize.Y)
            task.wait(0.03)
        end
    end
end

MainGuiObjects.TextButton.MouseButton1Click:Connect(
    function()
        local Spammers = {}
        for i, v in pairs(ArmorSpamFlags) do
            if v > 50 then
                local Player = Players:FindFirstChild(i)
                if Player then
                    Spammers[#Spammers + 1] = Player
                end
            end
        end
        ShowPlayers("Armor Spammers", Spammers)
    end
)

MainGuiObjects.TextButton_2.MouseButton1Click:Connect(
    function()
        ShowPlayers("Admins", Admins)
    end
)

MainGuiObjects.TextButton_3.MouseButton1Click:Connect(
    function()
        local Invis = {}
        for _, CHAR in pairs(workspace:GetChildren()) do
            local Player = Players:FindFirstChild(CHAR.Name)
            if Player then
                local Head = CHAR:FindFirstChild("Head")
                if Head then
                    if Head.Position.Y > 5000 or Head.Position.X > 99999 then
                        table.insert(Invis, Player)
                    end
                end
            end
        end
        ShowPlayers("Invisible", Invis)
    end
)

MainGuiObjects.TextButton_4.MouseButton1Click:Connect(
    function()
        ShowPlayers("Kill Auras", KillAuras)
    end
)

MainGuiObjects.TextButton_5.MouseButton1Click:Connect(
    function()
        ShowPlayers("Tase Auras", TaseAuras)
    end
)

MainGuiObjects.TextButton_6.MouseButton1Click:Connect(
    function()
        ShowPlayers("Loop Killing", Loopkilling)
    end
)

MainGuiObjects.TextButton_7.MouseButton1Click:Connect(
    function()
        ShowPlayers("Loop Tasing", LoopTasing)
    end
)

MainGuiObjects.TextButton_8.MouseButton1Click:Connect(
    function()
        ShowPlayers("Infected", Infected)
    end
)

MainGuiObjects.TextButton_9.MouseButton1Click:Connect(
    function()
        ShowPlayers("Protected", Protected)
    end
)

MainGuiObjects.GetFlingers.MouseButton1Click:Connect(
    function()
        local Flingers = {}
        local ValidParts = {}
        for _, CHAR in pairs(workspace:GetChildren()) do
            if Players:FindFirstChild(CHAR.Name) then
                for _, object in pairs(CHAR:GetChildren()) do
                    ValidParts[object.Name] = object
                end
                if not ValidParts["Torso"] and not ValidParts["Head"] then
                    local Player = Players:FindFirstChild(CHAR.Name)
                    if Player then
                        table.insert(Flingers, Player)
                    end
                end
                ValidParts = {}
            end
        end

        ShowPlayers("Invis Flingers", Flingers)
    end
)

MainGuiObjects.GetOnePunchers.MouseButton1Click:Connect(
    function()
        ShowPlayers("One Punch", Onepunch)
    end
)

MainGuiObjects.GetAntiShoots.MouseButton1Click:Connect(
    function()
        ShowPlayers("Shoot Back", AntiShoots)
    end
)

MainGuiObjects.GetClickTeleports.MouseButton1Click:Connect(
    function()
        ShowPlayers("Click Teleport", ClickTeleports)
    end
)
MainGuiObjects.GetTaseBack.MouseButton1Click:Connect(
    function()
        ShowPlayers("Tase Back", TaseBacks)
    end
)

MainGuiObjects.UIListLayout_3.Parent = MainGuiObjects.PlayerListFrame
MainGuiObjects.UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
MainGuiObjects.UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout_3.Padding = UDim.new(0, 5)

MainGuiObjects.UICorner_13.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_13.Parent = MainGuiObjects.TextButton_10

MainGuiObjects.PlayerListRound_3.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound_3.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound_3.Parent = MainGuiObjects.PlayerList

MainGuiObjects.Toggles.Name = "Toggles"
MainGuiObjects.Toggles.Parent = MainGuiObjects.WrathAdminGuiMain
MainGuiObjects.Toggles.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.Toggles.BorderSizePixel = 0
MainGuiObjects.Toggles.Position = UDim2.new(0.727664113, -605, 0.0156493802, 479)
MainGuiObjects.Toggles.Size = UDim2.new(0, 242, 0, 237)
makeDraggable(MainGuiObjects.Toggles)

MainGuiObjects.TogglesTopbar.Name = "TogglesTopbar"
MainGuiObjects.TogglesTopbar.Parent = MainGuiObjects.Toggles
MainGuiObjects.TogglesTopbar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TogglesTopbar.BorderSizePixel = 0
MainGuiObjects.TogglesTopbar.Size = UDim2.new(0, 242, 0, 31)

MainGuiObjects.TemplateTopbarRound_3.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TemplateTopbarRound_3.Name = "TemplateTopbarRound"
MainGuiObjects.TemplateTopbarRound_3.Parent = MainGuiObjects.TogglesTopbar

MainGuiObjects.TogglesTitle.Name = "TogglesTitle"
MainGuiObjects.TogglesTitle.Parent = MainGuiObjects.TogglesTopbar
MainGuiObjects.TogglesTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle.BackgroundTransparency = 1.000
MainGuiObjects.TogglesTitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TogglesTitle.Size = UDim2.new(0, 242, 0, 31)
MainGuiObjects.TogglesTitle.Font = Enum.Font.Code
MainGuiObjects.TogglesTitle.Text = "Toggles"
MainGuiObjects.TogglesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle.TextSize = 31.000

MainGuiObjects.PlayerListRound_4.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound_4.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound_4.Parent = MainGuiObjects.Toggles

MainGuiObjects.TogglesListFrame.Name = "TogglesListFrame"
MainGuiObjects.TogglesListFrame.Parent = MainGuiObjects.Toggles
MainGuiObjects.TogglesListFrame.Active = true
MainGuiObjects.TogglesListFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.TogglesListFrame.BorderSizePixel = 0
MainGuiObjects.TogglesListFrame.Position = UDim2.new(0.0371900834, 0, 0.160976171, 0)
MainGuiObjects.TogglesListFrame.Size = UDim2.new(0, 225, 0, 192)
MainGuiObjects.TogglesListFrame.ScrollBarThickness = 1

MainGuiObjects.UIListLayout_4.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout_4.Padding = UDim.new(0, 5)

MainGuiObjects.Toggle.Name = "Toggle"
MainGuiObjects.Toggle.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.Toggle.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle.BorderSizePixel = 0
MainGuiObjects.Toggle.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle.Font = Enum.Font.Code
MainGuiObjects.Toggle.Text = " Anti-Crash"
MainGuiObjects.Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle.TextSize = 14.000
MainGuiObjects.Toggle.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "acrash")
        ChangeGuiToggle(States.AntiCrash, "Anti-Crash")
        if States.AntiCrash then
            ChangeGuiToggle(false, "Shoot Back")
            ChangeGuiToggle(false, "Tase Back")
        end
    end
)

MainGuiObjects.UICorner_14.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_14.Parent = MainGuiObjects.Toggle

MainGuiObjects.TextLabel_4.Parent = MainGuiObjects.Toggle
MainGuiObjects.TextLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_4.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_4.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_4.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_4.Font = Enum.Font.Code
MainGuiObjects.TextLabel_4.Text = "true"
MainGuiObjects.TextLabel_4.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_4.TextSize = 14.000

MainGuiObjects.Toggle_2.Name = "Toggle"
MainGuiObjects.Toggle_2.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.Toggle_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_2.BorderSizePixel = 0
MainGuiObjects.Toggle_2.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_2.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_2.Font = Enum.Font.Code
MainGuiObjects.Toggle_2.Text = " Anti-Bring"
MainGuiObjects.Toggle_2.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_2.TextSize = 14.000
MainGuiObjects.Toggle_2.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_2.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "ab")
        ChangeGuiToggle(States.AntiBring, "Anti-Bring")
    end
)

MainGuiObjects.UICorner_15.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_15.Parent = MainGuiObjects.Toggle_2

MainGuiObjects.TextLabel_5.Parent = MainGuiObjects.Toggle_2
MainGuiObjects.TextLabel_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_5.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_5.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_5.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_5.Font = Enum.Font.Code
MainGuiObjects.TextLabel_5.Text = "false"
MainGuiObjects.TextLabel_5.TextColor3 = Color3.fromRGB(255, 0, 0)
MainGuiObjects.TextLabel_5.TextSize = 14.000

MainGuiObjects.Toggle_3.Name = "Toggle"
MainGuiObjects.Toggle_3.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.Toggle_3.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_3.BorderSizePixel = 0
MainGuiObjects.Toggle_3.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_3.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_3.Font = Enum.Font.Code
MainGuiObjects.Toggle_3.Text = " Shoot Back"
MainGuiObjects.Toggle_3.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_3.TextSize = 14.000
MainGuiObjects.Toggle_3.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_3.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "sb")
        ChangeGuiToggle(States.ShootBack, "Shoot Back")
    end
)

MainGuiObjects.TextLabel_6.Parent = MainGuiObjects.Toggle_3
MainGuiObjects.TextLabel_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_6.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_6.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_6.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_6.Font = Enum.Font.Code
MainGuiObjects.TextLabel_6.Text = "false"
MainGuiObjects.TextLabel_6.TextColor3 = Color3.fromRGB(255, 0, 0)
MainGuiObjects.TextLabel_6.TextSize = 14.000

MainGuiObjects.UICorner_16.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_16.Parent = MainGuiObjects.Toggle_3

MainGuiObjects.TaseBackToggle = Instance.new("TextButton")
MainGuiObjects.TaseBackToggle.Name = "Toggle"
MainGuiObjects.TaseBackToggle.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.TaseBackToggle.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TaseBackToggle.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TaseBackToggle.BorderSizePixel = 0
MainGuiObjects.TaseBackToggle.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.TaseBackToggle.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.TaseBackToggle.Font = Enum.Font.Code
MainGuiObjects.TaseBackToggle.Text = " Tase Back"
MainGuiObjects.TaseBackToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TaseBackToggle.TextSize = 14.000
MainGuiObjects.TaseBackToggle.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.TaseBackToggle.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "tb")
        ChangeGuiToggle(States.TaseBack, "Tase Back")
    end
)

MainGuiObjects.UICorner_16.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_16.Parent = MainGuiObjects.TaseBackToggle

MainGuiObjects.TBTextToggle = Instance.new("TextLabel")
MainGuiObjects.TBTextToggle.Parent = MainGuiObjects.TaseBackToggle
MainGuiObjects.TBTextToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TBTextToggle.BackgroundTransparency = 1.000
MainGuiObjects.TBTextToggle.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TBTextToggle.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TBTextToggle.Font = Enum.Font.Code
MainGuiObjects.TBTextToggle.Text = "false"
MainGuiObjects.TBTextToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainGuiObjects.TBTextToggle.TextSize = 14.000

MainGuiObjects.Toggle_4.Name = "Toggle"
MainGuiObjects.Toggle_4.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.Toggle_4.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_4.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_4.BorderSizePixel = 0
MainGuiObjects.Toggle_4.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_4.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_4.Font = Enum.Font.Code
MainGuiObjects.Toggle_4.Text = " Anti-Fling"
MainGuiObjects.Toggle_4.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_4.TextSize = 14.000
MainGuiObjects.Toggle_4.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_4.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "afling")
        ChangeGuiToggle(States.AntiFling, "Anti-Fling")
    end
)

MainGuiObjects.UICorner_17.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_17.Parent = MainGuiObjects.Toggle_4

MainGuiObjects.TextLabel_7.Parent = MainGuiObjects.Toggle_4
MainGuiObjects.TextLabel_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_7.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_7.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_7.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_7.Font = Enum.Font.Code
MainGuiObjects.TextLabel_7.Text = "false"
MainGuiObjects.TextLabel_7.TextColor3 = Color3.fromRGB(255, 0, 0)
MainGuiObjects.TextLabel_7.TextSize = 14.000

MainGuiObjects.Toggle_5.Name = "Toggle"
MainGuiObjects.Toggle_5.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.Toggle_5.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_5.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_5.BorderSizePixel = 0
MainGuiObjects.Toggle_5.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_5.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_5.Font = Enum.Font.Code
MainGuiObjects.Toggle_5.Text = " Anti-Punch"
MainGuiObjects.Toggle_5.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_5.TextSize = 14.000
MainGuiObjects.Toggle_5.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_5.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "ap")
        ChangeGuiToggle(States.AntiPunch, "Anti-Punch")
    end
)

MainGuiObjects.UICorner_18.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_18.Parent = MainGuiObjects.Toggle_5

MainGuiObjects.TextLabel_8.Parent = MainGuiObjects.Toggle_5
MainGuiObjects.TextLabel_8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_8.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_8.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_8.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_8.Font = Enum.Font.Code
MainGuiObjects.TextLabel_8.Text = "false"
MainGuiObjects.TextLabel_8.TextColor3 = Color3.fromRGB(255, 0, 0)
MainGuiObjects.TextLabel_8.TextSize = 14.000

MainGuiObjects.Toggle_6.Name = "Toggle"
MainGuiObjects.Toggle_6.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.Toggle_6.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_6.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_6.BorderSizePixel = 0
MainGuiObjects.Toggle_6.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_6.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_6.Font = Enum.Font.Code
MainGuiObjects.Toggle_6.Text = " Anti-Criminal"
MainGuiObjects.Toggle_6.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_6.TextSize = 14.000
MainGuiObjects.Toggle_6.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_6.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "ac")
        ChangeGuiToggle(States.AntiCriminal, "Anti-Criminal")
    end
)

-- last minute too
MainGuiObjects.AutoRespawn = Instance.new("TextButton")
MainGuiObjects.AutoRespawn.Name = "Toggle"
MainGuiObjects.AutoRespawn.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.AutoRespawn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.AutoRespawn.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.AutoRespawn.BorderSizePixel = 0
MainGuiObjects.AutoRespawn.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.AutoRespawn.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.AutoRespawn.Font = Enum.Font.Code
MainGuiObjects.AutoRespawn.Text = " Auto-Respawn"
MainGuiObjects.AutoRespawn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.AutoRespawn.TextSize = 14.000
MainGuiObjects.AutoRespawn.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.AutoRespawn.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "auto")
        ChangeGuiToggle(States.AutoRespawn, "Auto-Respawn")
    end
)

MainGuiObjects.AutoRespawnToggle = Instance.new("TextLabel")
MainGuiObjects.AutoRespawnToggle.Parent = MainGuiObjects.AutoRespawn
MainGuiObjects.AutoRespawnToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.AutoRespawnToggle.BackgroundTransparency = 1.000
MainGuiObjects.AutoRespawnToggle.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.AutoRespawnToggle.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.AutoRespawnToggle.Font = Enum.Font.Code
MainGuiObjects.AutoRespawnToggle.Text = "false"
MainGuiObjects.AutoRespawnToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
MainGuiObjects.AutoRespawnToggle.TextSize = 14.000

MainGuiObjects.ARRound = Instance.new("UICorner")
MainGuiObjects.ARRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.ARRound.Parent = MainGuiObjects.AutoRespawn

MainGuiObjects.AutoTeamChange = Instance.new("TextButton")
MainGuiObjects.AutoTeamChange.Name = "Toggle"
MainGuiObjects.AutoTeamChange.Parent = MainGuiObjects.TogglesListFrame
MainGuiObjects.AutoTeamChange.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.AutoTeamChange.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.AutoTeamChange.BorderSizePixel = 0
MainGuiObjects.AutoTeamChange.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.AutoTeamChange.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.AutoTeamChange.Font = Enum.Font.Code
MainGuiObjects.AutoTeamChange.Text = " Auto Team Change"
MainGuiObjects.AutoTeamChange.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.AutoTeamChange.TextSize = 14.000
MainGuiObjects.AutoTeamChange.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.AutoTeamChange.MouseButton1Click:Connect(
    function()
        UseCommand(Settings.Prefix .. "atc")
        ChangeGuiToggle(States.AutoTeamChange, "Auto Team Change")
    end
)

MainGuiObjects.ATCToggle = Instance.new("TextLabel")
MainGuiObjects.ATCToggle.Parent = MainGuiObjects.AutoTeamChange
MainGuiObjects.ATCToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.ATCToggle.BackgroundTransparency = 1.000
MainGuiObjects.ATCToggle.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.ATCToggle.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.ATCToggle.Font = Enum.Font.Code
MainGuiObjects.ATCToggle.Text = "true"
MainGuiObjects.ATCToggle.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.ATCToggle.TextSize = 14.000

MainGuiObjects.ATCRound = Instance.new("UICorner")
MainGuiObjects.ATCRound.CornerRadius = UDim.new(0, 5)
MainGuiObjects.ATCRound.Parent = MainGuiObjects.AutoTeamChange

function ChangeGuiToggle(State, Name)
    for i, v in pairs(MainGuiObjects.TogglesListFrame:GetChildren()) do
        if v:IsA("TextButton") then
            if v.Text == " " .. Name then
                if State then
                    v:FindFirstChildWhichIsA("TextLabel").Text = "true"
                    v:FindFirstChildWhichIsA("TextLabel").TextColor3 = Color3.fromRGB(85, 255, 0)
                else
                    v:FindFirstChildWhichIsA("TextLabel").Text = "false"
                    v:FindFirstChildWhichIsA("TextLabel").TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end

function ChangeImmunityToggle(State, Name)
    for i, v in pairs(MainGuiObjects.ImmunityListFrame:GetChildren()) do
        if v:IsA("TextButton") then
            if v.Text == " " .. Name then
                if State then
                    v:FindFirstChildWhichIsA("TextLabel").Text = "true"
                    v:FindFirstChildWhichIsA("TextLabel").TextColor3 = Color3.fromRGB(85, 255, 0)
                else
                    v:FindFirstChildWhichIsA("TextLabel").Text = "false"
                    v:FindFirstChildWhichIsA("TextLabel").TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end

MainGuiObjects.UICorner_19.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_19.Parent = MainGuiObjects.Toggle_6

MainGuiObjects.TextLabel_9.Parent = MainGuiObjects.Toggle_6
MainGuiObjects.TextLabel_9.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_9.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_9.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_9.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_9.Font = Enum.Font.Code
MainGuiObjects.TextLabel_9.Text = "false"
MainGuiObjects.TextLabel_9.TextColor3 = Color3.fromRGB(255, 0, 0)
MainGuiObjects.TextLabel_9.TextSize = 14.000

MainGuiObjects.ImmunitySettings.Name = "ImmunitySettings"
MainGuiObjects.ImmunitySettings.Parent = MainGuiObjects.WrathAdminGuiMain
MainGuiObjects.ImmunitySettings.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.ImmunitySettings.BorderSizePixel = 0
MainGuiObjects.ImmunitySettings.Position = UDim2.new(0.727664113, -354, 0.402190834, -235)
MainGuiObjects.ImmunitySettings.Size = UDim2.new(0, 242, 0, 241)
makeDraggable(MainGuiObjects.ImmunitySettings)

MainGuiObjects.ImmunityTopbar.Name = "ImmunityTopbar"
MainGuiObjects.ImmunityTopbar.Parent = MainGuiObjects.ImmunitySettings
MainGuiObjects.ImmunityTopbar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.ImmunityTopbar.BorderSizePixel = 0
MainGuiObjects.ImmunityTopbar.Size = UDim2.new(0, 242, 0, 31)

MainGuiObjects.TemplateTopbarRound_4.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TemplateTopbarRound_4.Name = "TemplateTopbarRound"
MainGuiObjects.TemplateTopbarRound_4.Parent = MainGuiObjects.ImmunityTopbar

MainGuiObjects.TogglesTitle_2.Name = "TogglesTitle"
MainGuiObjects.TogglesTitle_2.Parent = MainGuiObjects.ImmunityTopbar
MainGuiObjects.TogglesTitle_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle_2.BackgroundTransparency = 1.000
MainGuiObjects.TogglesTitle_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TogglesTitle_2.Size = UDim2.new(0, 242, 0, 31)
MainGuiObjects.TogglesTitle_2.Font = Enum.Font.Code
MainGuiObjects.TogglesTitle_2.Text = "Immunity Settings"
MainGuiObjects.TogglesTitle_2.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle_2.TextSize = 24.000

MainGuiObjects.PlayerListRound_5.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound_5.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound_5.Parent = MainGuiObjects.ImmunitySettings

MainGuiObjects.ImmunityListFrame.Name = "ImmunityListFrame"
MainGuiObjects.ImmunityListFrame.Parent = MainGuiObjects.ImmunitySettings
MainGuiObjects.ImmunityListFrame.Active = true
MainGuiObjects.ImmunityListFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.ImmunityListFrame.BorderSizePixel = 0
MainGuiObjects.ImmunityListFrame.Position = UDim2.new(0.0371900834, 0, 0.164775416, 0)
MainGuiObjects.ImmunityListFrame.Size = UDim2.new(0, 225, 0, 192)
MainGuiObjects.ImmunityListFrame.ScrollBarThickness = 1

MainGuiObjects.UIListLayout_5.Parent = MainGuiObjects.ImmunityListFrame
MainGuiObjects.UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout_5.Padding = UDim.new(0, 5)

MainGuiObjects.Toggle_7.Name = "Toggle"
MainGuiObjects.Toggle_7.Parent = MainGuiObjects.ImmunityListFrame
MainGuiObjects.Toggle_7.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_7.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_7.BorderSizePixel = 0
MainGuiObjects.Toggle_7.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_7.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_7.Font = Enum.Font.Code
MainGuiObjects.Toggle_7.Text = " Kill Commands"
MainGuiObjects.Toggle_7.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_7.TextSize = 14.000
MainGuiObjects.Toggle_7.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_7.MouseButton1Click:Connect(
    function()
        ProtectedSettings.killcmds = not ProtectedSettings.killcmds
        ChangeImmunityToggle(ProtectedSettings.killcmds, "Kill Commands")
    end
)

MainGuiObjects.UICorner_20.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_20.Parent = MainGuiObjects.Toggle_7

MainGuiObjects.TextLabel_10.Parent = MainGuiObjects.Toggle_7
MainGuiObjects.TextLabel_10.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_10.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_10.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_10.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_10.Font = Enum.Font.Code
MainGuiObjects.TextLabel_10.Text = "true"
MainGuiObjects.TextLabel_10.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_10.TextSize = 14.000

MainGuiObjects.Toggle_8.Name = "Toggle"
MainGuiObjects.Toggle_8.Parent = MainGuiObjects.ImmunityListFrame
MainGuiObjects.Toggle_8.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_8.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_8.BorderSizePixel = 0
MainGuiObjects.Toggle_8.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_8.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_8.Font = Enum.Font.Code
MainGuiObjects.Toggle_8.Text = " Teleport Commands"
MainGuiObjects.Toggle_8.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_8.TextSize = 14.000
MainGuiObjects.Toggle_8.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_8.MouseButton1Click:Connect(
    function()
        ProtectedSettings.tpcmds = not ProtectedSettings.tpcmds
        ChangeImmunityToggle(ProtectedSettings.tpcmds, "Teleport Commands")
    end
)

MainGuiObjects.UICorner_21.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_21.Parent = MainGuiObjects.Toggle_8

MainGuiObjects.TextLabel_11.Parent = MainGuiObjects.Toggle_8
MainGuiObjects.TextLabel_11.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_11.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_11.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_11.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_11.Font = Enum.Font.Code
MainGuiObjects.TextLabel_11.Text = "true"
MainGuiObjects.TextLabel_11.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_11.TextSize = 14.000

MainGuiObjects.Toggle_9.Name = "Toggle"
MainGuiObjects.Toggle_9.Parent = MainGuiObjects.ImmunityListFrame
MainGuiObjects.Toggle_9.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_9.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_9.BorderSizePixel = 0
MainGuiObjects.Toggle_9.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_9.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_9.Font = Enum.Font.Code
MainGuiObjects.Toggle_9.Text = " Arrest Commands"
MainGuiObjects.Toggle_9.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_9.TextSize = 14.000
MainGuiObjects.Toggle_9.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_9.MouseButton1Click:Connect(
    function()
        ProtectedSettings.arrestcmds = not ProtectedSettings.arrestcmds
        ChangeImmunityToggle(ProtectedSettings.arrestcmds, "Arrest Commands")
    end
)

MainGuiObjects.UICorner_22.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_22.Parent = MainGuiObjects.Toggle_9

MainGuiObjects.TextLabel_12.Parent = MainGuiObjects.Toggle_9
MainGuiObjects.TextLabel_12.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_12.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_12.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_12.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_12.Font = Enum.Font.Code
MainGuiObjects.TextLabel_12.Text = "true"
MainGuiObjects.TextLabel_12.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_12.TextSize = 14.000

MainGuiObjects.Toggle_10.Name = "Toggle"
MainGuiObjects.Toggle_10.Parent = MainGuiObjects.ImmunityListFrame
MainGuiObjects.Toggle_10.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_10.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_10.BorderSizePixel = 0
MainGuiObjects.Toggle_10.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_10.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_10.Font = Enum.Font.Code
MainGuiObjects.Toggle_10.Text = " Give Commands"
MainGuiObjects.Toggle_10.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_10.TextSize = 14.000
MainGuiObjects.Toggle_10.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_10.MouseButton1Click:Connect(
    function()
        ProtectedSettings.givecmds = not ProtectedSettings.givecmds
        ChangeImmunityToggle(ProtectedSettings.givecmds, "Give Commands")
    end
)

MainGuiObjects.UICorner_23.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_23.Parent = MainGuiObjects.Toggle_10

MainGuiObjects.TextLabel_13.Parent = MainGuiObjects.Toggle_10
MainGuiObjects.TextLabel_13.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_13.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_13.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_13.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_13.Font = Enum.Font.Code
MainGuiObjects.TextLabel_13.Text = "true"
MainGuiObjects.TextLabel_13.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_13.TextSize = 14.000

MainGuiObjects.Toggle_11.Name = "Toggle"
MainGuiObjects.Toggle_11.Parent = MainGuiObjects.ImmunityListFrame
MainGuiObjects.Toggle_11.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_11.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_11.BorderSizePixel = 0
MainGuiObjects.Toggle_11.Position = UDim2.new(-0.00444444455, 0, 0.00902553741, 0)
MainGuiObjects.Toggle_11.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_11.Font = Enum.Font.Code
MainGuiObjects.Toggle_11.Text = " Other Commands"
MainGuiObjects.Toggle_11.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_11.TextSize = 14.000
MainGuiObjects.Toggle_11.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_11.MouseButton1Click:Connect(
    function()
        ProtectedSettings.othercmds = not ProtectedSettings.othercmds
        ChangeImmunityToggle(ProtectedSettings.othercmds, "Other Commands")
    end
)

MainGuiObjects.UICorner_24.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_24.Parent = MainGuiObjects.Toggle_11

MainGuiObjects.TextLabel_14.Parent = MainGuiObjects.Toggle_11
MainGuiObjects.TextLabel_14.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_14.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_14.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_14.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_14.Font = Enum.Font.Code
MainGuiObjects.TextLabel_14.Text = "true"
MainGuiObjects.TextLabel_14.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_14.TextSize = 14.000

MainGuiObjects.UICorner_25.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_25.Parent = MainGuiObjects.Toggle_12

MainGuiObjects.AdminSettings.Name = "AdminSettings"
MainGuiObjects.AdminSettings.Parent = MainGuiObjects.WrathAdminGuiMain
MainGuiObjects.AdminSettings.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.AdminSettings.BorderSizePixel = 0
MainGuiObjects.AdminSettings.Position = UDim2.new(0.280947179, 81, 0.336463153, -171)
MainGuiObjects.AdminSettings.Size = UDim2.new(0, 242, 0, 201)
makeDraggable(MainGuiObjects.AdminSettings)

function ChangeAdminGuiToggle(State, Name)
    for i, v in pairs(MainGuiObjects.AdminListFrame:GetChildren()) do
        if v:IsA("TextButton") then
            if v.Text == " " .. Name then
                if State then
                    v:FindFirstChildWhichIsA("TextLabel").Text = "true"
                    v:FindFirstChildWhichIsA("TextLabel").TextColor3 = Color3.fromRGB(85, 255, 0)
                else
                    v:FindFirstChildWhichIsA("TextLabel").Text = "false"
                    v:FindFirstChildWhichIsA("TextLabel").TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end

MainGuiObjects.AdminTopbar.Name = "AdminTopbar"
MainGuiObjects.AdminTopbar.Parent = MainGuiObjects.AdminSettings
MainGuiObjects.AdminTopbar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.AdminTopbar.BorderSizePixel = 0
MainGuiObjects.AdminTopbar.Size = UDim2.new(0, 242, 0, 31)

MainGuiObjects.TemplateTopbarRound_5.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TemplateTopbarRound_5.Name = "TemplateTopbarRound"
MainGuiObjects.TemplateTopbarRound_5.Parent = MainGuiObjects.AdminTopbar

MainGuiObjects.TogglesTitle_3.Name = "TogglesTitle"
MainGuiObjects.TogglesTitle_3.Parent = MainGuiObjects.AdminTopbar
MainGuiObjects.TogglesTitle_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle_3.BackgroundTransparency = 1.000
MainGuiObjects.TogglesTitle_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TogglesTitle_3.Size = UDim2.new(0, 242, 0, 31)
MainGuiObjects.TogglesTitle_3.Font = Enum.Font.Code
MainGuiObjects.TogglesTitle_3.Text = "Admin Settings"
MainGuiObjects.TogglesTitle_3.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle_3.TextSize = 24.000

MainGuiObjects.PlayerListRound_6.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound_6.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound_6.Parent = MainGuiObjects.AdminSettings

MainGuiObjects.AdminListFrame.Name = "AdminListFrame"
MainGuiObjects.AdminListFrame.Parent = MainGuiObjects.AdminSettings
MainGuiObjects.AdminListFrame.Active = true
MainGuiObjects.AdminListFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.AdminListFrame.BorderSizePixel = 0
MainGuiObjects.AdminListFrame.Position = UDim2.new(0.0330578499, 0, 0.209551603, 0)
MainGuiObjects.AdminListFrame.Size = UDim2.new(0, 225, 0, 150)
MainGuiObjects.AdminListFrame.ScrollBarThickness = 1

MainGuiObjects.UIListLayout_6.Parent = MainGuiObjects.AdminListFrame
MainGuiObjects.UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout_6.Padding = UDim.new(0, 5)

MainGuiObjects.Toggle_13.Name = "Toggle"
MainGuiObjects.Toggle_13.Parent = MainGuiObjects.AdminListFrame
MainGuiObjects.Toggle_13.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_13.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_13.BorderSizePixel = 0
MainGuiObjects.Toggle_13.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_13.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_13.Font = Enum.Font.Code
MainGuiObjects.Toggle_13.Text = " Kill Commands"
MainGuiObjects.Toggle_13.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_13.TextSize = 14.000
MainGuiObjects.Toggle_13.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_13.MouseButton1Click:Connect(
    function()
        AdminSettings.killcmds = not AdminSettings.killcmds
        ChangeAdminGuiToggle(AdminSettings.killcmds, "Kill Commands")
    end
)

MainGuiObjects.UICorner_26.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_26.Parent = MainGuiObjects.Toggle_13

MainGuiObjects.TextLabel_16.Parent = MainGuiObjects.Toggle_13
MainGuiObjects.TextLabel_16.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_16.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_16.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_16.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_16.Font = Enum.Font.Code
MainGuiObjects.TextLabel_16.Text = "true"
MainGuiObjects.TextLabel_16.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_16.TextSize = 14.000

MainGuiObjects.Toggle_14.Name = "Toggle"
MainGuiObjects.Toggle_14.Parent = MainGuiObjects.AdminListFrame
MainGuiObjects.Toggle_14.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_14.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_14.BorderSizePixel = 0
MainGuiObjects.Toggle_14.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_14.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_14.Font = Enum.Font.Code
MainGuiObjects.Toggle_14.Text = " Teleport Commands"
MainGuiObjects.Toggle_14.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_14.TextSize = 14.000
MainGuiObjects.Toggle_14.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_14.MouseButton1Click:Connect(
    function()
        AdminSettings.tpcmds = not AdminSettings.tpcmds
        ChangeAdminGuiToggle(AdminSettings.tpcmds, "Teleport Commands")
    end
)

MainGuiObjects.UICorner_27.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_27.Parent = MainGuiObjects.Toggle_14

MainGuiObjects.TextLabel_17.Parent = MainGuiObjects.Toggle_14
MainGuiObjects.TextLabel_17.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_17.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_17.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_17.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_17.Font = Enum.Font.Code
MainGuiObjects.TextLabel_17.Text = "true"
MainGuiObjects.TextLabel_17.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_17.TextSize = 14.000

MainGuiObjects.Toggle_15.Name = "Toggle"
MainGuiObjects.Toggle_15.Parent = MainGuiObjects.AdminListFrame
MainGuiObjects.Toggle_15.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_15.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_15.BorderSizePixel = 0
MainGuiObjects.Toggle_15.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_15.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_15.Font = Enum.Font.Code
MainGuiObjects.Toggle_15.Text = " Arrest Commands"
MainGuiObjects.Toggle_15.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_15.TextSize = 14.000
MainGuiObjects.Toggle_15.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_15.MouseButton1Click:Connect(
    function()
        AdminSettings.arrestcmds = not AdminSettings.arrestcmds
        ChangeAdminGuiToggle(AdminSettings.arrestcmds, "Arrest Commands")
    end
)

MainGuiObjects.UICorner_28.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_28.Parent = MainGuiObjects.Toggle_15

MainGuiObjects.TextLabel_18.Parent = MainGuiObjects.Toggle_15
MainGuiObjects.TextLabel_18.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_18.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_18.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_18.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_18.Font = Enum.Font.Code
MainGuiObjects.TextLabel_18.Text = "true"
MainGuiObjects.TextLabel_18.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_18.TextSize = 14.000

MainGuiObjects.Toggle_16.Name = "Toggle"
MainGuiObjects.Toggle_16.Parent = MainGuiObjects.AdminListFrame
MainGuiObjects.Toggle_16.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_16.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_16.BorderSizePixel = 0
MainGuiObjects.Toggle_16.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
MainGuiObjects.Toggle_16.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_16.Font = Enum.Font.Code
MainGuiObjects.Toggle_16.Text = " Give Commands"
MainGuiObjects.Toggle_16.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_16.TextSize = 14.000
MainGuiObjects.Toggle_16.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_16.MouseButton1Click:Connect(
    function()
        AdminSettings.givecmds = not AdminSettings.givecmds
        ChangeAdminGuiToggle(AdminSettings.givecmds, "Give Commands")
    end
)

MainGuiObjects.UICorner_29.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_29.Parent = MainGuiObjects.Toggle_16

MainGuiObjects.TextLabel_19.Parent = MainGuiObjects.Toggle_16
MainGuiObjects.TextLabel_19.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TextLabel_19.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_19.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_19.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_19.Font = Enum.Font.Code
MainGuiObjects.TextLabel_19.Text = "true"
MainGuiObjects.TextLabel_19.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_19.TextSize = 14.000

MainGuiObjects.Toggle_17.Name = "Toggle"
MainGuiObjects.Toggle_17.Parent = MainGuiObjects.AdminListFrame
MainGuiObjects.Toggle_17.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.Toggle_17.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.Toggle_17.BorderSizePixel = 0
MainGuiObjects.Toggle_17.Position = UDim2.new(-0.00444444455, 0, 0.00902553741, 0)
MainGuiObjects.Toggle_17.Size = UDim2.new(0, 225, 0, 25)
MainGuiObjects.Toggle_17.Font = Enum.Font.Code
MainGuiObjects.Toggle_17.Text = " Other Commands"
MainGuiObjects.Toggle_17.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.Toggle_17.TextSize = 14.000
MainGuiObjects.Toggle_17.TextXAlignment = Enum.TextXAlignment.Left
MainGuiObjects.Toggle_17.MouseButton1Click:Connect(
    function()
        AdminSettings.othercmds = not AdminSettings.othercmds
        ChangeAdminGuiToggle(AdminSettings.othercmds, "Other Commands")
    end
)

MainGuiObjects.UICorner_30.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_30.Parent = MainGuiObjects.Toggle_17
pcall(protect_gui, WrathAdminGuiMain)
MainGuiObjects.TextLabel_20.Parent = MainGuiObjects.Toggle_17
MainGuiObjects.TextLabel_20.BackgroundColor3 = Color3.fromRGB(15, 33, 49)
MainGuiObjects.TextLabel_20.BackgroundTransparency = 1.000
MainGuiObjects.TextLabel_20.Position = UDim2.new(0.800000012, 0, 0, 0)
MainGuiObjects.TextLabel_20.Size = UDim2.new(0, 45, 0, 25)
MainGuiObjects.TextLabel_20.Font = Enum.Font.Code
MainGuiObjects.TextLabel_20.Text = "true"
MainGuiObjects.TextLabel_20.TextColor3 = Color3.fromRGB(85, 255, 0)
MainGuiObjects.TextLabel_20.TextSize = 14.000

MainGuiObjects.Commands.Name = "Commands"
MainGuiObjects.Commands.Parent = MainGuiObjects.WrathAdminGuiMain
MainGuiObjects.Commands.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.Commands.BorderSizePixel = 0
MainGuiObjects.Commands.Position = UDim2.new(0.0118406396, 0, 0.549295723, 0)
MainGuiObjects.Commands.Size = UDim2.new(0, 242, 0, 276)

makeDraggable(MainGuiObjects.Commands)

MainGuiObjects.CommandsTopbar.Name = "CommandsTopbar"
MainGuiObjects.CommandsTopbar.Parent = MainGuiObjects.Commands
MainGuiObjects.CommandsTopbar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.CommandsTopbar.BorderSizePixel = 0
MainGuiObjects.CommandsTopbar.Size = UDim2.new(0, 242, 0, 31)

MainGuiObjects.TemplateTopbarRound_6.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TemplateTopbarRound_6.Name = "TemplateTopbarRound"
MainGuiObjects.TemplateTopbarRound_6.Parent = MainGuiObjects.CommandsTopbar

MainGuiObjects.TogglesTitle_4.Name = "TogglesTitle"
MainGuiObjects.TogglesTitle_4.Parent = MainGuiObjects.CommandsTopbar
MainGuiObjects.TogglesTitle_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle_4.BackgroundTransparency = 1.000
MainGuiObjects.TogglesTitle_4.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TogglesTitle_4.Size = UDim2.new(0, 242, 0, 31)
MainGuiObjects.TogglesTitle_4.Font = Enum.Font.Code
MainGuiObjects.TogglesTitle_4.Text = "Commands"
MainGuiObjects.TogglesTitle_4.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TogglesTitle_4.TextSize = 31.000

MainGuiObjects.PlayerListRound_7.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound_7.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound_7.Parent = MainGuiObjects.Commands

MainGuiObjects.CommandsListFrame.Name = "CommandsListFrame"
MainGuiObjects.CommandsListFrame.Parent = MainGuiObjects.Commands
MainGuiObjects.CommandsListFrame.Active = true
MainGuiObjects.CommandsListFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.CommandsListFrame.BorderSizePixel = 0
MainGuiObjects.CommandsListFrame.Position = UDim2.new(0.0371900834, 0, 0.160976127, 0)
MainGuiObjects.CommandsListFrame.Size = UDim2.new(0, 225, 0, 221)
MainGuiObjects.CommandsListFrame.ScrollBarThickness = 1

function NewCommand(Text)
    local Command = Instance.new("TextButton")
    Command.Name = "Command"
    Command.Parent = MainGuiObjects.CommandsListFrame
    Command.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Command.BorderColor3 = Color3.fromRGB(27, 42, 53)
    Command.BorderSizePixel = 0
    Command.Position = UDim2.new(0, 0, 2.66529071e-07, 0)
    Command.Size = UDim2.new(0, 225, 0, 25)
    Command.Font = Enum.Font.Code
    Command.Text = Text
    Command.TextColor3 = Color3.fromRGB(255, 255, 255)
    Command.TextSize = 14.000
    Command.RichText = true
    Command.TextWrapped = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Command

    task.spawn(
        function()
            task.wait(1 / 20)
            Command.Size = UDim2.new(0, 220, 0, math.max(25, Command.TextBounds.Y))
            MainGuiObjects.CommandsListFrame.CanvasSize =
                UDim2.new(0, 0, 0, MainGuiObjects.UIListLayout_7.AbsoluteContentSize.Y)
        end
    )
end

for i, v in next, Commands do
    local Split = v:split(" -- ")
    if Split[2] then
        NewCommand(Split[1] .. "\n--\n" .. Split[2])
    else
        NewCommand(v)
    end
end

MainGuiObjects.UIListLayout_7.Parent = MainGuiObjects.CommandsListFrame
MainGuiObjects.UIListLayout_7.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout_7.Padding = UDim.new(0, 5)

MainGuiObjects.Output.Name = "Output"
MainGuiObjects.Output.Parent = MainGuiObjects.WrathAdminGuiMain
MainGuiObjects.Output.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.Output.BorderSizePixel = 0
MainGuiObjects.Output.Position = UDim2.new(0.490850389, -736, 0.0625978187, 231)
MainGuiObjects.Output.Size = UDim2.new(0, 242, 0, 164)
makeDraggable(MainGuiObjects.Output)

MainGuiObjects.TemplateTopbar_3.Name = "TemplateTopbar"
MainGuiObjects.TemplateTopbar_3.Parent = MainGuiObjects.Output
MainGuiObjects.TemplateTopbar_3.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainGuiObjects.TemplateTopbar_3.BorderSizePixel = 0
MainGuiObjects.TemplateTopbar_3.Size = UDim2.new(0, 242, 0, 31)

MainGuiObjects.TemplateTopbarRound_7.CornerRadius = UDim.new(0, 5)
MainGuiObjects.TemplateTopbarRound_7.Name = "TemplateTopbarRound"
MainGuiObjects.TemplateTopbarRound_7.Parent = MainGuiObjects.TemplateTopbar_3

MainGuiObjects.TemplateTitle_3.Name = "TemplateTitle"
MainGuiObjects.TemplateTitle_3.Parent = MainGuiObjects.TemplateTopbar_3
MainGuiObjects.TemplateTitle_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TemplateTitle_3.BackgroundTransparency = 1.000
MainGuiObjects.TemplateTitle_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainGuiObjects.TemplateTitle_3.Size = UDim2.new(0, 242, 0, 31)
MainGuiObjects.TemplateTitle_3.Font = Enum.Font.Code
MainGuiObjects.TemplateTitle_3.Text = "Output"
MainGuiObjects.TemplateTitle_3.TextColor3 = Color3.fromRGB(255, 255, 255)
MainGuiObjects.TemplateTitle_3.TextSize = 31.000

MainGuiObjects.PlayerListRound_8.CornerRadius = UDim.new(0, 5)
MainGuiObjects.PlayerListRound_8.Name = "PlayerListRound"
MainGuiObjects.PlayerListRound_8.Parent = MainGuiObjects.Output

MainGuiObjects.OutputListFrame.Name = "OutputListFrame"
MainGuiObjects.OutputListFrame.Parent = MainGuiObjects.Output
MainGuiObjects.OutputListFrame.Active = true
MainGuiObjects.OutputListFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
MainGuiObjects.OutputListFrame.BorderSizePixel = 0
MainGuiObjects.OutputListFrame.Position = UDim2.new(0.0252201017, 0, 0.248236686, 0)
MainGuiObjects.OutputListFrame.Size = UDim2.new(0, 225, 0, 114)
MainGuiObjects.OutputListFrame.ScrollBarThickness = 5

MainGuiObjects.UIListLayout_8.Parent = MainGuiObjects.OutputListFrame
MainGuiObjects.UIListLayout_8.HorizontalAlignment = Enum.HorizontalAlignment.Left
MainGuiObjects.UIListLayout_8.SortOrder = Enum.SortOrder.LayoutOrder
MainGuiObjects.UIListLayout_8.Padding = UDim.new(0, 5)

function AddLog(Type, Text)
    local Log = Instance.new("TextButton")
    Log.Name = "Log"
    Log.Parent = MainGuiObjects.OutputListFrame
    Log.BackgroundColor3 = Color3.fromRGB(52, 33, 33)
    Log.BorderColor3 = Color3.fromRGB(22, 8, 0)
    Log.BorderSizePixel = 0
    Log.AutoButtonColor = false
    Log.Font = Enum.Font.Code
    Log.Text = "[" .. Type:upper() .. "] " .. Text
    if Type:lower() == "success" then
        Log.TextColor3 = Color3.fromRGB(0, 255, 38)
    elseif Type:lower() == "error" then
        Log.TextColor3 = Color3.fromRGB(255, 51, 51)
    else
        Log.TextColor3 = Color3.fromRGB(0, 153, 43)
    end
    Log.RichText = true
    Log.TextSize = 14.000
    Log.TextWrapped = true
    Log.Size = UDim2.new(0, 225, 0, 25)
    Log.TextXAlignment = Enum.TextXAlignment.Left

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Log

    MainGuiObjects.OutputListFrame.CanvasSize = UDim2.new(0, 0, 0, MainGuiObjects.UIListLayout_8.AbsoluteContentSize.Y)
    MainGuiObjects.OutputListFrame.CanvasPosition = Vector2.new(0, MainGuiObjects.UIListLayout_8.AbsoluteContentSize.Y)
end

MainGuiObjects.UICorner_32.CornerRadius = UDim.new(0, 5)
MainGuiObjects.UICorner_32.Parent = MainGuiObjects.Log

MainGuiObjects.OutputListFrame.ChildAdded:Connect(
    function(Log)
        if Log:IsA("TextButton") then
            task.wait(1 / 20)
            Log.Size = UDim2.new(0, 220, 0, math.max(25, Log.TextBounds.Y))
            MainGuiObjects.OutputListFrame.CanvasSize =
                UDim2.new(0, 0, 0, MainGuiObjects.UIListLayout_8.AbsoluteContentSize.Y)
            MainGuiObjects.OutputListFrame.CanvasPosition =
                Vector2.new(0, MainGuiObjects.UIListLayout_8.AbsoluteContentSize.Y)
        end
    end
)

--// cmd search
TextBox.Changed:Connect(
    function(Text)
        Text = TextBox.Text
        local Found = {}
        if Text ~= "" then
            for i, v in pairs(MainGuiObjects.CommandsListFrame:GetChildren()) do
                if v:IsA("TextButton") then
                    if v.Text:find(Text) then
                        table.insert(Found, v)
                    end
                    v.Visible = false
                end
            end
            for i, v in next, Found do
                v.Visible = true
            end
            MainGuiObjects.CommandsListFrame.CanvasSize =
                UDim2.new(0, 0, 0, MainGuiObjects.UIListLayout_7.AbsoluteContentSize.Y)
        else
            for i, v in pairs(MainGuiObjects.CommandsListFrame:GetChildren()) do
                if v:IsA("TextButton") then
                    v.Visible = true
                end
            end
            MainGuiObjects.CommandsListFrame.CanvasSize =
                UDim2.new(0, 0, 0, MainGuiObjects.UIListLayout_7.AbsoluteContentSize.Y)
        end
    end
)

--// Gui toggle
UserInputService.InputBegan:Connect(
    function(INPUT)
        if INPUT.UserInputType == Enum.UserInputType.Keyboard and INPUT.KeyCode == Enum.KeyCode[Settings.ToggleGui] then
            ToggleGuis()
        end
    end
)

--// Fix scrolling frames
for i, v in next, MainGuiObjects do
    if v:IsA("ScrollingFrame") then
        local ListLayout = v:FindFirstChildWhichIsA("UIListLayout")
        if ListLayout then
            v.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
        end
    end
end

ToggleGuis()

-- lazy
ChangeGuiToggle(false, "Anti-Crash")

local executorname = identifyexecutor()

if shared.notify_of_executor == true then
Notify(executorname, "Has Been Successfully Identified")
wait(3)
else
Notify(scriptversion)
end

AddLog("Success", "Loaded Wrath Admin in " .. tostring(tick() - ExecutionTime) .. " second(s).")
wait(1)
Notify("Script Version Is", scriptversion, 5)
