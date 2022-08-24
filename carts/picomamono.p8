pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- init

-- constants
k_max_w = 25
k_max_h = 24

k_xp_vals = {1,2,3,4,5} -- xp values
k_max_lvl = 5

k_mine 	   = 0x1 -- 1000 
k_covered  = 0x2 -- 0100
k_flagged 	= 0x4 -- 0010

k_start    = 0x1 -- 1000
k_play     = 0x2 -- 0100
k_over     = 0x4 -- 0010
k_win      = 0x8 -- 0001

k_p_spr = 33
k_p_spr_max = 7

k_size = 5

-- board
w = k_max_w
h = k_max_h
mons = {1,1,1,1,1}
num_clear = 0
board = {} --board state
count_board = {} --precount monster levels
mon_board = {} --monster values
flag_board = {} -- player flag states
need_board = true

-- drawing
x_offset = 2
y_offset = 5

-- location marker
p = {}
p.x = 1
p.y = 1
p.lvl = 1
p.xp = 0
p.anim = 0
p.anim_dir = 1
p.targ_x = 0 -- offset for
p.targ_y = 0 -- movement dir

-- ui
ui = {}
ui.mode = k_start
ui.menu_item = 0

-- save ids
k_save_name  = "ztoups_picomamano_0_1"
k_save_first = 0
k_save_n_1   = 1
k_save_n_2			= 1
k_save_n_3			=	1
k_save_n_4			= 1
k_save_n_5			= 1
k_save_w     = 2
k_save_h     = 3

function _init()
	cartdata(k_save_name)

	if (dget(k_first) == 0) then
	-- initialize save
		dset(k_first,1)
		save_prefs()
	else
	-- load save
		load_prefs()
	end
	
	reset()
end

function reset()
	need_board = true
	empty_board()

	empty_player()

	ui.mode = k_start
	ui.menu_item = 0
end

function reset_player()
	p.x=1
	p.y=1
	p.lvl = 1
	p.xp = 0
	p.anim = 0
	p.anim_dir = 1
	p.targ_x = 0 -- offset for
	p.targ_y = 0 -- movement dir
end

function empty_board()
	num_clear = 0
	for i=1,w do
		board[i]={}
		count_board[i]={}
		mon_board[i]={}
		flag_board[i]={}
		for j=1,h do
			board[i][j]=k_covered
			count_board[i][j]=0
			mon_board[i][j]=0
			flag_board[i][j]=0
		end
	end
end

-- uses w, h, and num_mines 
--  to place mines on the board.
--  first_x and first_y indicate
--  where the player clicked
--  so that the algorithm can
--  skip that location.
function layout(first_x, 
		first_y)
		
	clear(first_x,first_y)
	
	lvl_placed = 0
	m_placed = 0
	m_chance=num_mines/w

	while m_placed < num_mines do
		-- place all the mines
		-- determine % chance of a
		-- mine in a column
		for i=1,w do
			-- on each col, randomly
			--  place one if %
			if (rnd(1)<=m_chance) then
				-- try to find a row
				target_row = flr(rnd(h))+1

				if (board[i][target_row] 
						== k_covered) then
					board[i][target_row] |= k_mine
					m_placed+=1
				end 
			end

			printh('placed '..m_placed..' of '..num_mines)

			if (m_placed == num_mines) break
		end
	end
	
	-- now create the count board
	for i=1,w do
		for j=1,h do
			--count adjacent mines
			count_x = max(1,i-1)
			count_y = max(1,j-1)
			count_x_end = min(w,i+1)
			count_y_end = min(h,j+1)
			
			count = 0;
			if (board[i][j] & k_mine == k_mine) count-=1
			for k=count_x,count_x_end do
				for l=count_y,count_y_end do
				 if (board[k][l] & k_mine == k_mine) then
				 	count += 1
				 end
				end
			end
			
			count_board[i][j] = count
		end
	end
	
	need_board = false
end
-->8
-- update

function _update60()
	if ui.mode==k_start then
		upd_start()
	elseif ui.mode==k_play then
		upd_game_run()
	elseif ui.mode==k_over or ui.mode==k_win then
		upd_game_end() -- just the one function
	end
end
-->8
-- draw

function _draw()
	if ui.mode==k_start then
		draw_start()
	elseif ui.mode==k_play then
		draw_game_run()
	elseif ui.mode==k_over then
		draw_game_over()
	else -- (ui.mode == k_win) 
		draw_win()
	end
end
-->8
-- utility

function sign(n)
	return n<0 and -1 or n>0 and 1 or 0
end
-->8
-- clearing

function clear(ax,ay)
	board[ax][ay] &= ~k_covered
	num_clear += 1	
end

