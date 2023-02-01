pico-8 cartridge // http://www.pico-8.com
version 39
__lua__


function _init()

	coin_i={1,gen_anim({16,17,18,19},{4,3,3,3})}
	ply=player(5,50)
	level=gen_map()
	hup={
		h3={4,6},
		h4={3,7},
		h5={3,8},
		h6={3,9},
		h7={4,10},
		h8={5,11},
		h9={6,12},
		h10={7,12},
		h11={8,12},
		h12={9,12}
	}
	wup={
		n3=4,
		n2=5,
		n1=6,
		p0=7,
		p1=8,
		p2=9,
		p3=10
	}
	ph1=6
	ph2=0
	ph◆=0
	cw=0
	for i=1,100 do
		ph2=flr(rnd(hup["h"..ph1][2]-hup["h"..ph1][1]))+hup["h"..ph1][1]+1
		ph◆=abs(ph2-ph1)
		if ph2-ph1 < 0 then
			cw=wup["n"..ph◆]
		else
			cw=wup["p"..ph◆]
		end
		cw=flr(rnd(cw-1))+2
		addtomap(level,ph2,cw+5)
		ph1=ph2
		ph2=0
	end
	cs={}
	trs={}
	
	scr={0,0}
	
end

function _update()
	
	ply:update(plat,cs,trs,level,scr[1])
	if (ply.♥) scr[1]+=(ply.box.x1-scr[1]-16)/10	
	-- coin animation logic
	if coin_i[1] < #coin_i[2]then
		coin_i[1]+=1
	else
		coin_i[1]=1
	end
	
end

function _draw()
	cls()
	rectfill(0,0,127,127,12)
	
	--begin drawing of the map
	c_block=0 --curent block
	plat={}
	cs={}
	trs={}
	for y=1,16 do
		for x=flr(scr[1]/8),flr(scr[1]/8)+flr(128/8)+1 do
			if x>0 and x<#level[y] then
				c_block=level[y][x]
				if c_block ~= 0 then
					if c_block == 43 then
						spr(coin_i[2][coin_i[1]],(x-1)*8-scr[1],(y-1)*8)
					else
						spr(c_block,(x-1)*8-scr[1],(y-1)*8)
					end
					if (fget(c_block,0)) add(plat,█((x-1)*8,(y-1)*8,7,7))
					if (fget(c_block,1)) add(cs,█((x-1)*8,(y-1)*8,7,7))
					if (fget(c_block,2)) add(trs,█((x-1)*8+3,(y-1)*8+3,1,1))
				--else
					--spr(c_block,(x-1)*8-scr[1],(y-1)*8)
				end
			end
		end
	end
	-- end drawing of the map
	
	ply:draw(scr)
	
	print("☉:"..ply.points,3,3,10)
	
	rect(0,0,127,127,7)
end
-->8
-- helper functions

function █(x,y,w,h)
	return {
		x1=x,
		y1=y,
		x2=x+w,
		y2=y+h,
		h=h,
		w=h,
		update=function (self)
			self.x2=self.x1+w
			self.y2=self.y1+w
		end
	}
end

function coll(a,b)
	if a.y1 > b.y1+b.h then return false end
	if b.y1 > a.y1+a.h then return false end
	if a.x1 > b.x1+b.w then return false end
	if b.x1 > a.x1+a.w then return false end
	
	return true
end

function gen_anim(frms,dur)
	
	anim_frms={}
	for i,frm in pairs(frms) do
		for j=1,dur[i] do
			add(anim_frms,frm)
		end
	end
	
	return anim_frms
end

function coll_test(box,tiles)
	hit_l={}
	
	for i,tile in pairs(tiles) do
		if coll(box, tile) then
			add(hit_l,tile)
		end
	end
	
	return hit_l
	
end

function move(box,vel,tiles)
	coll_types={
		top=false,
		bottom=false,
		right=false,
		left=false
	}
	
	box.x1+=vel[1]
	box:update()
	hit_list=coll_test(box,tiles)
	for i,tile in pairs(hit_list) do
		if vel[1]>0 then
			box.x1=tile.x1-8
			coll_types.right=true
			box:update()
		elseif vel[1]<0 then
			box.x1=tile.x2+1
			coll_types.left=true
			box:update()
		end
	end	
	
	box.y1+=vel[2]
	box:update()
	hit_list=coll_test(box,tiles)
	for i,tile in pairs(hit_list) do
		if vel[2]>0 then
			box.y1=tile.y1-8
			coll_types.bottom=true
			box:update()
		elseif vel[2]<0 then
			box.y1=tile.y2+1
			coll_types.top=true
			box:update()
		end
	end
	
	return box,coll_types
