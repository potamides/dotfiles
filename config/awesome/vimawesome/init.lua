local hotkeys_popup = require("awful.hotkeys_popup")

--------------
local gears = require("gears")
local awful = require("awful")
local textbox = require("wibox.widget.textbox")

local sequence, modename, modkey, grabber, default_commands, active_commands = textbox(), textbox()


local function parse(_sequence, pattern)
    local capture = string.match(_sequence, '^' .. pattern[1])
    local sub_sequence = string.gsub(_sequence, '^' .. pattern[1], '')

    if capture then
        table.remove(pattern, 1)
        if #sub_sequence == 0 and #pattern == 0 then
            return {capture}, true, true
        elseif #sub_sequence == 0 and #pattern > 0 then
            return {capture}, true, false
        elseif #sub_sequence > 0 and #pattern > 0 then
            local captures, valid, finished = parse(sub_sequence, pattern)
            return gears.table.merge({capture}, captures), valid, finished
        end
    end
    return {}, false, false

end

local function grab(_, key, event)
        if event == 'release' then
            return
        elseif event == modkey then
            startmode(default_commands)
            return
        end
        sequence.text = sequence.text .. key

        local should_break = true
        for _, command in ipairs(active_commands) do
            for _, pattern in ipairs(command.pattern) do
                local captures, valid, finished = parse(sequence.text, gears.table.clone(pattern, false))

                if finished then
                    command.handler(table.unpack(captures))
                    sequence.text = ''
                    return
                elseif valid then
                    should_break = false
                end
            end
        end

        if should_break then
            sequence.text = ''
        end
    end

local function startmode(commands)
    return
    function()
        sequence.text = ''
        modename.text = commands.name
        active_commands = commands
        grabber = awful.keygrabber.run(grab)
    end
end

local function startinsert(_modename)
    return
        function()
            modename.text = _modename
            awful.keygrabber.stop(grabber)
        end
end

local function init(_commands, _modkey)
    default_commands = _commands
    active_commands = _commands
    modkey = _modkey
    grabber = awful.keygrabber.run(grab)
    root.keys(awful.key({}, modkey, startmode(default_commands)))
end

local launcher_commands =
    {
        name = 'launcher',
        {
            description = "show help",
            pattern = {{"h"}},
            handler =
                function(_)
                    hotkeys_popup.show_help()
                end
        }
    }

local tag_commands =
    {
        name = 'TAG',
        {
            description = "focus a client",
            pattern = {{'[hjkl]'}},
            handler =
                function(movement)
                    local directions = {h = 'left', j = 'down', k = 'up', l = 'right'}
                    awful.client.focus.bydirection(directions[movement])
                end
        },
        {
            description = "focus a tag",
            pattern = {
                        {'f', '%d*', '[hl]'},
                        {'f?', '%d*', 'g', 'g'}
                    },
            handler =
                function(_, count, ...)
                    local screen, movement, tag, index = awful.screen.focused(), table.concat({...})
                    count = count == '' and 1 or tonumber(count)

                    if movement == 'gg' then
                        index = count
                    elseif movement == 'h' then
                        index = ((screen.selected_tag.index - 1 - count) % #screen.tags) + 1
                    elseif movement == 'l' then
                        index = ((screen.selected_tag.index - 1 + count) % #screen.tags) + 1
                    end

                    tag = screen.tags[index]
                    if tag then
                        tag:view_only()
                    end
                end
        },
        {
            description = "move focused client to tag",
            pattern = {
                        {'m', '%d*', '[hl]'},
                        {'m', '%d*', 'g', 'g'},
                        },
            handler =
                function(_, count, ...)
                    local screen, movement, tag, index = awful.screen.focused(), table.concat({...})
                    count = count == '' and 1 or tonumber(count)

                    if movement == 'gg' then
                        index = count
                    elseif movement == 'h' then
                        index = ((screen.selected_tag.index - 1 - count) % #screen.tags) + 1
                    elseif movement == 'l' then
                        index = ((screen.selected_tag.index - 1 + count) % #screen.tags) + 1
                    end

                    tag = screen.tags[index]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
        },
        {
            description = "toggle tag",
            pattern = {
                        {'t', '%d*', '[hl]'},
                        {'t', '%d*', 'g', 'g'},
                        },
            handler =
                function(_, count, movement)
                    local screen, tag, index = awful.screen.focused()
                    count = count == '' and 1 or tonumber(count)

                    if movement == 'gg' then
                        index = count
                    elseif movement == 'h' then
                        index = ((screen.selected_tag.index - 1 - count) % #screen.tags) + 1
                    elseif movement == 'l' then
                        index = ((screen.selected_tag.index - 1 + count) % #screen.tags) + 1
                    end

                    tag = screen.tags[index]
                    if tag then
                        awful.tag.viewtoggle(tag)
                    end
                end
        },
        {
            description = "enter client mode",
            pattern = {{"i"}},
            handler = startinsert("CLIENT")
        },
        {
            description = "enter launcher mode",
            pattern = {{'s'}},
            handler = startmode(launcher_commands)
        }
    }

init(tag_commands, 'Super_L')


return {init = init, startmode = startmode, startinsert = startinsert, sequence = sequence, modename = modename}
