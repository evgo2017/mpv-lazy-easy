-- long-press-speedup.lua
-- 类似网络播放器（如B站），长按画面进行倍速播放，松开恢复原速，短按暂停/播放

local options = {
    key = "MBTN_LEFT",              -- 触发长按倍速的按键。MBTN_LEFT 为鼠标左键，RIGHT 为方向键右等。
    speed = 2.0,                    -- 长按时触发的播放倍速配置。默认为 2.0 倍速。
    threshold_sec = 0.3,            -- 判定为“长按”所需的时间（单位：秒）。超过此时间则判定为长按。
    short_press_cmd = "cycle pause" -- 当触发短按（按下并立刻松开，且时间短于阈值）时执行的 MPV 内部命令。默认为暂停/播放。
}

local timer = nil
local is_fast_playing = false
local normal_speed = 1.0

local function start_fast_play()
    if not is_fast_playing then
        normal_speed = mp.get_property_native("speed", 1.0)
        mp.set_property("speed", options.speed)
        mp.osd_message("▶▶ x" .. options.speed, 2)
        is_fast_playing = true
    end
end

local function stop_fast_play()
    if timer then
        timer:kill()
        timer = nil
    end
    if is_fast_playing then
        mp.set_property("speed", normal_speed)
        mp.osd_message("▶ x" .. normal_speed, 2)
        is_fast_playing = false
    else
        -- 短按，执行默认命令
        if options.short_press_cmd and options.short_press_cmd ~= "" then
            mp.command(options.short_press_cmd)
        end
    end
end

local function handle_key(table)
    if table.event == "down" then
        if timer then timer:kill() end
        timer = mp.add_timeout(options.threshold_sec, start_fast_play)
    elseif table.event == "up" then
        stop_fast_play()
    end
end

mp.add_forced_key_binding(options.key, "long_press_speedup", handle_key, {complex = true})