end

function gen_t(el,f_el,l_el,l)
	t={}
	for i=1,l do
		if (i == 1) add(t,f_el)
		if (i > 1 and i < l) add(t,el)
		if (i == l) add(t,l_el)
	end
	
	return t
end


function gen_map()
	m = {}
	for i=1,16 do
		if (i < 7) add(m,gen_t(0,0,0,8))
		if (i == 7) add(m,gen_t(flr(rnd(2))+33,32,35,8))
		if (i > 7) add(m,gen_t(flr(rnd(3))+50,flr(rnd(3))+50,flr(rnd(3))+50,8))
	end
	
	return m
end

function addtomap(m,ph,cw)
	ic=flr(rnd(2))==1
	for y,row in pairs(m) do
		for x=1,cw do
			if x > cw-5 then
				if (y < ph+1) add(row,0)
				if (y == ph+1) add(row,33)
				if (y > ph+1) add(row,52)
			else
				add(row,0)
			end
		end
	end
end


-->8
-- objects

function player(x,y)
	return {
		box=█(x,y,7,7),
		vel={0,0},
		vs=0.25,
		max_vel=2,
		force=0.5,
		jumped=false,
		djumped=true,
		air⧗=0,
		points=0,
		♥=true,
		
		--animation logic
		anim_i=0,
		anims={
			idle=gen_anim({1,2,3,4},{10,4,10,4}),
			walk=gen_anim({5,6,7,8},{3,3,3,3}),
			jump={9,10,11},
		},
		mode="idle",
		facing=false,
		pars={},
		inp_pars={},
		walk⧗=time(),
		
		update=function(self,plat,cs,trs,m,scr)
		
			-- walking logic
			self.vel={0,0}
			if btn(1) then
				self.vel[1]+=2
			end
			
			if btn(0) then
				self.vel[1]-=2
			end
			
			if btn(4) and not self.jumped then
				if self.air⧗ < 6 then
					sfx(3)
					self.jumped=true
					self.djumped=false
					self.force = -4.75
					self.mode="jump"
				end
			elseif btn(4) and self.jumped and not self.djumped then
				if self.force > 0 then
					self.djumped=true
					self.force=-3
					sfx(2)
					for i=0,5 do
						add(self.pars,{{self.box.x2-3,self.box.y2},{(rnd(20)-10)/5,(rnd(10))/5},4,7})
					end
				end
			end
			
			if (btn(5) and not self.♥) self.♥=true
		
			self.vel[2] += self.force
			self.force+=0.5
			if self.force>7 then
				self.force=7
			end
			
			if self.vel[1]==0 and not self.jumped then
				self.mode="idle"
			elseif (self.vel[1]>0 or self.vel[1]<0) and not self.jumped then
				self.mode="walk"
			end
			
			if not self.♥ then
				self.vel={0,0}
			end
			
			-- collision logic
			self.box,col=move(self.box,self.vel,plat)
			
			if col.bottom then
				self.force=0
				if self.air⧗ > 25 then
					for i=0,5 do
						add(self.inp_pars,{{self.box.x2-3,self.box.y2},{(rnd(20)-10)/5,(rnd(10)-10)/8},2,7})
					end
				end
				self.jumped=false
				self.air⧗=0
			else
				self.air⧗+=1
			end
			
			if col.top then
				self.force=1
			end
			
			for i,t in pairs(trs) do
				if (coll(self.box,t)) self:kill()
			end
			
			for i,c in pairs(cs) do
				if (coll(self.box,c)) then
				 self:pick_c(c)
				 m[c.y1/8+1][c.x1/8+1]=0
				end
			end
			
			
			-- sound logic
			if time()-self.walk⧗ > 0.2 and col.bottom and self.mode=="walk" then 
				sfx(1) 
					add(self.inp_pars,{{self.box.x2-(self.facing==true and 0 or 8),self.box.y2},{(rnd(10)*(self.facing==true and -1 or 1))/10,(rnd(10)-10)/5},3,7})
				self.walk⧗=time()	
			end
			
			self.box:update()
		end,
		
		draw=function(self,scroll)
			--animation logic
			if self.anim_i<#self.anims[self.mode]-1 and self.mode~="jump"then
				self.anim_i+=1
			elseif self.mode=="jump" then
				if self.djumped then
					self.anim_i=2
				elseif self.force<0 then
					self.anim_i=0
				elseif flr(self.force)==0then
					self.anim_i=1
				elseif flr(self.force)>0 then
					self.anim_i=2
				end
			else
				self.anim_i=0
			end
			if self.vel[1]>0 then
				self.facing=false
			elseif self.vel[1]<0 then
				self.facing=true
			end
			
			if (self.♥) spr(self.anims[self.mode][self.anim_i+1],self.box.x1-scroll[1],self.box.y1,1,1,self.facing,false)
			
			-- particle logic
			for i,p in pairs(self.pars) do
				p[1][1]+=p[2][1]
				p[1][2]+=p[2][2]
				p[3]-=0.5
				circfill(p[1][1]-scroll[1],p[1][2],p[3],p[4])
				if p[3] <= 0 then
					self.pars[i]=nil
				end
			end
			
			for i,p in pairs(self.inp_pars) do
				p[1][1]+=p[2][1]
				p[1][2]+=p[2][2]
				p[2][2]+=0.1
				p[3]-=0.1
				circfill(p[1][1]-scroll[1],p[1][2],p[3],p[4])
				if p[3] <= 0 then
					self.inp_pars[i]=nil
				end
			end
			
			if not self.♥ then
				print("press ❎ to respawn", 30,40,8)
			end
			
		end,
		kill=function(s)
			sfx(4)
			for i=0,60 do
					add(s.inp_pars,{{s.box.x1+4,s.box.y2+4},{(rnd(20)-10)/5,(rnd(10)-10)/3},5,(flr(rnd(2))==1 and 2 or 8)})
			end
			s.vel={0,0}
			s.jumped=false
			s.djumped=true
			s.air⧗=0
			s.♥=false
		
			s.anim_i=0
			s.mode="idle"
			s.facing=false
			s.walk⧗=time()
			s.box.x1=0
			s.box.y1=50
			s.box:update()
		end,
		
		pick_c=function(s,c)
			s.points+=1	
			sfx(0)
			for i=0,10 do
					add(s.inp_pars,{{s.box.x1+4,s.box.y2+4},{(rnd(20)-10)/8,(rnd(10)-10)/4},2,10})
			end
		end
	}
