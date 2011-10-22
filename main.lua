--[[
Copyright © 2011 Andy Fraley (andrew.fraley@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local physics = require( "physics" )
physics.start()
physics.setScale( 20 )
physics.setDrawMode( "hybrid" ) 


main_radius = 110
cx = 160
cy = 240
bullet_radius = 5
local cr = 20
local main_circle = display.newCircle(cx, cy, main_radius)
local center_circle = display.newCircle(cx, cy, cr)
player_angle = 90
angle_increments = 30
psize = 20
lives = 3
score = 0
enemy_score = 50
lives_text = display.newText( "Lives: " .. lives, display.contentWidth - 70, 30, "Helvetica", 16 )
lives_text:rotate (90)

score_text = display.newText( "Score: " .. score, display.contentWidth - 70, 100, "Helvetica", 16 )
score_text:rotate (90)

center_circle:setFillColor(0, 0, 0)
main_circle:setFillColor(18, 12, 204)




local r_button = display.newImage( "right-button.png" )
r_button.x = display.contentWidth / 2 + 100
r_button.y = display.contentHeight - 50
r_button:addEventListener("tap", r_button)

function r_button:tap( event )
	move_player(false)
end --r_button tap

local l_button = display.newImage( "left-button.png" )
l_button.x = display.contentWidth / 2 - 100
l_button.y = display.contentHeight - 50
l_button:addEventListener("tap", l_button)

function l_button:tap( event )
	move_player(true)
end --r_button tap

local fire_button = display.newImage( "fire-button.png" )
fire_button.x = display.contentWidth / 2 
fire_button.y = 50
fire_button:addEventListener("tap", fire_button)

function fire_button:tap( event )
	fire()
end --r_button tap

function fire()
	center_angle = player_angle + angle_increments / 2
	local start_rad = math.rad(center_angle + 1);
	local r = main_radius + psize - 5
	local start_x = cx + r * math.sin(start_rad)
	local start_y = cy - r * math.cos(start_rad)
	
	local end_x = cx + cr * math.sin(start_rad)
	local end_y = cy - cr * math.cos(start_rad)
	
	local bullet = display.newCircle(start_x, start_y, bullet_radius)
	
	bullet:setFillColor(255,0,0)
	bullet.myName = "bullet"
	physics.addBody( bullet, {radius = bullet_radius / 2})
	bullet.collision = onLocalCollision
	bullet:addEventListener( "collision", bullet )
	transition.to( bullet, { time=1500, xScale = .1, yScale = .1, x=(end_x), y=(end_y), onComplete= function () bullet:removeSelf() end} )

end --fire



function move_player(direction)
	if (direction) then
		player_angle = player_angle + angle_increments
		if player_angle > 360 then player_angle = player_angle - 360 end
		player:rotate(angle_increments)
		
	else 
		player_angle = player_angle - angle_increments
		if (player_angle < 0) then player_angle = player_angle + 360 end
		player:rotate(360 - angle_increments)
		
	end -- if direction
	local r = main_radius
	local start_rad = math.rad(player_angle + 1);
	local start_x = cx + r * math.sin(start_rad)
	local start_y = cy - r * math.cos(start_rad)
	player.y = start_y
	player.x = start_x
	--player:removeSelf()
	--player = drawplayer(main_radius, cx, cy, player_angle)
	
end -- move_player


local function drawline(angle, main_radius, cx, cy, cr)
	local r = main_radius
	local start_rad = math.rad(angle + 1);
	local end_x = cx + r * math.sin(start_rad)
	local end_y = cy - r * math.cos(start_rad)
	
	local start_x = cx + cr * math.sin(start_rad)
	local start_y = cy - cr * math.cos(start_rad)
	
	local segment = display.newLine(start_x,start_y, end_x, end_y ) 
	return segment
	
end -- drawline

for i = 1, 12 do
	drawline(i * 30, main_radius, cx, cy, cr)
end -- for i

function drawplayer(main_radius, cx, cy, angle) 
	local r = main_radius
	
	local start_rad = math.rad(angle + 1);
	local end_rad = math.rad(angle + 16);
	
	local start_x = cx + r * math.sin(start_rad)
	local start_y = cy - r * math.cos(start_rad)
	
	local end_x = cx + (r + psize) * math.sin(end_rad)
	local end_y = cy - (r + psize) * math.cos(end_rad)
	local player = display.newLine(start_x,start_y, end_x, end_y ) 
	
	start_rad = math.rad(angle + 31);
	start_x = cx + r * math.sin(start_rad)
	start_y = cy - r * math.cos(start_rad)
	
	--local player2 = display.newLine(start_x,start_y, end_x, end_y ) 
	--player:append(start_x,start_y, end_x, end_y ) 
	player:append(start_x,start_y) 
	player:setColor(255, 0, 0)
	player.width = 5
	
	local squareShape = { 0, 0, 25, 40, -12, 55 }
	
	
	physics.addBody ( player, "static", {shape=squareShape} )
	player.myName = "player"
	player.collision = onLocalCollision
	player:addEventListener( "collision", player )
	return player
end -- drawplayer

function draw_enemy ()
	local eangle =  (math.random(12) * angle_increments)
	local center_angle = eangle - (angle_increments / 2)
	local start_rad = math.rad(center_angle + 1);
	local r = main_radius + psize - 5
	local end_x = cx + r * math.sin(start_rad)
	local end_y = cy - r * math.cos(start_rad)
	local enemy = display.newCircle(cx, cy, 1)
	enemy.angle = eangle - angle_increments
	enemy:setFillColor(0,255,0)
	random_time = math.random(20) * 350
	physics.addBody( enemy, {radius = bullet_radius / 2} )
	enemy.collision = onLocalCollision 
	enemy:addEventListener( "collision", enemy )
	enemy.myName = "enemy"
	transition.to( enemy, { time=random_time, xScale = 7, yScale = 7, x=(end_x), y=(end_y), onComplete= function () enemy:removeSelf() draw_enemy() end} )
	enemy.dead = 0
	return enemy
end --draw_enemy


player = drawplayer(main_radius, cx, cy, player_angle)
enemy1 = draw_enemy()
enemy2 = draw_enemy()
enemy3 = draw_enemy()


function onLocalCollision( self, event )
	if ( event.phase == "began" ) then

		if (self.myName ~= event.other.myName) and (self.myName ~= "player" and self.myName ~= "bullet")  then
			--print( self.myName .. ": collision began with " .. event.other.myName )
			if (self.myName == "bullet" or event.other.myName == "bullet") then
				if (self.myName == "enemy" and event.other.alpha == 1 and self.alpha == 1) then
					self.alpha = 0
					event.other.alpha = 0
					score = score + enemy_score
					score_text.text = "Score: " .. score
					print ("enemy dead")
					
				else
					
				
				end
			elseif (self.myName == "player" and event.other.myName == "enemy") or  (self.myName == "enemy" and event.other.myName == "player") then
				if (self.myName == "enemy" and event.other.alpha == 1 and self.alpha == 1) then
						print (player_angle .. "  " .. self.angle)
						if (player_angle == self.angle or player_angle - self.angle == 360 or player_angle + self.angle == 360) then
							self.alpha = 0
							print ("collision with live enemy")
							lives = lives - 1
							lives_text.text = "Lives: " .. lives
						end
				
				else
					
				
				end
			end
		end

	end
end


local function onGlobalCollision ( event )
	if ( event.phase == "began" ) then

		print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision began" )

	elseif ( event.phase == "ended" ) then

		print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision ended" )

	end
	
	print( "**** " .. event.element1 .. " -- " .. event.element2 )
end
--Runtime:addEventListener( "collision", onGlobalCollision )