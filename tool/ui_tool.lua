uitool = {}

function uitool:far_away()
    return cc.p(10000,10000)
end

function uitool:zero()
    return cc.p(0,0)
end

function uitool:top_z_order()
    return 2000
end

function uitool:mid_z_order()
    return 1000
end

function uitool:bottom_z_order()
    return 0
end

function uitool:screen_center_pos()
    return cc.p(960,540)
end

function uitool:get_node_center_position(node)
    local size = node:getContentSize()
    return cc.p(size.width/2,size.height/2)
end

function uitool:get_node_bottom_center_position(node)
    local size = node:getContentSize()
    return cc.p(size.width/2,0)
end

function uitool:create_ui_binding(panel,binding)
    assert(panel:get_root(), "uitool:createResourceBinding() - not load resource node")
	for nodeName, nodeBinding in pairs(binding) do
        local node = self:seek_child_node(panel:get_root(), nodeName);
        if nodeBinding.varname then
            panel[nodeBinding.varname] = node
        end
    end
end

function uitool:seek_child_node(node, name)
    local child = node:getChildByName(name)
    --print("find" .. name .. "in" .. node:getName())
    if child then
        return child 
    else
        local children = node:getChildren()
        for i=1, #children do
            child = self:seek_child_node(children[i], name)
            if child then
                return child
            end
        end
        return nil
    end
end

function uitool:is_touch_in_node_rect(node,touch,event,scale)
    local scale = scale or 1.0
    local node = event:getCurrentTarget()
    local locationInNode = node:convertToNodeSpace(touch:getLocation())
    local border = node:getContentSize()
    local rect = cc.rect(0,0,border.width*scale,border.height*scale)
    
    return cc.rectContainsPoint(rect, locationInNode)
end


function uitool:is_touch_in_node_circle(node,touch,event,scale)
    local scale = scale or 1.0
    local node = event:getCurrentTarget()
    local locationInNode = node:convertToNodeSpace(touch:getLocation())
    local x,y = node:getPosition()
    local radius = math.min(node:getContentSize().width,node:getContentSize().height)
    

    return math.pow(locationInNode.x - x, 2) + math.pow(locationInNode.y - y, 2) < math.pow(radius)
end

function uitool:move_to_and_fade_out(node,pos)
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:move_to_and_fade_out(children[i])
        end
    end

    local ac1 = nil 
    if pos then
        ac1 = node:runAction(cc.MoveTo:create(0.1,cc.p(pos.x,pos.y)))
    end   
    local ac2 = node:runAction(cc.FadeOut:create(0.2))

    local seq1 = cc.Sequence:create(ac1,ac2)
    
    node:runAction(seq1)
end

function uitool:repeat_fade_in_and_out(node)
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:repeat_fade_in_and_out(children[i])
        end
    end

    local ac1 = node:runAction(cc.FadeTo:create(1,155)) 
    local ac2 = node:runAction(cc.FadeTo:create(1,255))

    local seq = cc.Sequence:create(ac1,ac2)
    
    node:runAction(cc.RepeatForever:create(seq))
end

function uitool:repeat_scale(node)
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:repeat_scale(children[i])
        end
    end

    local ac1 = node:runAction(cc.ScaleTo:create(0.5,1.1)) 
    local ac2 = node:runAction(cc.ScaleTo:create(0.5,1))

    local seq = cc.Sequence:create(ac1,ac2)
    
    node:runAction(cc.RepeatForever:create(seq))
end

function uitool:set_progress_bar(img,percent)
    if not img.raw_size then
        img.raw_size = img:getContentSize()
    end
    if percent < 0 then 
        percent = 0
    end
    if percent > 1 then 
        percent = 1
    end
    img:setContentSize(img.raw_size.width*percent,img.raw_size.height)
end

function uitool:set_node_to_global_top(node,z)
    z = z or self:top_z_order()
    local children = node:getChildren()

    if #children > 0 then
        for i=1, #children do
            self:set_node_to_global_top(children[i])
        end
    end

    node:setGlobalZOrder(z)
end

