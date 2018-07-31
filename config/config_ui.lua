Config = Config or {}
Config.sprite_path = "Sprite/"
Config.monster_img_path = "Monster/"
Config.model_path = "Model/"

Config.sprite = {
	gezi_raw = Config.sprite_path.."hex_tile_enabled.png",
	selected = Config.sprite_path.."icon_selected_1.png",
	chesspiece_mask = Config.sprite_path.."header_hex_mask.png",

	hex_border_0 = Config.monster_img_path.."hex_tile_border_0.png",
	hex_border_1 = Config.monster_img_path.."hex_tile_border_1.png",
	hex_border_2 = Config.monster_img_path.."hex_tile_border_2.png",
	hex_border_3 = Config.monster_img_path.."hex_tile_border_3.png",
	hex_border_4 = Config.monster_img_path.."hex_tile_border_4.png",

	rarity_sp_1 = Config.monster_img_path.."item_bg_1_1.png",
	rarity_sp_2 = Config.monster_img_path.."item_bg_1_2.png",
	rarity_sp_3 = Config.monster_img_path.."item_bg_1_3.png",
	rarity_sp_4 = Config.monster_img_path.."item_bg_1_4.png",

	card_border_0 = Config.monster_img_path.."hero_card_border_0.png",
	card_border_1 = Config.monster_img_path.."hero_card_border_1.png",
	card_border_2 = Config.monster_img_path.."hero_card_border_2.png",
	card_border_3 = Config.monster_img_path.."hero_card_border_3.png",
	card_border_4 = Config.monster_img_path.."hero_card_border_4.png",

	attack_type_1 = Config.monster_img_path.."icon_attack_type_1.png",
	attack_type_2 = Config.monster_img_path.."icon_attack_type_2.png",
	attack_type_3 = Config.monster_img_path.."icon_attack_type_3.png",
	attack_type_4 = Config.monster_img_path.."icon_attack_type_4.png",
}

Config.color = {
	rarity_color_1 = cc.c4b(66,152,76,255),
	rarity_color_2 = cc.c4b(74,154,219,255),
	rarity_color_3 = cc.c4b(193,78,242,255),
	rarity_color_4 = cc.c4b(243,146,46,255),
}

Config.text = {
	monster_type_1 = "PHYSICAL MELEE",
	monster_type_2 = "MAGIC MELEE",
	monster_type_3 = "PHYSICAL RANGE",
	monster_type_4 = "MAGIC RANGE",

	rarity_text_1 = "RARITY: COMMON MONSTER",
	rarity_text_2 = "RARITY: EPIC MONSTER",
	rarity_text_3 = "RARITY: MONSTROUS MONSTER",
	rarity_text_4 = "RARITY: DIABOLIC MONSTER",
}