end

-->8
--[[
	original=10
	+3=5
	+2=6
	+1=7
	+0=8
	-1=9
	-2=10
	-3=11
	min=4
	bh=7
	max=12
]]--
__gfx__
88888888444444444444444400000000000000004444444444444444000000004444444444444444444444444444444400000000000000000000000000000000
8800008844f4fff444444444444444444444444444f4fff444f4fff44444444444f4fff444f41f1444f41f1444f4fff400000000000000000000000000000000
808008084fff1f1044f41f1444f4fff444f4fff44fff1f104fff1f1044f4fff44fff1f104ffffff04fff1f104ffffff000000000000000000000000000000000
800080080ffffff04fff1f104fff1f104fff1f140ffffff00ffffff04fff1f100ffffff00ffffff00fff1f100fff1f1000000000000000000000000000000000
80080008006666000ffffff00ffffff04fff1f1000666600006666000ffffff00066660000666600006666000066660000000000000000000000000000000000
80800808007777000066660000666600006666000077770000777700006666000077770000777700007777000077770000000000000000000000000000000000
88000088007777000077770000777700007777000077771000777710017777000177770000777700007777000077770000000000000000000000000000000000
88888888001001000010010000100100001001000010000001000000000000100000010000010010000100100001001000000000000000000000000000000000
00aaaa0000aaaa0000aaaa0000aaaa00077777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaa7a00aaaa7a000aaa7000aaaa7a0771717700777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa99a7a0aaa9a7000aaaa000aa9aa70777177707717177000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa99aaa0aaa9aa000aaaa000aa9aaa0771717707771777000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa99aaa0aaa9aa000aaaa000aa9aaa0677777607717177000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa99aaa0aaa9aa000aaaa000aa9aaa0666666606777776000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa00aaaaaa000aaaa000aaaaaa0066666000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa0000aaaa0000aaaa0000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbbbbbbbbbbbbbbbbbbbbbbbbbb000555555599999999999999999999999900000000888868884444444400aaaa0000000000000000000000000000000000
0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb055555555aaaaaaaaaaaaaaaaaaaaaaaa0007700088886888555555540aaaa7a000000000000000000000000000000000
bb5bb5bbbb5bb5bbbbbb5bbbbbbbb5bb55555555aaaaa9aaaaaaaaaaaaaa9aaa000670006666666744444444aaa99a7a00300000300000000000000000000000
5b4b545bb545b4b5b55b45b5bb5b545b55555055aa9aaaaaaaaaaaaaaaaaaaaa006677008688888844455555aaa99aaa00b00030b00303000000000000000000
4545444554445454544544545545444555555555aaaaaaaaaaaaaaaaa9aaaaaa006667008688888844444444aaa99aaa30b003b0b00b0b300000000000000000
4444444444464444444464444444444455555555aaaaaaaaaaaaaaaaaaaaa9aa066667706666667744444445aaa99aaab0b30bb0b03b3bb30000000000000000
4444644446444444444444464464464455505555a9aaaa9aaaaaaaaaaaaaaaaa0666667088886888555555540aaaaaa0b3bb3bb3b3bbbbbb0000000000000000
4644444444444644464444446444444455555555aaaaaaaaaaaaaaaaaaaaaaaa66666677888868884444444400aaaa00bbbbbbbbbbbbbbbb0000000000000000
4444444464444446444444444444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab0000000444000000000000b00000444444444444444444400888800
4447444444777744444444444444444444444444aaaa9aaaa9aaaaaaa9aaa9aaaaaaaaaabb00000044400000000000bb00000444044444444444444008000080
44774464477777744444464444444644444444449aaaaaaaaaa9aaaaaaaaaaaaaaaaaaaa5bb000004440000000000bb500000444004446444444440080800008
6444744447177174446444444446444444444444aaaaaaaaaaaaaaaaaaaaaa9aaaaaaaaa45b000004400000000000b5400000044000444444444400080080008
4444477447777774444444444444444444444444aaa9aaaaaaaaa9aaaa9aaaaaaaaaaaaa44500000400000000000054400000004000044444644000080008008
4464474444777744464444444444464444444444aaaaaaaaaaaaaaa9aaaaaaaaaaaaaaaa44400000000000000000044400000000000004444440000080000808
4444644444717146444446444644444444444444aaaaa9aaa9aaaaaaa9aa9aaaaaaaaaaa44400000000000000000044400000000000004444440000008000080
4444444446444444444444444444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44400000000000000000044400000000000000444400000000888800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003300000000000003333000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033330000000000033333300000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333000000000333333330000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000055555500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000333333330000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333330000033333333333300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333330000333333333333330
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555000000005555555555000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333330000033333333333300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333333333000333333333333330
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333333333003333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000005555000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440000000000004444000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440000000000004444000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044440000000000004444000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000f0003333330
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000ff400000f040000555500
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f40000f4f4000004f40033333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff4400004444000004440005555550
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444000044440000f4440033333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444400004444000044440000044000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444400004444000044440000044000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003300000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003330330000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003330333000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003335333030000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044453335333533000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044453335333533300000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044453333333333330000000000000000
__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccaaacccccccaaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccaacaacccaccacaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccaaacaaacccccacaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccaacaacccaccacaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccaaacccccccaaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccccccccccccc44444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccccccccccccc44f4fff4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccccccccccccc4fff1f14ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccccccccccccc4fff1f1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccccccccccccccc6666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccccccccccccccc7777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7ccccccccccccccccc1cc1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7
7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccc7
7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccc7
7b5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbccccccccccccccccccccccccccccccccccccccccbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbbb5bb5bbcccccccccc7
7b4b5b545b4b5b545b4b5b545b4b5b545b4b5ccccccccccccccccccccccccccccccccccccccccb545b4b5b545b4b5b545b4b5b545b4b5b545b4b5cccccccccc7
7545454445454544454545444545454445454cccccccccccccccccccccccccccccccccccccccc5444545454445454544454545444545454445454cccccccccc7
7444444464444444644444446444444464444cccccccccccccccccccccccccccccccccccccccc4446444444464444444644444446444444464444cccccccccc7
7444446444444464444444644444446444444cccccccccccccccccccccccccccccccccccccccc4644444446444444464444444644444446444444cccccccccc7
7464444444644444446444444464444444644cccccccccccccccccccccccccccccccccccccccc4444464444444644444446444444464444444644cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
7444444444444444444444444444444444444cccccccccccccccccccccccccccccccccccccccc4444444444444444444444444444444444444444cccccccccc7
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777

__gff__
0000000000000000000000000000000000000000000000000000000000000000010101010004040404010102000000000101010101000000040000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff00000000000000000000000000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000050500605007050090400c0400f04013040160401a0401d0401f0402314028120301202e1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c630080200561003210016100e6101860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000505004040037400573007030097300e0200f710150101f30021300243002530026300293003830000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000001340013400233004320073200a3200e310123101831025300313003a3002e3001b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003c67038670326602c6502765023640206401d6301a63017620156101461012610116100f6100f6500e6500e6500e6500d6500d6500c6500c6500b6500a6500a650096500865007650076500000000000
__music__
00 41404344

