pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- init

k_logo					= 0x0 -- 0000
k_start    = 0x1 -- 1000
k_play     = 0x2 -- 0100
k_over     = 0x4 -- 0010
k_win      = 0x8 -- 0001

k_logo_frames = 12
k_logo_steps = 5 -- time to hold frame

k_max_parts = 100
k_max_part_hp = 100

-- ui
ui = {}
-- disable logo ui.mode = k_logo
ui.mode = k_start
ui.step = k_logo_steps
ui.frame = 0

-- ball -- could we do more than one???
b = {}
b.x = 64
b.y = 64
b.dx = 0
b.dy = -1
b.r = 3
b.c = 10

-- player 1?
p1 = {}
p1.x = 64
p1.y = 3
p1.w = 5 -- half width; will draw on each side of the location
p1.h = 1 -- half height
p1.c = 14

-- particle effects !!!
part_xs    = {}
part_p_xs  = {} -- p = previous
part_ys    = {}
part_p_ys  = {} -- p = previous
part_dxs   = {}
part_dys   = {}
part_hps   = {}
part_index = 1

function _init()

end

function reset_parts()
	for i=1,k_max_parts do
		part_xs[i]    = 0
		part_p_xs[i]  = 0 -- p = previous
		part_ys[i]    = 0
		part_p_ys[i]  = 0 -- p = previous
		part_dxs[i]   = 0
		part_dys[i]   = 0
		part_hps[i]   = 0
	end
end

function fire_next_parts
		(n,init_x,init_y)
	for i=1,n do
		if(part_index>k_max_parts)part_index=1
		
		part_spd = rnd(3)
		part_angle = rnd(1)
		
		part_xs[part_index]    = init_x
		part_p_xs[part_index]  = init_x -- p = previous
		part_ys[part_index]    = init_y
		part_p_ys[part_index]  = init_y -- p = previous
		part_dxs[part_index]   = cos(part_angle)*part_spd
		part_dys[part_index]   = sin(part_angle)*part_spd
		part_hps[part_index]   = 100
		
		part_index+=1
	end
end
-->8
-- update

function _update60()
	if(ui.mode==k_logo)upd_logo()
	if(ui.mode==k_start)ui.mode=k_play
	if(ui.mode==k_play)upd_play()
end
-->8
-- draw

function _draw()
	if(ui.mode==k_logo)drw_logo()
	if(ui.mode==k_play)drw_play()
end


-->8
-- update functions

function upd_play()
	-- update player position
	--  based on key input
	if (btn(⬅️)) then -- moving left
		if (p1.x-p1.w!=0) p1.x-=1
	end
	if (btn(➡️)) then
		if (p1.x+p1.w!=127) p1.x+=1
	end
	if (btn(⬆️)) then -- moving left
		if (p1.y-p1.h!=0) p1.y-=1
	end
	if (btn(⬇️)) then
		if (p1.y+p1.h!=127) p1.y+=1
	end
	
	--run wall collision detection
	if (b.y+b.dy<0 or b.y+b.dy>128) then
		b.c+=1
	 if(b.c==16)b.c=1
	 		
	 b.dy*=-1
	end
	if (b.x+b.dx<0 or b.x+b.dx>127) then
		b.c+=1
	 if(b.c==16)b.c=1
	 		
	 b.dx*=-1	
	end

	--run collision detection
	--simple version 2
	--checking collision with the
	--paddle -- still need to 
	--account for size of ball
	if (b.y+b.dy==p1.y+p1.h) then -- we could be hitting the paddle or missing it
	 if ((p1.x-p1.w)<(b.x+b.dx) 
	 	and (p1.x+p1.w)>(b.x+b.dx)) then
	 		b.c+=1
	 		if(b.c==16)b.c=0
	 		
	 		b.dy*=-1
	 		-- also apply some x velocity
	 		-- based on where the hit happened
	 		-- should switch to using
	 		-- proper vector math / 
	 		-- trigonometry to conserve
	 		-- speed
	 		if(b.x<p1.x)b.dx-=1
	 		if(b.x>p1.x)b.dx+=1
	 		fire_next_parts(25,b.x,b.y)
	 end	
	end
	
	--update ball position
	b.x+=b.dx
	b.y+=b.dy
	
