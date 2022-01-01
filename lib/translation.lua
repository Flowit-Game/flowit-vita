strings_i18n = {}

strings_i18n["en"] = {
    ["moves:"] = "moves:",
    ["level_prefix"] = "level",
    ["level_postfix"] = "",
    ["best:"]  = "best:",
    ["back"]   = "back",

    ["easy"]   = "easy",
    ["medium"] = "medium",
    ["hard"]   = "hard",

    ["settings"] = "settings",

    -- settings
    ["sound"]   = "sound",
    ["buttons"] = "buttons",
    ["done"]    = "done",
    ["on"]      = "",
    ["off"]     = "",

    ["level complete"] = "level complete",
    ["high score!"]    = "new record!",

    ["conf_levelmenu"] = "Return to level menu?",
    ["conf_nextlevel"] = "Go to next level?",
    ["conf_prevlevel"] = "Go to previous level?",
    ["conf_reset"]     = "Reset game?",
    ["progresslost"]   = "Progress on this level will be lost.",

    ["no"] = "No",
    ["yes"] = "Yes",
}

strings_i18n["ja"] = {
    ["moves:"] = "指し手：",
    ["level_prefix"] = "レベル",
    ["level_postfix"] = "",
    ["best:"]  = "ベスト：",
    ["back"]   = "戻る",

    ["easy"]   = "イージー",
    ["medium"] = "ノーマル",
    ["hard"]   = "ハード",

    ["settings"] = "設定",

    -- settings
    ["sound"]   = "効果音",
    ["buttons"] = "ボタン",
    ["done"]    = "完了",
    ["on"]      = "オン",
    ["off"]     = "オフ",

    ["level complete"] = "レベル修了",
    ["high score!"]    = "新記録！",

    ["conf_levelmenu"] = "レベルメニューへ戻りますか？",
    ["conf_nextlevel"] = "次のレベルへ進みますか？",
    ["conf_prevlevel"] = "前のレベルへ戻りますか？",
    ["conf_reset"]     = "レベルをやり直しますか？",
    ["progresslost"]   = "このレベルの状態は消えます。",

    ["no"] = "いいえ",
    ["yes"] = "はい",
}

strings_i18n["zh_t"] = {
    ["moves:"] = "步：",
    ["level_prefix"] = "",
    ["level_postfix"] = "級",
    ["best:"]  = "最佳：",
    ["back"]   = "回去",

    ["easy"]   = "簡單",
    ["medium"] = "中等",
    ["hard"]   = "困難",

    ["settings"] = "設定",

    -- settings
    ["sound"]   = "音效",
    ["buttons"] = "按鈕",
    ["done"]    = "完成",
    ["on"]      = "開啟",
    ["off"]     = "關閉",

    ["level complete"] = "等級完成",
    ["high score!"]    = "成績最佳！",

    ["conf_levelmenu"] = "要回到選單嗎？",
    ["conf_nextlevel"] = "要跳到下個等級嗎？",
    ["conf_prevlevel"] = "要回到上個等級嗎？",
    ["conf_reset"]     = "要重新開始嗎？",
    ["progresslost"]   = "這個等級的進度會被失去。",

    ["no"] = "否",
    ["yes"] = "是",
}

strings_i18n["zh_s"] = {
    ["moves:"] = "步：",
    ["level_prefix"] = "",
    ["level_postfix"] = "级",
    ["best:"]  = "最佳：",
    ["back"]   = "回去",

    ["easy"]   = "简单",
    ["medium"] = "中等",
    ["hard"]   = "困难",

    ["settings"] = "设定",

    -- settings
    ["sound"]   = "音效",
    ["buttons"] = "按钮",
    ["done"]    = "完成",
    ["on"]      = "开启",
    ["off"]     = "关闭",

    ["level complete"] = "等级完成",
    ["high score!"]    = "成绩最佳！",

    ["conf_levelmenu"] = "要回到选单吗？",
    ["conf_nextlevel"] = "要跳到下个等级吗？",
    ["conf_prevlevel"] = "要回到上个等级吗？",
    ["conf_reset"]     = "要重新开始吗？",
    ["progresslost"]   = "这个等级的进度会被失去。",

    ["no"] = "否",
    ["yes"] = "是",
}

function get_i18n(s)
    if not s then
        return nil
    end
    if strings_i18n[lang_code] == nil then
        lang_code = "en"
    end

    local s2 = strings_i18n[lang_code][s]
    if s2 == nil then
        return s
    end

    return s2
end
