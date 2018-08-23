local view = require("packages.mvc.view_base")

local map_view = view:instance()

map_view.RESOURCE_BINDING = {
    ["map_img"]				= {["varname"] = "map_img"},
    ["arena_show_node"]		= {["varname"] = "arena_show_node"},
    ["arena_bottom_node"]	= {["varname"] = "arena_bottom_node"},
    ["arena_event_node"]	= {["varname"] = "arena_event_node"},
    ["model_panel"]			= {["varname"] = "model_panel"},
    ["arena_top_node"]		= {["varname"] = "arena_top_node"},
    ["mask_img"]			= {["varname"] = "mask_img"},
    ["blood_template"]		= {["varname"] = "blood_template"},
    ["fly_word_template"]	= {["varname"] = "fly_word_template"},
    ["pre_panel"]			= {["varname"] = "pre_panel"},
    ["logo_node"]			= {["varname"] = "logo_node"},
}

function map_view:init_ui()
	self:initPrePanel()
	self:initArena()
	self:initArenaBottomNode()
end

function map_view:init_info()
	self.monster_model_list = {}
	self.model_node_list = {}
	self.monster_loaded_num = 0
	self.skew_angle = 60
	self.arena_event_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.arena_show_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.arena_bottom_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.arena_top_node:setRotation3D(cc.vec3(self.skew_angle,0,0))
	self.model_panel:setRotation3D(cc.vec3(self.skew_angle,0,0))
    self.camera = self.ctrl:getScene():getDefaultCamera()
    self.eventDispatcher = cc.Director:getInstance():getEventDispatcher()
end

function map_view:init_events()
	self:pauseArenaListener()
end

function map_view:update_view()
	if Judgment:Instance():is_wait_order() then
		self:show_guide()
	else
		self:hideGuide()
	end
end

function map_view:beginAnimation()
	self:playEnterAnimation()
	self:cameraAnimation()
end

function map_view:cameraAnimation()
	local ac1 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Wait_Time+3,0.75))
	local ac2 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Action_Time,1))
	local callback = cc.CallFunc:create(handler(self.ctrl,self.ctrl.startGame))

	local seq = cc.Sequence:create(ac1,ac2,callback)
		
	self:showMask()
	self.root:runAction(seq)
end

function map_view:endAnimation()
	self:hideGuide()
	local ac1 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Wait_Time,1))
	local ac2 = self.root:runAction(cc.ScaleTo:create(self.ctrl.Action_Time,0.75))
	local callback = cc.CallFunc:create(handler(self.ctrl,self.ctrl.open_result_view))

	local seq = cc.Sequence:create(ac1,ac2,callback)
		
	self.root:runAction(seq)
	self:hideMask()
	self.ctrl:close_battle_info_view()
end

function map_view:get_position_by_int(num)
	local pos = gtool:int_2_ccp(num)
	local a,b = self["gezi_"..pos.x.."_"..pos.y]:getPosition()
	return cc.p(a,b)
end
----------------------------------------------------------------
-------------------------------Ë½ÓÐ·½·¨--------------------------
----------------------------------------------------------------
function map_view:show_other_around_info(monster)
	self:hideGuide()
	self:show_guide(monster)
end

function map_view:hide_other_around_info()
	self:hideGuide()
	self:show_guide()
end

function map_view:show_guide(monster)
	local cur_active_monster = monster or Judgment:Instance():get_cur_active_monster()
	
	local gezi_list = cur_active_monster:getAroundInfo(monster)

	local a,b = self["gezi_"..gezi_list[0].x.."_"..gezi_list[0].y.."_black"]:getPosition()
	self.cur_monster_pos_sp:setPosition(cc.p(a,b))
	
	for k,v in pairs(gezi_list) do
		if k>10 and v<100 and v>10 then
			self:showCanMoveToGezi(k)
		elseif k>10 and v>100 then
			if math.floor(v/100) == Judgment.MapItem.ENEMY then
				self:showEnemy(k,monster,v%100)
			end
		end
    end
end

