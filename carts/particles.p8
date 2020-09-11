pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- init

-- constants
k_max_p = 1000
k_g = .098
k_start_x = 64
k_start_y = 0

-- arrays to represent particles
--  each index represents 
--  particle data
p_xs = {}
p_prev_xs = {}
p_ys = {}
p_prev_ys = {}
p_dxs = {}
p_dys = {}
p_lifetimes = {}
p_colors = {}

start_x = k_start_x
start_y = k_start_y

function _init() 

	for i=1,k_max_p do
		reset_particle(i)
	end

end

function reset_particle(j)
	p_xs[j] = start_x
	p_prev_xs[j] = start_x
	p_ys[j] = start_y
	p_prev_ys[j] = start_y
	p_dxs[j]=rnd(2)-1 -- -1 to +1
	p_dys[j]=rnd(2)-1
	p_lifetimes[j]=50+rnd(50)
	p_colors[j]=7
end
-->8
-- update

function _update60()
	-- move origin
	if (btn(0) and start_x > 0) start_x -= 1
 if (btn(1) and start_x < 127) start_x += 1
 if (btn(2) and start_y > 0) start_y -= 1
 if (btn(3) and start_y < 127) start_y += 1
	
	for i=1,k_max_p do
		p_prev_xs[i]=p_xs[i]
		p_prev_ys[i]=p_ys[i]
		
		p_xs[i]+=p_dxs[i]
		p_ys[i]+=p_dys[i]
--		p_dxs[i]=rnd(2)-1 -- -1 to +1
		-- apply gravity
		p_dys[i]+=k_g
		p_lifetimes[i]-=.8
		
		if (p_lifetimes[i] <= 0) then
			reset_particle(i)
		end
	end
	
end
-->8
-- draw

function _draw()
	cls()
	
	for i=1,k_max_p do
		if (p_lifetimes[i] > 0) then
		--dot	pset(p_xs[i], p_ys[i], p_colors[i])
		-- line
		line(p_prev_xs[i], 
			p_prev_ys[i],
			p_xs[i],
			p_ys[i],
			p_colors[i])
		end
	end

end
-->8
-- physics


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
