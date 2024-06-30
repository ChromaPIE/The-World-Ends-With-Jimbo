-- == DRAGON COUTURE
-- == Card draw and hand size

local stuffToAdd = {}

-- Self Found, Others Lost
table.insert(stuffToAdd, {
	object_type = "Joker",
	name = "selfFound",
	key = "selfFound",
	config = {extra = {handSize = 0, handSizeBuff = 2}},
	pos = {x = 1, y = 2},
	loc_txt = {
		name = 'Self Found, Others Lost',
		text = {
			"{C:attention}重掷{}商店可使",
			"下一回合手牌上限{C:attention}+#1#",
			"{C:inactive}（当前可{C:attention}+#2#{C:inactive}手牌上限）"
		}
	},
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	atlas = "jokers",
	loc_vars = function(self, info_queue, center)
		return {vars = {center.ability.extra.handSizeBuff, center.ability.extra.handSize}}
	end,
	calculate = function(self, card, context)
		if context.reroll_shop and not context.blueprint then
			card.ability.extra.handSize = card.ability.extra.handSize + card.ability.extra.handSizeBuff
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Upgrade!"})
		end
		
		if context.ending_shop and not context.blueprint then
			G.hand:change_size(card.ability.extra.handSize)
		end
		
		if context.end_of_round and not context.individual and not context.repetition
		and not context.blueprint then
			G.hand:change_size(-card.ability.extra.handSize)
			card.ability.extra.handSize = 0
		end
	end
})

-- One Grain, Infinite Promise
table.insert(stuffToAdd, {
	object_type = "Joker",
	name = "oneGrain",
	key = "oneGrain",
	config = {extra = {toDraw = 4, inRound = false}},
	pos = {x = 3, y = 2},
	loc_txt = {
		name = 'One Grain, Infinite Promise',
		text = {
			"在回合内使用{C:attention}消耗牌{}时",
			"抽{C:attention}#1#{}张牌"
		}
	},
	rarity = 1,
	cost = 3,
	discovered = true,
	blueprint_compat = true,
	atlas = "jokers",
	loc_vars = function(self, info_queue, center)
		return {vars = {center.ability.extra.toDraw}}
	end,
	calculate = function(self, card, context)
		if context.using_consumeable and #G.hand.cards>0 and card.ability.extra.inRound then
			local card_count = card.ability.extra.toDraw
			for i=1, card_count do
				draw_card(G.deck,G.hand, i*100/card_count,nil, nil , nil, 0.07)
				G.E_MANAGER:add_event(Event({func = function() G.hand:sort() return true end}))
			end
		end
		
		if context.first_hand_drawn and not context.blueprint then
			card.ability.extra.inRound = true
		end
		
		if context.end_of_round and not context.individual and not context.repetition
		and not context.blueprint then
			card.ability.extra.inRound = false
		end
	end
})

-- One Stroke, Vast Wealth
table.insert(stuffToAdd, {
	object_type = "Joker",
	name = "oneStroke",
	key = "oneStroke",
	config = {extra = {perDollar = 20, handSize = 0, handSizeMax = 10}},
	pos = {x = 2, y = 2},
	loc_txt = {
		name = 'One Stroke, Vast Wealth',
		text = {
			"每拥有{C:money}$#1#{}，手牌上限{C:attention}+1",
			"至多可{C:attention}+#3#",
			"{C:inactive}（当前为{C:attention}+#2#{C:inactive}手牌上限）"
		}
	},
	rarity = 2,
	cost = 7,
	discovered = true,
	blueprint_compat = false,
	atlas = "jokers",
	loc_vars = function(self, info_queue, center)
		return {vars = {center.ability.extra.perDollar, center.ability.extra.handSize, center.ability.extra.handSizeMax}}
	end,
	calculate = function(self, card, context)
		if context.first_hand_drawn and not context.blueprint then
			local oldMax = card.ability.extra.handSize
			card.ability.extra.handSize = math.max(0, math.min(math.floor((G.GAME.dollars) / card.ability.extra.perDollar), card.ability.extra.handSizeMax))
			if card.ability.extra.handSize ~= oldMax then
				G.hand:change_size(card.ability.extra.handSize - oldMax)
			end
		end
	end
})

