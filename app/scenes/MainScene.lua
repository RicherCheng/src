
local MainScene = class("MainScene", cc.load("mvc").SceneBase)


MainScene.RESOURCE_FILENAME = "MainScene.csb"
 
MainScene.RESOURCE_BINDING = {
	--main_view
    ["main_view"]			= {["varname"] = "main_view"},
	--title_right_view
    ["title_right_view"]	= {["varname"] = "title_right_view"},
	--setting_view
    ["setting_view"]		= {["varname"] = "setting_view"},
	--advence_panel
    ["adventure_view"]		= {["varname"] = "adventure_view"},
	--confirm_view
    ["confirm_view"]		= {["varname"] = "confirm_view"},
	--embattle_view
    ["embattle_view"]		= {["varname"] = "embattle_view"},
    --monster_list_view
    ["monster_list_view"]	= {["varname"] = "monster_list_view"},
    --monster_info_view
    ["monster_info_view"]	= {["varname"] = "monster_info_view"},
}

MainScene.VIEW_PATH = "app.views.mainscene"

function MainScene:onCreate()
	self.map_data = require("app.data.MapData")
	self.save_data = require("app.data.SaveData")
	self:dataInit()
	self:viewInit()
end

function MainScene:onEnter()
	self:openMainView()
	self:openTitleRightView()
end

function MainScene:onExit()
end

function MainScene:dataInit()
	self.save_data:init(self)
end

function MainScene:viewInit()
	self.main_view:init()
	self.title_right_view:init()
	self.setting_view:init()
	self.adventure_view:init()
	self.confirm_view:init()
	self.embattle_view:init()
	self.monster_list_view:init()
	self.monster_info_view:init()
end

function MainScene:goToFightScene()
	local scene = cc.Scene:create()
	local layer = self.app_:createView("FightScene")
	scene:addChild(layer)
	if scene then
		local ts = cc.TransitionFadeTR:create(1.5, scene)
		cc.Director:getInstance():pushScene(ts)
	end	
end

function MainScene:getMapData()
	return self.map_data
end

function MainScene:getSaveData()
	return self.save_data
end

function MainScene:saveData()
	return self.save_data:save()
end

function MainScene:getRewardByChapterAndLevel(chapter_num,level_num)
	return self.map_data:getRewardByChapterAndLevel(chapter_num,level_num)
end

function MainScene:getStarNumByChapterAndLevel(chapter_num,level_num)
	return self.save_data:getStarNumByChapterAndLevel(chapter_num,level_num)
end

function MainScene:getPlayerData()
	return self.save_data:getPlayerData()
end

function MainScene:openMainView()
	if self.main_view then
		self.main_view:openView()
	end
end

function MainScene:closeMainView()
	if self.main_view then
		self.main_view:closeView()
	end
end

function MainScene:openTitleRightView()
	if self.title_right_view then
		self.title_right_view:openView()
	end
end

function MainScene:openMonsterListView()
	if self.monster_list_view then
		self.main_view:closeView()
		self.monster_list_view:openView()
	end
end

function MainScene:closeMonsterListView()
	if self.monster_list_view then
        self.main_view:openView()
		self.monster_list_view:closeView()
	end
end

function MainScene:openMonsterInfoView(monster_list,index)
	if self.monster_info_view then
		self.monster_list_view:closeView()
		self.monster_info_view:openView(monster_list,index)
	end
end

function MainScene:closeMonsterInfoView()
	if self.monster_info_view then
        self.monster_list_view:openView()
		self.monster_info_view:closeView()
	end
end

function MainScene:openAdventureView()
	if self.adventure_view then
		self.main_view:closeView()
		self.adventure_view:openView()
	end
end

function MainScene:closeAdventureView()
	if self.adventure_view then
        self.main_view:openView()
		self.adventure_view:closeView()
	end
end

function MainScene:openEmbattleView()
	if self.embattle_view then
        self.adventure_view:closeView()
		self.embattle_view:openView()
	end
end

function MainScene:openSpecificEmbattleView(chapter_num,level_num)
	local data = self.map_data:getMapDataByStoryAndLevel(chapter_num,level_num)
	if self.embattle_view then
        self.adventure_view:closeView()
		self.embattle_view:openView(data)
	end
end

function MainScene:closeEmbattleView()
	if self.embattle_view then
        self.adventure_view:openView()
		self.embattle_view:closeView()
	end
end

function MainScene:openConfirmView(chapter_num,level_num)
	if self.confirm_view then
		self.confirm_view:openView(chapter_num,level_num,reward_data)
	end
end

function MainScene:closeConfirmView()
	if self.confirm_view then
		self.confirm_view:closeView()
	end
end

function MainScene:openSettingView()
	if self.setting_view then
		self.setting_view:openView()
	end
end

function MainScene:getCollectedMonsterList()
	return Config.Monster
end

return MainScene
