local view = require("packages.mvc.view_base")

local result_view = view:instance()

result_view.RESOURCE_BINDING = 
{
    ["result_bg_img"]		= {["varname"] = "result_bg_img"},
    ["result_band_img"]		= {["varname"] = "result_band_img"},
    ["star_1"]				= {["varname"] = "star_1"},
    ["star_2"]				= {["varname"] = "star_2"},
    ["star_3"]				= {["varname"] = "star_3"},
    ["result_text"]			= {["varname"] = "result_text"},
    ["reward_node"]         = {["varname"] = "reward_node"},
    ["left_btn_img"]		= {["varname"] = "left_btn_img"},
    ["right_btn_img"]		= {["varname"] = "right_btn_img"},
    ["reward_template"]     = {["varname"] = "reward_template"},
}

result_view.init_events = function(self)
    uitool:make_img_to_button(self.left_btn_img, function(sender)
    	self._ctrl:close_result_view()
    	self._ctrl:go_to_main_scene()
    end)

    uitool:make_img_to_button(self.right_btn_img, function(sender)
    	self._ctrl:close_result_view()
    	self._ctrl:go_to_main_scene()
    end)
end

result_view.update_info = function(self)
    self._reward_data = game_data_ctrl:instance():get_reward_by_chapter_and_level(self._result.chapter_num, self._result.level_num)
    self._reward_list = {}
end

result_view.update_view = function(self)
    for i = 1, 3 do
        local star_key = "star_" .. i
        if not (i > self._result.star_num) then
            self[star_key]:loadTexture(g_config.sprite.result_star_got)
        else
            self[star_key]:loadTexture(g_config.sprite.result_star_gray)
        end
    end
    local last_star_num = game_data_ctrl:instance():get_star_num_by_chapter_and_level(self._result.chapter_num, self._result.level_num)

    if self._result.star_num > 0 then
        self.result_bg_img:loadTexture(g_config.sprite.result_win_bg)
        self.result_band_img:loadTexture(g_config.sprite.result_win_band)
        self.result_text:setString(g_config.text.reward_first_get)
        self.reward_node:setVisible(true)
        self:update_reward()
    else
        self.result_bg_img:loadTexture(g_config.sprite.result_defeat_bg)
        self.result_band_img:loadTexture(g_config.sprite.result_defeat_band)
        self.result_text:setString(g_config.text.defeat)
        self.reward_node:setVisible(false)
    end

end

result_view.update_reward = function(self)
    self.reward_node:removeAllChildren()
    for k1, v1 in pairs(self._reward_data) do
        if k1 == "monster" then
            for k2, v2 in pairs(v1) do
                local card = self.reward_template:clone()
                uitool:init_monster_card_with_id_and_num(card, k2, v2)
                self.reward_node:addChild(card)
                table.insert(self._reward_list, card)
            end
        elseif (k1 == "coin" or k1 == "crystal") and v1 > 0 then
            local card = self.reward_template:clone()
            uitool:init_other_card_with_type_and_num(card, k1, v1)
            self.reward_node:addChild(card)
            table.insert(self._reward_list, card)
        end
    end
    local offset = 0
    local interval =  self.reward_template:getContentSize().width + 50
    if (#self._reward_list) % 2 == 0 then
        offset = interval / 2
    end
    local mid = math.floor((#self._reward_list) / 2) + 1
    
    for i, v in ipairs(self._reward_list) do
        v:setPosition((i - mid) * interval + offset, 0)
    end

    self:deal_with_result_and_reward()
end

result_view.deal_with_result_and_reward = function(self)
    game_data_ctrl:instance():set_star_num(self._result.chapter_num, self._result.level_num, self._result.star_num)
    game_data_ctrl:instance():add_reward_to_save_data(self._reward_data)
    self._result = nil
end

result_view.set_result = function(self, result)
    self._result = result
end

result_view.on_open = function(self)
    if self._result and type(self._result) == type({}) then
       self:update_info()
       self:update_view()
    end
end


return result_view