-- Swift Storm, Swift End
table.insert(stuffToAdd, {
	object_type = "Joker",
	name = "swiftStorm",
	key = "swiftStorm",
	config = {extra = {handSize = 0, handSizeBuff = 7}},
	pos = {x = 4, y = 2},
	loc_txt = {
		name = 'Swift Storm, Swift End',
		text = {
			"每回合{C:attention}最后一次{}出牌前",
			"手牌上限{C:attention}+#1#"
		}
	},
	rarity = 2,
	cost = 6,
	discovered = true,
	blueprint_compat = false,
	atlas = "jokers",
	loc_vars = function(self, info_queue, center)
		return {vars = {center.ability.extra.handSizeBuff}}
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.joker_main or context.debuffed_hand then
			if G.GAME.current_round.hands_left == 1 then
				if card.ability.extra.handSize == 0 then
					card.ability.extra.handSize = card.ability.extra.handSizeBuff
					G.hand:change_size(card.ability.extra.handSize)
				end
			else
				G.hand:change_size(-card.ability.extra.handSize)
				card.ability.extra.handSize = 0
			end
		end
		
		if context.end_of_round and not context.individual and not context.repetition
		and not context.blueprint then
			G.hand:change_size(-card.ability.extra.handSize)
			card.ability.extra.handSize = 0
		end
	end
})

-- Flames Apart, Foes Aflame
table.insert(stuffToAdd, {
	object_type = "Joker",
	name = "flamesApart",
	key = "flamesApart",
	config = {extra = {}},
	pos = {x = 5, y = 2},
	loc_txt = {
		name = 'Flames Apart, Foes Aflame',
		text = {
			"打出{C:attention}同花顺{}或{C:attention}秘密牌型{}时",
			"抽取牌组中的{C:dark_edition}所有卡牌"
		}
	},
	rarity = 3,
	cost = 7,
	discovered = true,
	blueprint_compat = false,
	atlas = "jokers",
	loc_vars = function(self, info_queue, center)
		return {vars = {}}
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint and 
		(next(context.poker_hands['Straight Flush']) or next(context.poker_hands['Five of a Kind']) or
		next(context.poker_hands['Flush House']) or next(context.poker_hands['Flush Five']))  then
			local toDraw = #G.deck.cards
			for i=1, toDraw do
				draw_card(G.deck,G.hand, i*100/toDraw ,true, card , nil, 0.07)
				G.E_MANAGER:add_event(Event({func = function() card:juice_up(0.3, 0.4) return true end}))
				G.E_MANAGER:add_event(Event({func = function() G.hand:sort() return true end}))
			end
		end
	end
})

-- Black Sky, White Bolt
table.insert(stuffToAdd, {
	object_type = "Joker",
	name = "blackSky",
	key = "blackSky",
	config = {extra = {handSize = 3}},
	pos = {x = 6, y = 2},
	loc_txt = {
		name = 'Black Sky, White Bolt',
		text = {
			"{C:attention}+#1#{} hand size",
			"Debuff all {C:spades}Spades{} and {C:clubs}Clubs{}"
		}
	},
	rarity = 2,
	cost = 7,
	discovered = true,
	blueprint_compat = false,
	atlas = "jokers",
	loc_vars = function(self, info_queue, center)
		return {vars = {center.ability.extra.handSize}}
	end,
	calculate = function(self, card, context)
		if not context.blueprint then
			if context.first_hand_drawn and not self.getting_sliced then
				print("Starting effect")
				for _, v in ipairs(G.deck.cards) do
					if v:is_suit('Spades') or v:is_suit('Clubs') then
						v.debuff = true
						v.ability.blackSkyDebuff = true
					end
				end
			end
		end
		
		if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
			for _, v in ipairs(G.playing_cards) do
				v.ability.blackSkyDebuff = nil
			end
		end
	end
})

return{stuffToAdd = stuffToAdd}