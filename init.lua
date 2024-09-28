local function isChromeFrontmost()
	local app = hs.application.frontmostApplication()
	return app and app:name() == "Microsoft Edge"
end

-- 定義一個表來存儲所有快捷鍵綁定
local hotkeys = {}

-- 定義一個函數來控制 Chrome 切換標籤頁
local function jumpToTabChrome(offset)
	local script = string.format(
		[[
         tell application "Microsoft Edge"
             set windowTabs to (tabs of front window)
             set activeTabIndex to (active tab index of front window)
             set targetTabIndex to activeTabIndex + %d

             if targetTabIndex > (count of windowTabs) then
                 set targetTabIndex to (count of windowTabs)
             end if

             if targetTabIndex < 1 then
                 set targetTabIndex to 1
             end if

             set active tab index of front window to targetTabIndex
         end tell
     ]],
		offset
	)

	-- 執行 AppleScript 來控制 Chrome
	hs.osascript.applescript(script)
end

-- 綁定 Command + Shift + 1 到 Command + Shift + 5
for i = 1, 5 do
	hotkeys["prevTab" .. i] = hs.hotkey.new({ "cmd", "shift" }, tostring(i), function()
		jumpToTabChrome(-i) -- 跳轉到當前標籤頁左邊第 i 個標籤頁
	end)
end

-- 綁定 Command + 1 到 Command + 5
for i = 1, 5 do
	hotkeys["nextTab" .. i] = hs.hotkey.new({ "cmd" }, tostring(i), function()
		jumpToTabChrome(i) -- 跳轉到當前標籤頁右邊第 i 個標籤頁
	end)
end

local function jumpToTab1()
	local script = string.format([[
 tell application "Microsoft Edge"
     set activeTabIndex to 1
     set active tab index of front window to activeTabIndex
 end tell
     ]])

	-- 執行 AppleScript 來控制 Chrome
	hs.osascript.applescript(script)
end

hotkeys["jumpToTab1"] = hs.hotkey.new({ "cmd" }, "0", function()
	if isChromeFrontmost() then
		jumpToTab1()
	end
end)

-- 定義一個函數來執行 AppleScript
local function executeAppleScript(scriptPath)
	local script = string.format("osascript %s", scriptPath)
	hs.execute(script)
end

-- 設置快捷鍵 Command + Shift + C 來複製當前標籤頁的 URL
hotkeys["copyURL"] = hs.hotkey.new({ "cmd", "shift" }, "C", function()
	executeAppleScript("~/.hammerspoon/scripts/copyCurrentURL.scpt")
end)

hotkeys["prevTab"] = hs.hotkey.new({ "cmd", "alt", "shift" }, "left", function()
	hs.eventtap.keyStroke({ "ctrl", "shift" }, "pageup")
end)

hotkeys["nextTab"] = hs.hotkey.new({ "cmd", "alt", "shift" }, "right", function()
	hs.eventtap.keyStroke({ "ctrl", "shift" }, "pagedown")
end)

local function updateHotkeys(isChrome)
	if isChrome then
		-- 當前是 Chrome，啟用所有快捷鍵
		for _, hk in pairs(hotkeys) do
			hk:enable()
		end
	else
		-- 當前不是 Chrome，禁用所有快捷鍵
		for _, hk in pairs(hotkeys) do
			hk:disable()
		end
	end
end

-- 使用 hs.window.filter 來監控應用狀態
local wf = hs.window.filter.new()
wf:subscribe(hs.window.filter.windowFocused, function(window, appName)
	if appName == "Microsoft Edge" then
		updateHotkeys(true)
	else
		updateHotkeys(false)
	end
end)

-- 初始化時檢查一次
updateHotkeys(isChromeFrontmost())
