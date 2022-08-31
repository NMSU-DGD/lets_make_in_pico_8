pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- init

-- constants
k_gravity = 0.1
k_walk_rate = 0.08
k_jump_rate = 0.8
k_epsilon = 0.01
k_max_anim_count = 29 --in frames

-- anim
anim_count=0

-- initialize player table
player={x=64,y=64}
player.dx=0
player.dy=0
player.x_prev=player.x
player.y_prev=player.y
player.mode = 0 -- 0: standing, 1: ball
player.frame = 1
player.max_jump_pwr = 8
player.jump_pwr = player.max_jump_pwr
player.resting = false
player.varia = false

function _init()
	cls()
	
--	palt(1, true) -- dark blue is transparent
--	palt(0, false) -- black is visible
end



-->8
-- update
function _update60()
--do animation updates 
-- move to draw?
	anim_count+=1
	if anim_count == k_max_anim_count then
		anim_count=0
		player.frame += 1
		if (player.frame == 3) player.frame=1 
	end

--respond to button presses
--left
	if (btn(0)) then 
		player.dx -= k_walk_rate
		player.face = 1
	end
	
--right
	if btn(1) then
		player.dx += k_walk_rate
		player.face = 0
	end

--up
	if (player.mode == 1) then
		if (btnp(2)) player.mode = 0 
	  -- stand
	else
		if btn(2) then
			--jump button down
		 if (player.jump_pwr > 0) then -- jump
				player.dy -= k_jump_rate
				player.jump_pwr -= 1
			end
		elseif (player.dy >= 0 
				or player.jump_pwr < 
				player.max_jump_pwr) then
			--jump button released or not down
			player.jump_pwr = 0 -- no more jumping after you release the key!
		end
	end
	
--down	
	if (btn(3) and player.mode == 0) then -- up
	 player.mode = 1
	end
	
--apply gravity
	player.dy+=k_gravity
	
--do collision det / resp
	--handle for standing
	if (player.mode == 0) then
		if map_hit(player.x+player.dx,
				player.y,7,7,0x40+0x80) then
			player.dx=0
		end
		if map_hit(player.x,
				player.y+player.dy,7,7,0x40+0x80) 
				then
			if (player.dy>0) player.resting=true
			player.dy=0
		end
		if map_hit(player.x+player.dx,
		  player.y+player.dy,7,7,0x40+0x80)
		  then
		  -- check diagonal as well
		 player.dx=0
		 player.dy=0
		end
	else
	 -- handle for ball mode
	 --  in ball mode, the avatar
	 --  is half-height and 
	 --  centered on x
	 if map_hit(player.x+2+player.dx,
				player.y+4,3,3,0x40) then
			player.dx=0
		end
		if map_hit(player.x+2,
				player.y+4+player.dy,3,3,0x80) 
				then
			if (player.dy>0) player.resting=true
			player.dy=0
		end
		if map_hit(player.x+2+player.dx,
		  player.y+4+player.dy,3,3,0x80)
		  then
		  -- check diagonal as well
		 player.dx=0
		 player.dy=0
		end
	end

	if (player.dy != 0) then
		player.resting = false
	end
	
	if (player.resting) then
		player.jump_pwr=player.max_jump_pwr
		player.dx *= 0.95
		if (abs(player.dx)<k_epsilon) player.dx=0
	end	
	
--run velocity simulation
	player.x += player.dx
	player.y += player.dy
end
-->8
-- draw
function _draw()
	cls() -- this is probably expensive

	cam_x=player.x-64
	cam_y=player.y-64
	camera(cam_x,cam_y)

	map(0,0,0,0,32,128)
		
	-- 1 if left, which is - vel
	-- 2 if right, which is + vel
	-- 0 if middle, 0 vel
	if (player.dx < 0) then
		face = 1
	elseif (player.dx > 0) then
		face = 2
	else
		face = 0
	end
	
	pal()
	if (player.varia) varia_swap()
	
	spr(
			(player.mode*3*8)
			+ (face*8)
			+ player.frame,
			player.x,
			player.y)
	
	player.x_prev = player.x
	player.y_prev = player.y
	
	-- draw foreground decorations
	map(0,0,0,0,32,128,16)
end
				
-->8
-- collisions

function check_resting(x,y)
	--check below for ground
	if (player.y%8 == 0) then --maybe resting on a tile
		cell_y = flr(y/8)
		cell_x_c = ceil(x/8)
		cell_x_f = flr(x/8)
		
		m_below_c = mget(cell_x_c, cell_y+1)
		m_below_f = mget(cell_x_f, cell_y+1)

	-- does it block from below 
	--  and are we resting on it?
		return (fget(m_below_c,6) or 
				fget(m_below_f,6))
	end
	
	return false