end

function upd_parts()
	for i=1,k_max_parts do
		if (part_hps[i] > 0) then
			part_p_xs[i]  = part_xs[i] -- p = previous
			part_p_ys[i]  = part_ys[i] -- p = previous
			part_xs[i]    += part_dxs[i]
			part_ys[i]    += part_dys[i]
			part_dxs[i]   *= 0.95
			part_dys[i]   *= 0.95
			part_hps[i]   -= 1
		end
	end
end

function upd_logo()
-- run animation timer
		if (ui.step > 0) then
		 ui.step-=1
		else
			ui.step=k_logo_steps
			ui.frame+=1
			-- make it hold at the end
			if (ui.frame==k_logo_frames) ui.step=k_logo_steps*30
		end
		if (ui.frame>k_logo_frames) ui.mode=k_start
end
-->8
-- draw functions

function drw_play()
 camera(0,0)
	cls()
	rect(0,0,127,127,11)
	drw_ball(b)
	drw_player(p1) -- could add p2 from here
end

function drw_ball(ball)
	circfill(ball.x,ball.y,ball.r,ball.c)
end

function drw_player(plr)
	rectfill(plr.x-plr.w,plr.y-plr.h,plr.x+plr.w,plr.y+plr.h,plr.c)
end

function drw_parts()
	for i=1,k_max_parts do
		if (part_hps[i] > 0) then
			color_lookup = ceil(part_hps[i]/20)
			part_color = 2
			if(color_lookup==5)part_color=7
			if(color_lookup==4)part_color=10
			if(color_lookup==3)part_color=9
			if(color_lookup==2)part_color=8
			line(part_p_xs[i],part_p_ys[i],part_xs[i],part_ys[i],part_color)
		end
	end
end

function drw_logo()
 cls()
		if(ui.frame==0 or ui.frame==k_logo_frames) then
		 col=0
		elseif(ui.frame==1 or ui.frame==k_logo_frames-1) then
		 col=5
		elseif(ui.frame==2 or ui.frame==k_logo_frames-2) then
			col=13
		elseif(ui.frame==3 or ui.frame==k_logo_frames-3) then
		 col=6
		else
			col=7
		end
		-- move the logo to the center
		camera(0,0)
		rectfill(0,0,127,127,col)
		-- move the logo to the center
		camera(-10,-40)
		layout_logo_caps()
		layout_logo_x(ui.frame)
		if(ui.frame>6)layout_name(ui.frame)
end

-- logo helper functions
-- draws the capital letters of
--  the pixl logo (pi l) in the
--  upper left
--  note that the spacing
--  between letters is a half
--  'pixel'
function layout_logo_caps()
-- p
	rectfill(0,0,7,8*5-1,2)
	rectfill(8,0,15,7,2)
	rectfill(8,16,15,23,2)
	rectfill(16,8,23,15,2)

-- i	
	rectfill(28,0,51,7,2)
	rectfill(28,8*4,51,8*5-1,2)
	rectfill(36,8,43,8*4-1,2)
	
-- l
 rectfill(84,0,91,8*5-1,2)
 rectfill(92,8*4,107,8*5-1,2)
end

function layout_logo_x(frame)
	if (frame>6) then
		col=3
		if (frame==7) col=6
		if (frame==8) col=11
		
-- x
		rectfill(56,8,63,15,col)
		rectfill(72,8,79,15,col)
		rectfill(64,16,71,23,col)
		rectfill(56,24,63,31,col)
		rectfill(72,24,79,31,col)
	end
end

function layout_name(frame)
	col=6
	if(frame>=7)col=7
	
	print('play & interactive',0,44,col)
	print('  e❎periences for',0,52,col)
	print('  learning lab',0,60,col)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101000001010100000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100010000010000020002000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000000010000000200000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000010000020002000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000001010100000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
