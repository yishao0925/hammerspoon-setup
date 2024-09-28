-- 獲取當前標籤頁的 URL 並複製到剪貼板
tell application "Microsoft Edge"
    set currentURL to URL of active tab of front window
end tell

-- 複製 URL 到剪貼板
set the clipboard to currentURL