function map_view:showEnemy(num,monster,distance)
	local cur_active_monster = monster or Judgment:Instance():get_cur_active_monster()
	local atk_img
	
	if cur_active_monster:is_melee() then
		atk_img = self.close_attack_img:clone()
	elseif distance>5 or distance < 3 then
		atk_img = self.too_far_attack_img:clone()
	else
		atk_img = self.far_attack_img:clone()
	end

	local x,y = math.modf(num/10),num%10
	atk_img:setPosition(self["gezi_"..x.."_"..y]:getPosition())

	self.arena_top_node:addChild(atk_img)
	uitool:repeat_fade_in_and_out(atk_img)

	local img = atk_img:getChildByName("img")
	uitool:makeImgToButtonHT(img,self.camera,function()
		Judgment:Instance():select_target(num,distance)
	end)
end

function map_view:showCanMoveToGezi(num)
	local x,y = math.modf(num/10),num%10
	if self["gezi_"..x.."_"..y.."_black"] then 
		self["gezi_"..x.."_"..y.."_black"]:setVisible(true)
		self["gezi_"..x.."_"..y.."_black"]:setScale(0.1)
		local time = math.random()/3+0.1
		self["gezi_"..x.."_"..y.."_black"]:runAction(cc.FadeIn:create(time))
		self["gezi_"..x.."_"..y.."_black"]:runAction(cc.ScaleTo:create(time,1))
		self.eventDispatcher:resumeEventListenersForTarget(self["gezi_"..x.."_"..y])
	end
end

function map_view:hideGuide()
	self.arena_top_node:removeAllChildren()
	self.cur_monster_pos_sp:setPosition(uitool:farAway())
    for x=1,8 do
    	for y=1,7 do
    		if self["gezi_"..x.."_"..y.."_black"] then 
    			self["gezi_"..x.."_"..y.."_black"]:setOpacity(0)
    			self["gezi_"..x.."_"..y.."_black"]:setVisible(false)
    			self.eventDispatcher:pauseEventListenersForTarget(self["gezi_"..x.."_"..y])
    		end
    	end
    end
end

function map_view:showMask()
	local ac1 = self.mask_img:runAction(cc.FadeOut:create(self.ctrl.Wait_Time+3))
	local ac2 = self.mask_img:runAction(cc.FadeIn:create(self.ctrl.Action_Time))

	local seq = cc.Sequence:create(ac1,ac2)
	
	self.mask_img:runAction(seq)
end

function map_view:hideMask()
	local ac1 = self.mask_img:runAction(cc.FadeIn:create(self.ctrl.Wait_Time))
	local ac2 = self.mask_img:runAction(cc.FadeOut:create(self.ctrl.Action_Time))

	local seq = cc.Sequence:create(ac1,ac2)
	
	self.mask_img:runAction(seq)
end
--------------------------Õ½³¡²¿·Ö¿ªÊ¼-------------------------
function map_view:createMonsterModel(monster)
    if monster.model then
        self.model_panel:removeChild(monster.model)
        monster.model = nil
    end

	self.model_node_list[monster:getTag()] = cc.Node:create()
	self.model_node_list[monster:getTag()]:retain()
	
	local callback = function(model)
		model:setScale(0.5)
		local node = self.model_node_list[monster:getTag()]
		local pos = monster:get_start_pos()
        local x,y = self["gezi_"..pos.x.."_"..pos.y]:getPosition()
        if monster:is_fly() then
        	node:setPosition(x,y+10)
        else
        	node:setPosition(x,y-10)
        end
		node:addChild(model)
        monster.node = node
		local blood_bar = self:initBloodBar(node,monster)
		self.model_panel:addChild(node)

		monster.model = model
		monster.animation = cc.Animation3D:create(monster.model_path)
		monster:reset()

		
		self.monster_loaded_num = self.monster_loaded_num + 1
		
	end
    cc.Sprite3D:createAsync(monster.model_path,callback)
    
end

function map_view:createOtherModel(other_model,pos)
	local callback = function(model)
		model:setScale(4)
        local x,y = self["gezi_"..pos.x.."_"..pos.y]:getPosition()
        model:setPosition(x,y)
		self.model_panel:addChild(model)
	end
	if other_model == 2 then
		local chapter_num, level_num = Judgment:Instance():get_cur_chapter_and_level()
		local barrier = self.ctrl.map_data:getBarrierModelByChapterAndLevel(chapter_num, level_num)
    	cc.Sprite3D:createAsync(barrier,callback)
    end
end

