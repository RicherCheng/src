local view= require("packages.mvc.view_base")

local title_right_view = view:instance()

title_right_view.RESOURCE_BINDING = {
    ["crystal_num_text"]	= {["varname"] = "crystal_num_text"},
    ["add_crystal_btn"]		= {["varname"] = "add_crystal_btn"},
    ["coin_num_text"]		= {["varname"] = "coin_num_text"},
    ["add_coin_btn"]		= {["varname"] = "add_coin_btn"},
}

title_right_view.init_ui = function(self)
    
end

title_right_view.init_info = function(self)
    self._view_pos = cc.p(1850, 1025)
end

title_right_view.init_events = function(self)
	self.add_coin_btn:addClickEventListener(function(sender)
        -- self.coin_num_text:setString(self.coin_num+1)
		-- self.coin_num = self.coin_num_text:getString()
    end)

	self.add_crystal_btn:addClickEventListener(function(sender)
        -- self.crystal_num_text:setString(self.crystal_num + 1)
		-- self.crystal_num = self.crystal_num_text:getString()
    end)
end

title_right_view.update_info = function(self)
    local player_data = game_data_ctrl:instance():get_player_data()
    self.coin_num = player_data.coin_num
    self.crystal_num = player_data.crystal_num
end

title_right_view.update_view = function(self)
    self.coin_num_text:setString(self.coin_num)
    self.crystal_num_text:setString(self.crystal_num)
end

title_right_view.on_open = function(self)
    self:update_info()
    self:update_view()
end

return title_right_view