strings_i18n = {}

strings_i18n["en"] = {
    ["moves:"] = "moves:",
    ["level_prefix"] = "level",
    ["level_postfix"] = "",
    ["best:"]  = "best:",
    ["optimal:"]  = "optimal:",
    ["by:"]  = "by ",
    ["back"]   = "back",

    ["easy"]   = "easy",
    ["medium"] = "medium",
    ["hard"]   = "hard",
    ["community"] = "community",

    ["settings"] = "settings",

    -- settings
    ["sound"]   = "sound",
    ["xo_buttons"] = "X/O buttons",
    ["reset_button"] = "reset button",
    ["confirmations"] = "confirmation dialogs",
    ["color_scheme"] = "color scheme",
    ["color_scheme_1"] = "A",
    ["color_scheme_2"] = "B",
    ["done"]    = "done",
    ["on"]      = "on",
    ["off"]     = "off",

    ["level complete"] = "level complete",
    ["high score!"]    = "new record!",

    ["conf_levelmenu"] = "Return to level menu?",
    ["conf_nextlevel"] = "Go to next level?",
    ["conf_prevlevel"] = "Go to previous level?",
    ["conf_reset"]     = "Reset game?",
    ["progresslost"]   = "Progress on this level will be lost.",

    ["no"] = "No",
    ["yes"] = "Yes",

    ["credits"] = "Flowit game by ByteHamster\nPorted by ywnico\nVersion " .. version_str .. "\ngithub.com/Flowit-Game",
}

strings_i18n["ja"] = {
    ["moves:"] = "指し手：",
    ["level_prefix"] = "レベル",
    ["level_postfix"] = "",
    ["best:"]  = "自己ベスト：",
    ["optimal:"]  = "最適：",
    ["by:"]  = "作成者：",
    ["back"]   = "戻る",

    ["easy"]   = "イージー",
    ["medium"] = "ノーマル",
    ["hard"]   = "ハード",
    ["community"] = "コミュニティ",

    ["settings"] = "設定",

    -- settings
    ["sound"]   = "効果音",
    ["xo_buttons"] = "ＯＸボタン",
    ["reset_button"] = "リセットボタン",
    ["confirmations"] = "確認メッセージ",
    ["color_scheme"] = "配色",
    ["color_scheme_1"] = "A",
    ["color_scheme_2"] = "B",
    ["done"]    = "完了",
    ["on"]      = "オン",
    ["off"]     = "オフ",

    ["level complete"] = "レベル修了",
    ["high score!"]    = "新記録！",

    ["conf_levelmenu"] = "レベルメニューへ戻りますか？",
    ["conf_nextlevel"] = "次のレベルへ進みますか？",
    ["conf_prevlevel"] = "前のレベルへ戻りますか？",
    ["conf_reset"]     = "レベルをリセットしますか？",
    ["progresslost"]   = "このレベルの状態は消えます。",

    ["no"] = "いいえ",
    ["yes"] = "はい",

    ["credits"] = "Flowitゲームクリエイター：ByteHamster\nゲームソフト移植：ywnico\nバージョン：" .. version_str .. "\ngithub.com/Flowit-Game",
}

strings_i18n["zh_t"] = {
    ["moves:"] = "步：",
    ["level_prefix"] = "",
    ["level_postfix"] = "級",
    ["best:"]  = "個人最佳：",
    ["optimal:"]  = "最優：",
    ["by:"]  = "作者：",
    ["back"]   = "回去",

    ["easy"]   = "簡單",
    ["medium"] = "中等",
    ["hard"]   = "困難",
    ["community"] = "社區貢獻",

    ["settings"] = "設定",

    -- settings
    ["sound"]   = "音效",
    ["xo_buttons"] = "ＯＸ按鈕",
    ["reset_button"] = "復位按鈕",
    ["confirmations"] = "確認提示",
    ["color_scheme"] = "配色",
    ["color_scheme_1"] = "A",
    ["color_scheme_2"] = "B",
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

    ["credits"] = "Flowit遊戲作者：ByteHamster\n軟體移植：ywnico\n版本：" .. version_str .. "\ngithub.com/Flowit-Game",
}

strings_i18n["zh_s"] = {
    ["moves:"] = "步：",
    ["level_prefix"] = "",
    ["level_postfix"] = "级",
    ["best:"]  = "个人最佳：",
    ["optimal:"]  = "最优：",
    ["by:"]  = "作者：",
    ["back"]   = "回去",

    ["easy"]   = "简单",
    ["medium"] = "中等",
    ["hard"]   = "困难",
    ["community"] = "社区贡献",

    ["settings"] = "设定",

    -- settings
    ["sound"]   = "音效",
    ["xo_buttons"] = "ＯＸ按钮",
    ["reset_button"] = "复位按钮",
    ["confirmations"] = "确认提示",
    ["color_scheme"] = "配色",
    ["color_scheme_1"] = "A",
    ["color_scheme_2"] = "B",
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

    ["credits"] = "Flowit游戏作者：ByteHamster\n软件移植：ywnico\n版本：" .. version_str .. "\ngithub.com/Flowit-Game",
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