-- this will be super inefficent
--  assumes current location is
--  already safe when called
function autoclear(ax,ay) 
	printh('starting for autoclear: '..ax..', '..ay)
	
	if ((ax == 0) or 
			(ax > w) or 
			(ay == 0) or 
			(ay > h)) then
		printh('ac returning out of bounds')
		return
	end
	
	if (board[ax][ay] & k_covered == 0) then
		return
	end
	
	clear(ax,ay)
	
	if (count_board[ax][ay] == 0) then
		autoclear(ax,  ay+1) --d
		autoclear(ax-1,ay+1) --dl
		autoclear(ax-1,ay)   --l
		autoclear(ax-1,ay-1) --ul
		autoclear(ax,  ay-1) --u
		autoclear(ax+1,ay-1) --ur
		autoclear(ax+1,ay)   --r
		autoclear(ax+1,ay+1) --d
	end
--	end
end
-->8
-- display screens

function draw_start()
	cls()
	
	map(0,0,0,0,16,16)
	print('sweeper',16,50,7)
	
	-- menu items
	print('start',16,70,7)
	print('# mines: ⬅️'..num_mines..'➡️',16,78,7)
	print('  width: ⬅️'..w..'➡️',16,86,7)
	print(' height: ⬅️'..h..'➡️',16,94,7)

	-- draw menu item indicator
	if (ui.menu_engage) then
		spr(43,8,70+(ui.menu_item*8))
	else
		spr(42,8,70+(ui.menu_item*8))
	end
end

function draw_game_run()
	cls()
	
	-- main loop 
	-- draw board
	for i=1,w do
		for j=1,h do
			spr_x = ((i-1)*5)+x_offset
			spr_y = ((j-1)*5)+y_offset
	--		print('i'..i..'j'..j,0,0)
				-- draw covered
			if (board[i][j] 
					& k_flagged == k_flagged) then
				spr(36,spr_x,spr_y)	-- draw covered
			elseif (board[i][j] 
					& k_covered == k_covered) then
				spr(33,spr_x,spr_y)
			elseif (board[i][j] 
					& k_mine == k_mine) then
					-- not covered & mine
		 	spr(35,spr_x,spr_y)
			else
				-- not covred & no mine
				if count_board[i][j] > 0 then
					spr(count_board[i][j],spr_x,spr_y)
				else
					spr(34,spr_x,spr_y)
				end
			end
		end
	end
	
	-- draw player marker
	spr(49+p.anim,
			((p.x-1)*5)-1
			+x_offset
			-p.targ_x,
			((p.y-1)*5)-1
			+y_offset
			-p.targ_y)
	
	p.anim += p.anim_dir
	if p.anim == k_p_spr_max or p.anim==0 then 
		p.anim_dir *= -1
	end
end

function draw_reset()
	print('restart',16,70,7)
	spr(42,8,70+(ui.menu_item*8))
end

function draw_game_over()
	print('game over!',16,50,7)
	draw_reset()
end

function draw_win()
	print('you win!',16,50,7)
	draw_reset()
end
-->8
-- interaction modes

function upd_start()
	-- start game!
	if btnp(2) then
		--up
  ui.menu_item -= 1
  if (ui.menu_item==-1) ui.menu_item=3
	elseif btnp(3) then 
		--down
  ui.menu_item += 1
  if (ui.menu_item==4) ui.menu_item=0
	elseif btnp(4) then
	 --o
	 -- start!
		if (ui.menu_item==0) ui.mode=k_play
	end
	 
	if (ui.menu_item!=0) then
		-- manipulating a setting
		if (ui.menu_item == 1) then --num_mines		
			if btnp(0) then
				num_mines -= 1
				if (num_mines==0) num_mines+=1
			elseif btnp(1) then
				num_mines += 1
				if (num_mines==(w*h)) num_mines-=1
			end
		elseif (ui.menu_item == 2) then
			if btnp(0) then
				w -= 1				
				if (w==0 or (w*h < num_mines)) then
				 w+=1
				end		
			elseif btnp(1) then
				w += 1
				if (w==k_max_w) w-=1
			end
		elseif (ui.menu_item == 3) then
			if btnp(0) then
				h -= 1	
				if (h==0 or (w*h < num_mines)) then
				 h+=1
				end		
			elseif btnp(1) then
				h += 1
				if (h==k_max_h) h-=1
			end
		end
		save_prefs() -- save any changes
	end
end

