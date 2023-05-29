Menu.Text("------- Gradient ColorBar -------")
Menu.Text("Made by: TTakaTit#9492")
Menu.Text("")

--local rain = Menu.Checkbox("RainBow", false)
local thick = Menu.SliderInt("Thickness", 5, 1, 100)
--local color = Menu.ColorEdit("Color", Color.new(1.0, 1.0, 1.0, 1.0))
local alpha = Menu.SliderFloat("Alpha", 255, 0.0, 255.0)
local speed = Menu.SliderFloat("Speed", 5.0, 1.0, 10.0)

local screen = EngineClient.GetScreenSize()

Cheat.RegisterCallback("draw", function()
	--if rain:Get() == true then 
		--alpha:SetVisible(true)
		--speed:SetVisible(true)
		--color:SetVisible(false)
		local i = alpha:Get()
		local t = thick:Get()
		local realtime = GlobalVars.realtime * speed:Get()
		local r1 = math.floor(math.sin(realtime + 0) * 127 + 128);
		local g1 = math.floor(math.sin(realtime + 4) * 127 + 128);
		local b1 = math.floor(math.sin(realtime + 8) * 127 + 128);
	
		local r2 = math.floor(math.sin(realtime + 12) * 127 + 128);
		local g2 = math.floor(math.sin(realtime + 16) * 127 + 128);
		local b2 = math.floor(math.sin(realtime + 20) * 127 + 128);
	
		local r3 = math.floor(math.sin(realtime + 24) * 127 + 128);
		local g3 = math.floor(math.sin(realtime + 28) * 127 + 128);
		local b3 = math.floor(math.sin(realtime + 32) * 127 + 128);
		
		Render.RectFilledMultiColor(Vector2.new(0, 0), Vector2.new(screen.x, t), Color.RGBA(r2, g2, b2, i), Color.RGBA(r3, g3, b3, i), Color.RGBA(r2, g2, b2, i), Color.RGBA(r1, g1, b1, i))
		
	--else
		--alpha:SetVisible(false)
		--speed:SetVisible(false)
		--color:SetVisible(true)
		--Render.Line(Vector2.new(0,(thick:Get()/2)-1), Vector2.new(screen.x,(thick:Get()/2)-1), Color.new(1,1,1,1),thick:Get())
	--end
end)