function map_view:initBloodBar(node,monster)
	local blood_bar = self.blood_template:clone()
	blood_bar.child = {}
	blood_bar.child.blood_img = blood_bar:getChildByName("blood_img")
	blood_bar.child.level_text = blood_bar:getChildByName("level_text")

	blood_bar.child.blood_img:loadTexture(Config.sprite["team_hp_img_"..monster.team_side])
	blood_bar.child.level_text:setString(monster.level)

	local updateHP = function(percent,damage,type)
		self:createDamageFlyWords(damage,monster,type)
		uitool:set_progress_bar(blood_bar.child.blood_img,percent)
	end

	local updateAnger = function(anger)
		for i=1,4 do
			if not (i>anger) then
				blood_bar:getChildByName("star_"..i):setVisible(true)
			else
				blood_bar:getChildByName("star_"..i):setVisible(false)
			end
		end
	end

	blood_bar.updateHP = updateHP
	blood_bar.updateAnger = updateAnger
	blood_bar:setPosition(0,75)
	uitool:set_node_to_global_top(blood_bar)
	blood_bar:setName("blood_bar")
	monster.blood_bar = blood_bar
	node:addChild(blood_bar)
end

function map_view:createDamageFlyWords(damage,monster,level)
	local fly_word = self.fly_word_template:clone()
	fly_word:setString(damage)
	fly_word:setTextColor(Config.color["damage_"..level])
	local x,y = monster.node:getPosition()

	fly_word:setPosition(x,y+60)
	--fly_word:setGlobalZOrder(uitool:top_z_order())
	fly_word:setScale(0.2)
	
	self.arena_top_node:addChild(fly_word)

	local ac1 = fly_word:runAction(cc.ScaleTo:create(0.2,1))
	fly_word:stopAction(ac1)
	local ac2 = fly_word:runAction(cc.MoveTo:create(0.5,cc.p(x,y+80)))
	fly_word:stopAction(ac2)
	local ac3 = fly_word:runAction(cc.FadeOut:create(0.1))
	fly_word:stopAction(ac3)
	
	local seq = cc.Sequence:create(ac1,ac2,ac3)

	fly_word:runAction(seq)
end

function map_view:initArena()
	for x=1,8 do
		for y=1,7 do
			--ÕâÀïÎªÁËÌá¸ßÐ§ÂÊ£¬µ÷ÓÃÁËÔ­±¾µÄ½Ó¿Ú£¬Ö»ÔÚÒ»²ãÀïÃæÑ°ÕÒ½Úµã¡£
			self["gezi_"..x.."_"..y] = self.arena_event_node:getChildByName("gezi_"..x.."_"..y)
			self["gezi_"..x.."_"..y.."_black"] = self.arena_bottom_node:getChildByName("gezi_"..x.."_"..y)
			if self["gezi_"..x.."_"..y] then
				self["gezi_"..x.."_"..y].arena_pos = cc.p(x,y)
                self:addArenaListener(self["gezi_"..x.."_"..y])
			end
		end
	end

end

--ÒòÎªÆåÅÌ×ö¹ýÇãÐ±´¦Àí£¬ËùÒÔÕâÀïÒªÓÃÉäÏßÀ´´¦Àí
function map_view:addArenaListener(gezi)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()
		local start_location = touch:getLocation()
		if Judgment:Instance():is_wait_order() then
        	if node:hitTest(start_location, self.camera, nil) then
        		local x,y = node:getPosition()
        		self.moveto_point_sp:setPosition(x,y)
        		self.target_gezi = node
        	end
        	return true
        else
        	return false
        end
    end

    local function touchMoved( touch, event )
        local node = event:getCurrentTarget()
        local cur_location = touch:getLocation()

        if node:hitTest(cur_location, self.camera, nil) then
        	local x,y = node:getPosition()
        	self.moveto_point_sp:setPosition(x,y)
        	self.target_gezi = node
        elseif self.target_gezi and self.target_gezi:getTag() == node:getTag() then
        	self.moveto_point_sp:setPosition(uitool:farAway())
            self.target_gezi = nil
        end
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        local cur_location = touch:getLocation()
        self.moveto_point_sp:setPosition(uitool:farAway())

        if node:hitTest(cur_location, self.camera, nil) then
            Judgment:Instance():select_pos(node)
        end
    end

    gezi.listener = cc.EventListenerTouchOneByOne:create()
    --gezi.listener:setSwallowTouches(true)
    gezi.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    gezi.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    gezi.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self.eventDispatcher:addEventListenerWithSceneGraphPriority(gezi.listener, gezi)