function upd_game_run()
	if (num_clear == ((w*h)-num_mines)) then
		ui.mode = k_win
	end
	if (btnp(4)) then
 	if need_board then
 		-- can't run until player
 		--  clicks a space!
 		layout(p.x,p.y)
		end
		
		if (board[p.x][p.y] & 
		  k_flagged != k_flagged) then
		
			if (board[p.x][p.y] & k_mine == k_mine) then
			 -- todo game over
			 clear(p.x,p.y)
			 ui.mode = k_over
			elseif (count_board[p.x][p.y] 
					== 0) then
				autoclear(p.x,p.y)
			else
				clear(p.x,p.y)
			end
		end
	elseif (btnp(5)) then
		board[p.x][p.y] ^^= k_flagged
	elseif (p.targ_x == 0 and p.targ_y == 0) then
		if (btnp(0) and p.x > 1) then
		 p.x -= 1
		 p.targ_x -= k_size
	 end
	 if (btnp(1) and p.x < w) then 
	 	p.x += 1
	 	p.targ_x += k_size
	 end
	 if (btnp(2) and p.y > 1) then
	  p.y -= 1
	  p.targ_y -= k_size
	 end
	 if (btnp(3) and p.y < h) then
	  p.y += 1
	  p.targ_y += k_size
	 end
	else
		p.targ_x = (abs(p.targ_x)-1)*sign(p.targ_x)
		p.targ_y = (abs(p.targ_y)-1)*sign(p.targ_y)
	end
end

function upd_game_end()
	if (btnp(4)) reset()
end
-->8
-- data manipulation

function save_prefs()
	dset(k_save_n_1,mon[1])
	dset(k_save_n_2,mon[2])
	dset(k_save_n_3,mon[3])
	dset(k_save_n_4,mon[4])
	dset(k_save_n_5,mon[5])
	dset(k_save_w,w)
	dset(k_save_h,h)
end

function load_prefs()
	mon[1]=dget(k_save_n_1)
	mon[2]=dget(k_save_n_2)
	mon[3]=dget(k_save_n_3)
	mon[4]=dget(k_save_n_4)
	mon[5]=dget(k_save_n_5)
	w=dget(k_save_w)
	h=dget(k_save_h)
end
__gfx__
0000000000800000099000000aa00000000b00000333000000cc00000222000000e000000666000080070000080200008099000080aa00008000b00080333000
000000000080000000090000000a00000b0b0000030000000c000000000200000e0e0000060600008070700008020000800090008000a00080b0b00080300000
00700700008000000090000000a000000bbb0000003000000cc000000002000000e0000006660000807070000802000080090000800a000080bbb00080030000
000770000080000009000000000a0000000b0000000300000c0c0000000200000e0e0000000600008070700008020000809000008000a0008000b00080003000
0007700000800000099900000aa00000000b00000330000000c000000002000000e000000006000080070000080200008099900080aa00008000b00080330000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
800cc00080222000800e000080666000990700009900800099440000000000000000000000000000000000000000000000000000000000000000000000000000
80c000008000200080e0e00080606000009070000090800000904000000000000000000000000000000000000000000000000000000000000000000000000000
80cc000080002000800e000080666000097070000900800009040000000000000000000000000000000000000000000000000000000000000000000000000000
80c0c0008000200080e0e00080006000907070009000800090400000000000000000000000000000000000000000000000000000000000000000000000000000
800c000080002000800e000080006000999700009990800099944000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777770001111c0001aa1500072eee00000000000777777775555555c22eeeeee00000000c00000000090000000000000000000000000000000000000
00000000766650001111c000a88a500072eee00000000000766666655111111c22eeeeee00000000cc0000000099000000000000000000000000000000000000
00000000766650001111c000a88a500072eee00000000000766666655111111c22eeeeee00000000ccc000009999900000000000000000000000000000000000
00000000766650001111c0001aa150007266500000000000766666655111111c22eeeeee00000000cc0000000099000000000000000000000000000000000000
0000000075555000ccccc000555550007255500000000000766666655111111c2200000000000000c00000000090000000000000000000000000000000000000
000000000000000000000000000000000000000000000000766666655111111c2200000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000766666655111111c2200000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000075555555cccccccc2200000000000000000000000000000000000000000000000000000000000000
00000000111111101112111011222110122222102222222022212220221112202111112000000000000000000000000000000000000000000000000000000000
00000000100000101000001010000010200000202000002020000020200000201000001000000000000000000000000000000000000000000000000000000000
00000000100000101000001020000020200000202000002020000020100000101000001000000000000000000000000000000000000000000000000000000000
00000000100000102000002020000020200000202000002010000010100000101000001000000000000000000000000000000000000000000000000000000000
00000000100000101000001020000020200000202000002020000020100000101000001000000000000000000000000000000000000000000000000000000000
00000000100000101000001010000010200000202000002020000020200000201000001000000000000000000000000000000000000000000000000000000000
00000000111111101112111011222110122222102222222022212220221112202111112000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808000090900000a0a0a00008b00000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08880000898090000a0a0000bbb0b000300830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
808080009990900008a8000000bb0000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888800009009000a0a0a0000bbb0000033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0888000000990000a0a0a000b0b0b000303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2626000026262600002600000026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2600260000260000260026002600260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2626000000260000260000002600260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2600000000260000260026002600260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2600000026262600002600000026000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
