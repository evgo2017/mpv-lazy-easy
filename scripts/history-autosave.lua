-- ============================================
-- MPV 完整会话恢复脚本
-- 功能：保存和恢复播放列表、位置、暂停状态
-- 保存位置：~/.config/mpv/last_session.json
-- 快捷键：Ctrl+Shift+r 恢复
-- ============================================

local mp = require "mp"
local utils = require "mp.utils"

-- 配置文件路径
local config_dir = os.getenv("HOME") and os.getenv("HOME") .. "/.config/mpv" or 
                   os.getenv("APPDATA") and os.getenv("APPDATA") .. "/mpv" or 
                   "."

local SESSION_FILE = config_dir .. "/last_session.json"
local LOG_FILE = config_dir .. "/session_log.txt"

-- 日志函数
local function log_message(message)
    local file = io.open(LOG_FILE, "a")
    if file then
        file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. message .. "\n")
        file:close()
    end
end

-- 获取当前会话信息
local function get_current_session()
    local session = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        playlist = {},
        playlist_pos = mp.get_property_number("playlist-pos", 0),
        time_pos = mp.get_property_number("time-pos", 0),
        paused = mp.get_property("pause") == "yes",
        speed = mp.get_property_number("speed", 1.0),
        volume = mp.get_property_number("volume", 100),
        mute = mp.get_property("mute") == "yes",
        file = mp.get_property("path", ""),
        title = mp.get_property("media-title", ""),
        duration = mp.get_property_number("duration", 0)
    }
    
    -- 保存整个播放列表
    local count = mp.get_property_number("playlist-count", 0)
    for i = 0, count - 1 do
        local filename = mp.get_property("playlist/" .. i .. "/filename")
        local title = mp.get_property("playlist/" .. i .. "/title") or filename
        if filename then
            table.insert(session.playlist, {
                filename = filename,
                title = title,
                index = i
            })
        end
    end
    
    return session
end

-- 保存会话
local function save_session()
    local session = get_current_session()
    
    local file, err = io.open(SESSION_FILE, "w")
    if not file then
        mp.osd_message("❌ 无法保存会话: " .. (err or "未知错误"), 2)
        log_message("保存失败: " .. (err or "未知错误"))
        return
    end
    
    local json = require "mp.utils".format_json(session)
    file:write(json)
    file:close()
    
    local message = string.format("💾 已保存会话:\n文件: %s\n位置: %d秒\n状态: %s",
        session.title or "未命名",
        math.floor(session.time_pos),
        session.paused and "⏸️ 暂停" or "▶️ 播放")
    
    mp.osd_message(message, 3)
    log_message("会话已保存: " .. session.title)
    
    return true
end

-- 恢复会话
local function restore_session()
    local file = io.open(SESSION_FILE, "r")
    if not file then
        mp.osd_message("📭 没有找到保存的会话", 2)
        return false
    end
    
    local content = file:read("*a")
    file:close()
    
    local success, session = pcall(utils.parse_json, content)
    if not success or not session then
        mp.osd_message("❌ 会话文件损坏", 2)
        log_message("恢复失败: 会话文件损坏")
        return false
    end
    
    -- 检查会话是否有效
    if not session.playlist or #session.playlist == 0 then
        mp.osd_message("❌ 会话中无播放列表", 2)
        return false
    end
    
    -- 清空当前播放列表
    mp.command("playlist-clear")
    
    -- 恢复播放列表
    for _, item in ipairs(session.playlist) do
        if item.filename and item.filename ~= "" then
            mp.commandv("loadfile", item.filename, "append")
        end
    end
    
    -- 等待播放列表加载完成
    mp.add_timeout(0.5, function()
        -- 跳转到上次的位置
        if session.playlist_pos and session.playlist_pos >= 0 then
            mp.set_property_number("playlist-pos", session.playlist_pos)
        end
        
        -- 等待文件加载
        mp.add_timeout(0.5, function()
            -- 设置播放位置
            if session.time_pos and session.time_pos > 0 then
                mp.commandv("seek", session.time_pos, "absolute")
            end
            
            -- 设置播放状态（关键：恢复暂停状态）
            if session.paused then
                mp.set_property("pause", "yes")
                mp.osd_message("⏸️ 已恢复暂停状态", 2)
            else
                mp.set_property("pause", "no")
            end
            
            -- 恢复其他设置
            if session.speed then
                mp.set_property_number("speed", session.speed)
            end
            
            if session.volume then
                mp.set_property_number("volume", session.volume)
            end
            
            if session.mute then
                mp.set_property("mute", session.mute and "yes" or "no")
            end
            
            -- 显示恢复信息
            local total = #session.playlist
            local current = session.playlist_pos + 1
            local time_str = string.format("%02d:%02d:%02d", 
                math.floor(session.time_pos / 3600),
                math.floor((session.time_pos % 3600) / 60),
                math.floor(session.time_pos % 60))
            
            local status_msg = string.format(
                "🔄 已恢复上次会话\n"
            )
            
            mp.osd_message(status_msg, 4)
            log_message("会话已恢复: " .. session.title)
        end)
    end)
    
    return true
