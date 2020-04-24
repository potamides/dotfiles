local lgi = require "lgi"
local GLib = lgi.GLib
local Gio = lgi.Gio

local mpc = {}

local function parse_password(host)
	-- This function is based on mpd_parse_host_password() from libmpdclient
	local position = string.find(host, "@")
	if not position then
		return host
	end
	return string.sub(host, position + 1), string.sub(host, 1, position - 1)
end

function mpc.new(host, port, password, error_handler, ...)
	host = host or os.getenv("MPD_HOST") or "localhost"
	port = port or os.getenv("MPD_PORT") or 6600
	if not password then
		host, password = parse_password(host)
	end
	local self = setmetatable({
		_host = host,
		_port = port,
		_password = password,
		_error_handler = error_handler or function() end,
		_connected = false,
		_try_reconnect = false,
		_idle_commands = { ... }
	}, { __index = mpc })
	self:_connect()
	return self
end

function mpc:_error(err)
	self._connected = false
	self._error_handler(err)
	self._try_reconnect = not self._try_reconnect
	if self._try_reconnect then
		self:_connect()
	end
end

function mpc:_connect()
	if self._connected then return end
	-- Reset all of our state
	self._reply_handlers = {}
	self._pending_reply = {}
	self._idle_commands_pending = false
	self._idle = false
	self._connected = true

	-- Set up a new connection
	local address
	if string.sub(self._host, 1, 1) == "/" then
		-- It's a unix socket
		address = Gio.UnixSocketAddress.new(self._host)
	else
		-- Do a TCP connection
		address = Gio.NetworkAddress.new(self._host, self._port)
	end
	local client = Gio.SocketClient()
	local conn, err = client:connect(address)

	if not conn then
		self:_error(err)
		return false
	end

	local input, output = conn:get_input_stream(), conn:get_output_stream()
	self._conn, self._output, self._input = conn, output, Gio.DataInputStream.new(input)

	-- Read the welcome message
	self._input:read_line()

	if self._password and self._password ~= "" then
		self:_send("password " .. self._password)
	end

	-- Set up the reading loop. This will asynchronously read lines by
	-- calling itself.
	local do_read
	do_read = function()
		self._input:read_line_async(GLib.PRIORITY_DEFAULT, nil, function(obj, res)
			local line, err = obj:read_line_finish(res)
			-- Ugly API. On success we get string, length-of-string
			-- and on error we get nil, error. Other versions of lgi
			-- behave differently.
			if line == nil or tostring(line) == "" then
				err = "Connection closed"
			end
			if type(err) ~= "number" then
				self._output, self._input = nil, nil
				self:_error(err)
			else
				do_read()
				line = tostring(line)
				if line == "OK" or line:match("^ACK ") then
					local success = line == "OK"
					local arg
					if success then
						arg = self._pending_reply
					else
						arg = { line }
					end
					local handler = self._reply_handlers[1]
					table.remove(self._reply_handlers, 1)
					self._pending_reply = {}
					handler(success, arg)
				else
					local _, _, key, value = string.find(line, "([^:]+):%s(.+)")
					if key then
					    self._pending_reply[string.lower(key)] = value
					end
				end
			end
		end)
	end
	do_read()

	-- To synchronize the state on startup, send the idle commands now. As a
	-- side effect, this will enable idle state.
	self:_send_idle_commands(true)

	return self
end

function mpc:_send_idle_commands(skip_stop_idle)
	-- We use a ping to unset this to make sure we never get into a busy
	-- loop sending idle / unidle commands. Next call to
	-- _send_idle_commands() might be ignored!
	if self._idle_commands_pending then
		return
	end
	if not skip_stop_idle then
		self:_stop_idle()
	end

	self._idle_commands_pending = true
	for i = 1, #self._idle_commands, 2 do
		self:_send(self._idle_commands[i], self._idle_commands[i+1])
	end
	self:_send("ping", function()
		self._idle_commands_pending = false
	end)
	self:_start_idle()
end

function mpc:_start_idle()
	if self._idle then
		error("Still idle?!")
	end
	self:_send("idle", function(success, reply)
		if reply.changed then
			-- idle mode was disabled by mpd
			self:_send_idle_commands()
		end
	end)
	self._idle = true
end

function mpc:_stop_idle()
	if not self._idle then
		error("Not idle?!")
	end
	self._output:write("noidle\n")
	self._idle = false
end

function mpc:_send(command, callback)
	if self._idle then
		error("Still idle in send()?!")
	end
	self._output:write(command .. "\n")
	table.insert(self._reply_handlers, callback or function() end)
end

function mpc:send(...)
	self:_connect()
	if not self._connected then
		return
	end
	local args = { ... }
	if not self._idle then
		error("Something is messed up, we should be idle here...")
	end
	self:_stop_idle()
	for i = 1, #args, 2 do
		self:_send(args[i], args[i+1])
	end
	self:_start_idle()
end

function mpc:toggle_play()
	self:send("status", function(success, status)
		if status.state == "stop" then
			self:send("play")
		else
			self:send("pause")
		end
	end)
end

--[[

-- Example on how to use this (standalone)

local host, port, password = nil, nil, nil
local m = mpc.new(host, port, password, error,
	"status", function(success, status) print("status is", status.state) end)

GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, function()
	-- Test command submission
	m:send("status", function(_, s) print(s.state) end,
		"currentsong", function(_, s) print(s.title) end)
	m:send("status", function(_, s) print(s.state) end)
	-- Force a reconnect
	GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, function()
		m._conn:close()
	end)
end)

GLib.MainLoop():run()
--]]

return mpc