end

function map_view:resumeArenaListener()
	
	for x=1,8 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self.eventDispatcher:resumeEventListenersForTarget(self["gezi_"..x.."_"..y])
			end
		end
	end
end

function map_view:pauseArenaListener()
	
	for x=1,8 do
		for y=1,7 do 
			if self["gezi_"..x.."_"..y] then
				self.eventDispatcher:pauseEventListenersForTarget(self["gezi_"..x.."_"..y])
			end
		end
	end
end

function map_view:initArenaBottomNode()
	self.moveto_point_sp 		= self.arena_bottom_node:getChildByName("moveto_point_sp")
	self.cur_monster_pos_sp 	= self.arena_bottom_node:getChildByName("cur_monster_pos_sp")
	self.far_attack_img 		= self.arena_bottom_node:getChildByName("far_attack_img")
	self.too_far_attack_img 	= self.arena_bottom_node:getChildByName("too_far_attack_img")
	self.close_attack_img 		= self.arena_bottom_node:getChildByName("close_attack_img")
end

function map_view:clearModelPanel()
	self.model_panel:removeAllChildren()
end

--------------------------Õ½³¡²¿·Ö½áÊø-------------------------


--------------------------½ø³¡¶¯»­¿ªÊ¼-------------------------
function map_view:initPrePanel()
	self.shield_img 	= self.logo_node:getChildByName("shield_img")
	self.sword_img	 	= self.logo_node:getChildByName("sword_img")
	self.em_img 		= self.logo_node:getChildByName("em_img")
	self.ts_img 		= self.logo_node:getChildByName("ts_img")
	self.word_img 		= self.logo_node:getChildByName("word_img")

end

function map_view:playEnterAnimation()

	self.shield_img:runAction(cc.FadeIn:create(0.5))
	local a1 = self.word_img:runAction(cc.FadeIn:create(0.5))
	local a2 = self.word_img:runAction(cc.ScaleTo:create(0.4,1))
	local seq1 = cc.Sequence:create(a1,a2)
	self.word_img:runAction(seq1)

	local ac1 = self.sword_img:runAction(cc.ScaleTo:create(0.4,1.2))
	self.sword_img:stopAction(ac1)
	local ac2 = self.sword_img:runAction(cc.MoveTo:create(0.3,uitool:zero()))
	self.sword_img:stopAction(ac2)
	local callback = function()
		self.word_img:setVisible(true)
		self.ts_img:runAction(cc.RotateTo:create(0.4,0))
		self.em_img:runAction(cc.RotateTo:create(0.4,0))
		self.ts_img:runAction(cc.FadeIn:create(0.3))
		self.em_img:runAction(cc.FadeIn:create(0.3))
	end

	callback = cc.CallFunc:create(callback)

	local seq2 = cc.Sequence:create(ac1,ac2,callback)

	self.sword_img:runAction(seq2)

	local ac3 =  self.logo_node:runAction(cc.FadeIn:create(2))
	self.logo_node:stopAction(ac3)
	local ac4 =  self.logo_node:runAction(cc.ScaleTo:create(1,0))
	self.logo_node:stopAction(ac4)

	local seq3 = cc.Sequence:create(ac3,ac4)

	self.logo_node:runAction(seq3)


	local ac5 =  self.pre_panel:runAction(cc.FadeIn:create(3))
	self.pre_panel:stopAction(ac5)
	local ac6 =  self.pre_panel:runAction(cc.MoveTo:create(0.2,cc.p(0,4000)))
	self.pre_panel:stopAction(ac6)

	local seq4 = cc.Sequence:create(ac5,ac6)

	self.pre_panel:runAction(seq4)
end

function map_view:initEnterAnimation()
	self.shield_img:setOpacity(0)

	self.sword_img:setPositionY(1500)
	self.sword_img:setScale(1.2)

	self.ts_img:setRotation(-60)
	self.em_img:setRotation(60)
	self.ts_img:setOpacity(0)
	self.em_img:setOpacity(0)

	self.word_img:setScale(5)
	self.word_img:setVisible(false)

	self.logo_node:setScale(1)
	self.logo_node:setVisible(true)

	self.pre_panel:setPosition(960,216)
end
--------------------------½ø³¡¶¯»­½áÊø-------------------------

return map_view