end

-- determine if a rectangle with
--  upper-left x,y and size w,h
--  collides with a map tile
--  with the specified flag
-- extended from: http://gamedev.docrobs.co.uk/first-steps-in-pico-8-easy-collisions-with-map-tiles
function map_hit(x,y,w,h,f,mx,my,mw,mh)
	mx = mx or 0
	my = my or 0
	mw = mw or 8
	mh = mh or 8

	for i=x,x+w do
		if (fget(mget(i/8,y/8)) & 
				f > 0) 
				or
				(fget(mget(i/8,(y+h)/8)) & 
				f > 0) then
			return true
		end		
	end
	
	for j=y,y+h do
		if (fget(mget(x/8,j/8)) & 
				f > 0) or
				(fget(mget((x+w)/8,j/8)) &
			 f > 0) then
			return true
		end
	end
	
	return false	
end										
-->8
-- draw helpers

function varia_swap()
	pal(8,14)
	pal(9,2)
	pal(4,13)
	pal(10,7)
end
-->8
-- pickup

function get_item(x,y)
-- tile at x,y must be an item
-- this function identifies it
-- sets appropriate values in
-- player, then replaces the
-- sprite on the map

item = mget(x/8,y/8)
end
__gfx__
000000000088820000e8820000000000000000000000000000000000000000000000000000888200008882000000000000000000000000000000000000000000
0000000007b8bb200778bb200000000000000000000000000000000000000000000000000b8bb8200b8bb8200000000000000000000000000000000000000000
007007000bbbbb2007bbbb200000000000000000000000000000000000000000000000000bbbb8200bbbb8200000000000000000000000000000000000000000
00077000088188440881884400000000000000000000000000000000000000000000000008188494081884940000000000000000000000000000000000000000
0007700077c4449477c444940000000000000000000000000000000000000000000000007c444994074449940000000000000000000000000000000000000000
00700700ddc949007dc94900000000000000000000000000000000000000000000000000dc9499000d9994000000000000000000000000000000000000000000
00000000004444000044440000000000000000000000000000000000000000000000000000444400004444000000000000000000000000000000000000000000
00000000002008000020080000000000000000000000000000000000000000000000000000200800000280000000000000000000000000000000000000000000
00000000008882000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000887b8300887b83000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088bbb30088bbb3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000994881209948812000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009777c44099777c40000000000000000000000000000000000000000000000000000aa000000aa0000000000000000000000000000000000000000000
000000000cccd90409cccd4000000000000000000000000000000000000000000000000000a8840000a784000000000000000000000000000000000000000000
00000000004444000044440000000000000000000000000000000000000000000000000000a9940000a994000000000000000000000000000000000000000000
00000000008002000008200000000000000000000000000000000000000000000000000000044000000440000000000000000000000000000000000000000000
0c0000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c77c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007e2d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00722d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cdd100000aa000000aa000000000000000000000000000000000000000000000000000000aa000000aa0000000000000000000000000000000000000000000
0c00001000a8940000a9940000000000000000000000000000000000000000000000000000a9940000a984000000000000000000000000000000000000000000
0000000000a9940000a8940000000000000000000000000000000000000000000000000000a9840000a994000000000000000000000000000000000000000000
00000000000440000004400000000000000000000000000000000000000000000000000000044000000440000000000000000000000000000000000000000000
0aa0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00990009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000990a9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00089999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00098999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa99999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88880888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666d666d666d666d666d666d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccd6ccd6ccd6ccd6ccd6ccd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccd6ccd6ccd6ccd6ccd6ccd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666d666d000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccd6ccd000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccd6ccd000000002000200200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd000000002020200200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000009444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000094444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000094409400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000eee0094400400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000e000e044444990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000e000e004440009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000e000e094444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000eee0094444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000220044444000004000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000e000220004444400000944000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002002220004444440099440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e000000000000002202220e00444444944400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e02000000020e00202200200444404444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e00200002002e0e0222200209449990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02002020020020e002220e0294994444990009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22002020022020202220020244444004444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
00c0c0000000000000c0c0000000000000c0c0000000000000808000000000000380800000000000008080000000000003000000000000000000000000000000c141410000000000000000000000000000000000000000000000000000000000000010c1000000000000000000000000101010c1c10000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000004000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000040000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000040000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000004000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000400000000000000000004000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000040000000000000000000004000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000004000004141414141410000404000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4062000000000000000000000040004062000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4072707071000071000071717072704272000071000070000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040400000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000400000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000400000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000400000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000400000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000400000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000400000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003a05000000340502c0502705022050200501c0501a0501805016050140501205011050000000f0500d0500c0500c05010050160501c0502405000000000000000023050230502b050000000000000000