function uitool:makeImgToButton(img,callback)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()

        if self:is_touch_in_node_rect(node,touch,event) then
            node:setScale(1.06)
            return true
        end

        return false
    end

    local function touchMoved( touch, event )
        local node = event:getCurrentTarget()

        if self:is_touch_in_node_rect(node,touch,event) then
            node:setScale(1.06)
        else
            node:setScale(1.0)
        end
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        
        if self:is_touch_in_node_rect(node,touch,event) then
            if callback then
                callback()
            end
        end
        node:setScale(1.0)
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    --img.listener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

function uitool:makeImgToButtonNoScale(img,callback)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()

        if self:is_touch_in_node_rect(node,touch,event) then
            return true
        end

        return false
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        
        if self:is_touch_in_node_rect(node,touch,event) then
            if callback then
                callback()
            end
        end
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

function uitool:makeImgToButtonHT(img,camera,callback)
    local function touchBegan( touch, event )
        local node = event:getCurrentTarget()
        local start_location = touch:getLocation()

        if node:hitTest(start_location, camera, nil) then
            return true
        end

        return false
    end

    local function touchEnded( touch, event )
        local node = event:getCurrentTarget()
        local end_location = touch:getLocation()

        if node:hitTest(end_location, camera, nil) then
            if callback then
                callback()
            end
        end
    end

    img.listener = cc.EventListenerTouchOneByOne:create()
    img.listener:setSwallowTouches(true)
    img.listener:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    img.listener:registerScriptHandler(touchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(img.listener, img)
end

function uitool:initMonsterCardWithIDAndNum(card,id,num,click_event)
    local monster = g_config.monter[id]
    card:loadTexture(monster.char_img_path)
    card.border_img = card:getChildByName("border_img")
    card.border_img:loadTexture(g_config.sprite["card_border_"..monster.rarity])
    card.type_img = card:getChildByName("type_img")
    card.type_img:loadTexture(g_config.sprite["attack_type_"..monster.attack_type])
    card.num_text = card:getChildByName("num_text")
    card.num_text:setString("X"..num)
    card.num_text:setTextColor(g_config.color["rarity_color_"..monster.rarity])
    if click_event then 
        cur_monster.head_img:addClickEventListener(click_event)
    end

end

function uitool:initOtherCardWithTypeAndNum(card,ctype,num,click_event)
    card.border_img = card:getChildByName("border_img")
    card.border_img:loadTexture(g_config.sprite.card_border_0)
    local x,y = card.border_img:getPosition()
    card.border_img:setPosition(x+3,y)
    card.type_img = card:getChildByName("type_img")
    card.type_img:setVisible(false)
    card.num_text = card:getChildByName("num_text")
    card.num_text:setString("+"..num)
    if ctype == "coin" then
        card:loadTexture(g_config.sprite.card_coin)
        card.num_text:setTextColor(g_config.color.coin)
    elseif ctype == "crystal" then
        card:loadTexture(g_config.sprite.card_crystal)
        card.num_text:setTextColor(g_config.color.crystal)
    end
    
    if click_event then 
        cur_monster.head_img:addClickEventListener(click_event)
    end

end

function uitool:createTopTip(string,color)
    color = color or "white"
    color = g_config.color[color]
    local scene = cc.Director:getInstance():getRunningScene()
    if not scene.top_tip then
        local tip_bg = cc.Sprite:create()
        tip_bg:setTexture(g_config.sprite.tip_bg)
        local label = cc.Label:createWithTTF(string,g_config.font.default,36)
        label:setPosition(self:get_node_center_position(tip_bg))
        tip_bg.label = label
        tip_bg:addChild(label)
        tip_bg:setScale(2)
        scene.top_tip = tip_bg
        scene:addChild(tip_bg, self:top_z_order())
    else
        scene.top_tip:stopAllActions()
        scene.top_tip.label:setString(string)
        scene.top_tip:setVisible(true)
    end

    scene.top_tip.label:setTextColor(color)

    scene.top_tip:setPosition(self:get_node_center_position(scene))

    local cb = function()
        scene.top_tip:setVisible(false)
    end

    local callback = cc.CallFunc:create(cb)

    local ac = scene.top_tip:runAction(cc.FadeIn:create(1))
    scene.top_tip:stopAction(ac)

    local seq = cc.Sequence:create(ac,callback)

    scene.top_tip:runAction(seq)
end