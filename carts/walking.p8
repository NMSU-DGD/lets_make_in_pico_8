pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- init

k_logo					= 0x0 -- 0000
k_start    = 0x1 -- 1000
k_play     = 0x2 -- 0100

k_friction = 0.90
k_impulse_inc = 0.55
k_epsilon = 0.000001

-- ui
ui = {}
-- disable logo ui.mode = k_logo
ui.mode = k_play
ui.step = k_logo_steps
ui.frame = 0

pika = {}
pika.x = 2
pika.y = 2
pika.dir=0
pika.spr=1

function _init()

end

-->8
-- update

function _update60()
	if btn(⬇️) then 
		pika.y=pika.y+1
		pika.spr=1 
	end
	if btn(➡️) then
		pika.x=pika.x+1
		pika.spr=1
	end
	if btn(⬅️) then
		pika.x=pika.x-1
		pika.spr=2
	end
	if btn(⬆️) then
		pika.y=pika.y-1
		pika.spr=3
	end
	if btn(❎) then
		
	end
end
-->8
-- draw

function _draw()
--	if(ui.mode==k_logo)drw_logo()
	if(ui.mode==k_play)drw_play()
end


-->8
-- update functions

function upd_play()
	
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

-- returns 1 if lines intersect
--  0 if not. from:
--  https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
function line_seg_intersect(
		p0x,p0y,p1x,p1y,p2x,p2y,p3x,p3y)
	
	s1x=p1x-p0x;
	s1y=p1y-p0y;
	
	s2x=p3x-p2x;
	s2y=p3y-p2y;
	
	s=(-s1y*(p0x-p2x)+s1x*(p0y-p2y))/(-s2x*s1y+s1x*s2y)
	t=( s2x*(p0y-p2y)-s2y*(p0x-p2x))/(-s2x*s1y+s1x*s2y)

	if (s>=0 and s<=1 and t>=0 and t<=1) then
		return true
	else
		return false
	end		
end
-->8
-- draw functions

function drw_play()
 camera(0,0)
	cls()
	
	drw_pika()
end

function drw_pika()
	spr(pika.spr,pika.x,pika.y)
end

function drw_scores()
	print(p1.s,2,2,p1.c)
	print(p2.s,123,121,p2.c)
end

function drw_ball(ball)
	circfill(ball.x,ball.y,ball.r,ball.c)
end

function drw_player(plr)
	rectfill(plr.x-plr.w,plr.y,plr.x+plr.w,plr.y,plr.c)
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

function drw_win(plr)
	cls()
	
	print('congratulations player '..plr.name,0,44,plr.c)
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
0000000000a90009aa00900000a90009aa0090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aaaa9aaa99000000aaaa9aaa990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700990a0aa00aa09044990aaaa9aaa990440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770009908aaa9aaa98044990aaaa9aaa990440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000090a999009999040090a9990099990400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070009a9a9a00a9a994009a9a9a00a9a99400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a944900900990000a94490090099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbb0006777777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bb8b3007677771500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbb33307766615500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbb33207766615500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008b3332307766615500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000033333007761115500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004440007655551500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004440006555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000021220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000021212100000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200000000000000000000210000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200210000000000000000000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000