end

-- 打开上次播放文件所在的文件夹
local function open_last_folder()
    local file = io.open(SESSION_FILE, "r")
    if not file then
        mp.osd_message("📭 没有保存的会话", 2)
        return
    end
    
    local content = file:read("*a")
    file:close()
    
    local success, session = pcall(utils.parse_json, content)
    if not success or not session then
        mp.osd_message("❌ 会话文件损坏", 2)
        return
    end
    
    local path = session.file
    if (not path or path == "") and session.playlist and #session.playlist > 0 then
        local idx = (session.playlist_pos or 0) + 1
        if session.playlist[idx] then
            path = session.playlist[idx].filename
        end
    end
    
    if path and path ~= "" then
        mp.osd_message("📂 打开文件夹...", 2)
        
        -- Windows: explorer /select, path
        local is_windows = package.config:sub(1,1) == '\\'
        if is_windows then
            path = path:gsub("/", "\\")
            os.execute(string.format('explorer /select, "%s"', path))
        else
            -- MacOS: open -R path / Linux: xdg-open dir
            os.execute(string.format('open -R "%s"', path))
        end
    else
        mp.osd_message("❌ 未找到文件路径", 2)
    end
end

-- 自动保存会话（在退出时）
local function auto_save_session()
    local count = mp.get_property_number("playlist-count", 0)
    if count > 0 then
        save_session()
    end
end

-- 自动恢复会话（在启动时）
local function auto_restore_session()
    -- 只有直接启动 mpv 而没有文件参数时才恢复
    local args = mp.get_property_native("options/vo")
    if args == "" or args == nil then
        mp.add_timeout(1.0, function()
            restore_session()
        end)
    end
end

-- ============================================
-- 注册事件和快捷键
-- ============================================

-- 添加快捷键
mp.add_key_binding("Ctrl+Shift+r", "restore_session", restore_session)
mp.add_key_binding("Ctrl+Shift+o", "open_last_folder", open_last_folder)
mp.add_key_binding("Ctrl+Shift+d", "delete_session", function()
    os.remove(SESSION_FILE)
    mp.osd_message("🗑️ 已删除保存的会话", 2)
end)

-- 注册事件
mp.register_event("shutdown", auto_save_session)

-- 启动时自动恢复
mp.register_event("start-file", function()
    -- 延迟执行，确保其他脚本已加载
    mp.add_timeout(0.5, auto_restore_session)
end)

-- 初始化日志
log_message("=== MPV 会话管理器启动 ===")

-- 显示加载信息
mp.osd_message("🎬 会话管理器已加载\nCtrl+Shift+r: 恢复会话\nCtrl+Shift+o: 打开位置\n", 5)

print("会话管理器脚本已加载")