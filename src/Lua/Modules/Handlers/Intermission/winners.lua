local module = {}

local text = FangsHeist.require"Modules/Libraries/text"

module.name = "Winners"

local POSITION_DATA = {
	{x = 160*FU, y = 110*FU, patch = "FH_PODIUM_FIRST"},
	{x = 160*FU-100*FU, y = 120*FU, patch = "FH_PODIUM_SECOND"},
	{x = 160*FU+100*FU, y = 130*FU, patch = "FH_PODIUM_THIRD"}
}

function module.think(p) // runs when selected
end

local profit_sort = function(a, b)
	local profit1 = FangsHeist.returnProfit(a)
	local profit2 = FangsHeist.returnProfit(b)

	return profit1 > profit2
end

local TRIM_LENGTH = 12
local function trim(str)
	if #str > TRIM_LENGTH then
		local trim = string.sub(str, 1, TRIM_LENGTH-3)

		trim = $.."..."

		return trim
	end

	return str
end

function module.draw(v)
	local plyrs = {}

	local width = v.width()*FU/v.dupx()
	local height = v.height()*FU/v.dupy()

	for _,data in pairs(FangsHeist.Net.placements) do
		local placement = data.place
		local p = data.p

		if placement > 3 then continue end
		if not (p and p.valid) then continue end

		plyrs[placement] = p
	end

	if not (#plyrs) then
		text.draw(v,
			width/2,
			height/2 - 21*FU/2,
			FU,
			"NO WINNERS!!",
			"FHFNT",
			"center",
			V_SNAPTOLEFT|V_SNAPTOTOP,
			v.getColormap(nil, SKINCOLOR_CYAN)
		)
		return
	end

	for i = 1,3 do
		if not plyrs[i] then break end

		local p = plyrs[i]
		local pos = POSITION_DATA[i]

		local podium = v.cachePatch(pos.patch)

		local mult = FixedDiv(width, 320*FU)
		local x = FixedMul(pos.x, mult)

		local name = (trim(p.name)):upper()

		local sep = 12*FU
		local width = 0
		local length = 0
		for sp,_ in pairs(p.heist.team.players) do
			if not (sp and sp.valid and sp.heist) then continue end
			length = $+1
			width = $+sep
		end

		local div = length > 1 and width/(length-1) or width/2
		local i = 0

		local podium_scale = FU*6/8
		local podium_wscale = podium_scale + FU*(length-1)/8
		v.drawScaled(x-podium.width*podium_wscale/2, 200*FU-podium.height*podium_scale, podium_wscale, podium, V_SNAPTOBOTTOM|V_SNAPTOLEFT)

		for sp,_ in pairs(p.heist.team.players) do
			if not (sp and sp.mo and sp.valid and sp.heist) then continue end

			local color = v.getColormap(sp.skin, sp.skincolor, ((sp.mo and sp.mo.valid) and sp.mo.translation or nil))
			local scale = skins[sp.skin].highresscale
			local stnd = v.getSprite2Patch(sp.skin, SPR2_STND, false, A, 1)
			local dx = x - width/2 + div*i
			if length <= 1 then
				dx = x
			end

			--[[if length % 2 == 1 then
				dx = x - width + sep*i
			end]]

			v.drawScaled(dx, pos.y, scale*6/8, stnd, V_SNAPTOBOTTOM|V_SNAPTOLEFT, color)

			i = $+1
		end

		local y = pos.y+12*FU
		local f = V_SNAPTOBOTTOM|V_SNAPTOLEFT
		// 21*FU

		if length > 1 then
			text.draw(v,
				x, y,
				FU*6/9,
				"TEAM",
				"FHFNT",
				"center",
				f,
				v.getColormap(nil, p.skincolor))
			y = $+20*(FU*6/9)
		end

		text.draw(v,
			x, y,
			FU*6/9,
			name,
			"FHFNT",
			"center",
			f,
			v.getColormap(nil, p.skincolor))
		y = $+20*FU

		local scale = (FU/3)*2
		local patch = v.cachePatch("FH_PROFIT")

		v.drawScaled(x-patch.width*scale/2, y, scale, patch, f)
		text.draw(v,
			x,
			y+4*FU-9*FU,
			scale,
			"$"..tostring(FangsHeist.returnProfit(p)),
			"PRTFT",
			"center",
			f
		)

		--v.drawString(x, y, "$"..tostring(FangsHeist.returnProfit(p)), V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_GREENMAP, "thin-fixed-center")
	end
end

return module