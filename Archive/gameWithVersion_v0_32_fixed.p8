pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- abby's restless heart
-- by deadsmile games

message={timer=0}
game_state,c,control_menu,m,a=0,0,0,false,1
players,jump_pressed_by_player={},{false,false}

tutorial_step,tutorial_pending=0,false

hours,minutes,seconds,frames=0,0,0,0

camera_pos,l={},1
camera_limits={
	{0,0,1152,352},{144,224,516,240},{0,128,1152,240},{0,352,1152,352},{0,0,480,352},{608,0,1152,352}
}
camera_limit=camera_limits[l]

g,r=0,0

gravity=0.4

function set_message(text)
	message.text=text
	message.timer=120
	message.w=#text*4-4
	message.x=64-message.w/2
	message.y=130
end function btn_player(btn_id,pidx)

	if m then if pidx==1 then return btn(btn_id,1) else return btn(btn_id,0) end
	end

	local result=false
	if c !=2 then result=result or btn(btn_id,0) end
	if c !=1 then result=result or btn(btn_id,1) end
	return result
end function btnp_player(btn_id,pidx)
	if m then if pidx==1 then return btnp(btn_id,1) else return btnp(btn_id,0) end
	end
	local result=false
	if c !=2 then result=result or btnp(btn_id,0) end
	if c !=1 then result=result or btnp(btn_id,1) end
	return result
end function btn_mapped(btn_id)
	return btn_player(btn_id,a)
end function btnp_mapped(btn_id)
	return btnp_player(btn_id,a)
end function _init()
	init_sprites()
	init_map()
	music(10)
	init_player()
end function is_solid(x,y) return fget(mget(flr(x/8),flr(y/8)),0) end function is_deadly(x,y)
	local mapx=flr(x/8)
	local mapy=flr(y/8)
	local spval=mget(mapx,mapy)
	if not fget(spval,7) then return false end
	local tilex=mapx*8
	local tiley=mapy*8
	if fget(spval,3) then return distance(x,y,tilex+7,tiley+7)<4
	elseif fget(spval,4) then return distance(x,y,tilex,tiley+7)<4
	elseif fget(spval,5) then return distance(x,y,tilex+7,tiley)<4
	elseif fget(spval,6) then return distance(x,y,tilex,tiley)<4 end
	return true
end function update_message()
	if message.timer > 0 then if message.timer > 60 then local a=min(4-message.timer/30,1)
			message.y=lerp(lerp(130,112,a),112,a)
		else
			local a=max(0,min(1-message.timer/15,1))
			message.y=lerp(112,lerp(112,130,a),a)
		end
		message.timer-=1
	end
end function update_control_tutorial()
	if not tutorial_pending or game_state !=1 then return end
	if message.timer > 0 then return end

	local tut={
		{"p1: wasd p2: arrows","press WASD or ARROWS to move","press ARROWS to move","press WASD to move"},
		{"p1: space p2: z to jump","press SPACE or Z to jump","press Z to jump","press SPACE to jump"},
		{"p1: e p2: x to interact","press E or X to interact","press X to interact","press E to interact"}
	}
	local row=tut[tutorial_step]
	if not row then tutorial_pending=false return end
	local text=m and row[1] or c==0 and row[2] or c==1 and row[3] or row[4]

	set_message(text)
	tutorial_step+=1
end function _update()
	if game_state==0 then if r<0 then r+=1
			if r==0 then game_state=1
			for x=0,127 do for y=60,63 do mset(x,y,0) end end
			end
			return
		end
		if r<61 then r+=1 return end

		if g < 4 then if btnp_mapped(2) then g=(g-1+4)%4
			elseif btnp_mapped(3) then g=(g+1)%4
			end
			if btnp_mapped(4) then if g==0 then m=false
			tutorial_step=1
			tutorial_pending=true
			r=-12
			return
			elseif g==1 then m=true
			init_player()
			tutorial_step=1
			tutorial_pending=true
			r=-12
			return
			elseif g==2 then g=5
			return
			elseif g==3 then g=4
			return
			end
			end
		end

		if g==5 then if btnp_mapped(5) then g=2 end
			return
		end

		if g==4 then if btnp_mapped(2) then control_menu=(control_menu-1+3)%3
			elseif btnp_mapped(3) then control_menu=(control_menu+1)%3
			end
			if btnp_mapped(4) then c=control_menu

			if c==0 then set_message("both active")
			elseif c==1 then set_message("arrows only")
			else
			set_message("wasd only")
			end
			g=3
			return
			end
			if btnp_mapped(5) then g=3
			end
			return
		end
	end

	for p in all(particles) do p:update()
	end

	if game_state==1 then frames+=1
		if frames==30 then frames=0
 		seconds+=1
 		if seconds==60 then seconds=0
 			minutes+=1
 			if minutes==60 then minutes=0
 				hours+=1
 			end
 		end
 	end

 	if game_state==1 then select_player(1) end
	foreach(platforms,update_platform)
 	foreach(anim_tiles,update_anim_tile)
 	foreach(coins,update_coin)

 	foreach(fireballs,update_fireball)
 	foreach(fireball_shooters,update_shooter)
 	foreach(bubbles,update_bubble)
 	foreach(bubble_shooters,update_shooter)

 	if g > 0 then g-=1
 	elseif r > 0 then r-=1

 		if r<=0 then r=0
 			init_player()
 		end
 	else
 		if m then update_player_slot(1)
			update_player_slot(2)
		else
 			select_player(1)
 			update_input()
 			move_player()
 			animate_player()
 			save_active_player()
 		end
 end
 end

 if game_state==2 then update_player_endgame()
 	for k,v in pairs(fragments) do v:update()
 	end
 end

 update_message()
 update_control_tutorial()

 select_player(1)
 camera_pos.x+=flr((player.x-57-camera_pos.x)*0.25)
 camera_pos.y+=flr((player.y-58-camera_pos.y)*0.25)
	camera_pos.x=mid(camera_limit[1],camera_pos.x,camera_limit[3])
	camera_pos.y=mid(camera_limit[2],camera_pos.y,camera_limit[4])
end function draw_object(o)
	o.sp[o.frame]:draw(o.x,o.y)
end function draw_message()
	if message.timer>0 then rectfill(message.x-2,message.y-2,message.x+message.w+4,message.y+6,7)
		rectfill(message.x-3,message.y-1,message.x+message.w+5,message.y+5,7)
		print(message.text,message.x,message.y,0)
	end
end function _draw()
	cls()
	if game_state==0 then if r<0 then if r%2==0 then cls(8) end
			return
		end
		draw_dust()
		if r<61 then print("\f8deadsmile games\n\f7presents",34,56)
			return
		end
		if g==5 then print("\f8credits\n\f7game design\n\f8lucas eduardo\n\f7programming\n\f8lucas eduardo\n\f7art/music/sfx\n\f8lucas eduardo\n\f7level design/testing\n\f8lucas eduardo\n\f7x to return",24,22)
			return
		end
		if g==4 then local c1,c2,c3=5,5,5
			if control_menu==0 then c1=7
			elseif control_menu==1 then c2=7
			else c3=7 end
			print("\f8controls",40,28)
			print("both active",32,44,c1)
			print("arrows only",32,52,c2)
			print("wasd only",32,60,c3)
			print("⬆️⬇️❎ / WASD",42,74,6)
			return
		end
		print("abby's",50,34,6)
		print("restless heart",34,44,7)
		local s1,s2,s3,s4=5,5,5,5
		if g==0 then s1=7
		elseif g==1 then s2=7
		elseif g==2 then s3=7
		else s4=7 end
		print("new game",48,78,s1)
		print("multiplayer",42,86,s2)
		print("credits",50,94,s3)
		print("controls",48,102,s4)
		print("⬆️⬇️❎",54,114,6)
		print("v0.31",2,122,5)
		return
	end
	camera(camera_pos.x,camera_pos.y)

	map(0,0,0,0,128,128)
	foreach(triggers,draw_object)
	foreach(platforms,draw_object)
	foreach(coins,draw_object)
	for p in all(particles) do p:draw()
	end
	foreach(fireballs,draw_object)
	foreach(bubbles,draw_object)

	local function draw_current_player(pidx,invert)
		local pp=players[pidx]
		if not pp or r>0 then return end
		if invert then for c=1,15 do pal(c,15-c,1) end
		end
		spr(pp.frame,pp.x,pp.y,1,1,pp.face_l,false)
		if g > 0 then local a=min(1-((g-15)/15),1)
			a=lerp(lerp(0,1,a),1,a)
			local cy=lerp(pp.y,pp.y-12,a)
			local cf=flr(lerp(1,#sp_coin1+1,a))
			if cf > #sp_coin1 then cf=1 end
			draw_sprite(sp_coin1[cf],pp.x,cy)
		end
		pal()
	end
	draw_current_player(1,false)
	if m then draw_current_player(2,true) end
	for k,v in pairs(fragments) do v:draw()
	end

	camera(0,0)
	draw_dust()

	if game_state==2 then if end_timer > 200 then print("victory!",48,28,10)
 		local secs_str=sub("0"..seconds,-2)
 		local mins_str=sub("0"..minutes,-2)
 		local s="time: "..hours..":"..mins_str..":"..secs_str.."."..flr(frames*100/30)
 		local x=64-(#s*4)/2
 		print(s,x,46,6)
 		s="death toll: "..deaths
 		x=64-(#s*4)/2
 		print(s,x,38,6)
 	end
 end

	draw_message()
end
-->8
sp_coin1,sp_coin2,sp_fire_l,sp_fire_r,sp_fire_u,sp_fire_d,sp_bubble,sp_trigger,sp_plat1x3,sp_plat3x1,sp_plat1x4,sp_plat2x3,sp_plat2x1,sp_arrows={},{},{},{},{},{},{},{},{},{},{},{},{},{}

function new_sprite_list(list,indices,flipx_list)
	local flipx_i=1
	local flipx_count=flipx_list==nil and 0 or #flipx_list
	for k,v in pairs(indices) do local flipx=false
		if flipx_i<=flipx_count then if flipx_list[flipx_i]==k then flipx=true
			flipx_i+=1
			end
		end
		add(list,new_sprite_8x8(v,flipx,false))
	end
end function new_sprite_8x8(index,flipx,flipy)
	return new_sprite((index%16)*8,flr(index/16)*8,8,8,flipx,flipy,0,0)
end function new_sprite_8tile(index,offsetx,offsety)
	return new_sprite((index%16)*8,flr(index/16)*8,8,8,false,false,offsetx,offsety)
end function new_sprite(x,y,w,h,flipx,flipy,offsetx,offsety)
	s={

		x=x,y=y,w=w,h=h,flipx=flipx,flipy=flipy,offsetx=offsetx,offsety=offsety,draw=draw_sprite
	}
	return s
end function new_tile_sprite(sp_list,w,h)
	s={

		sp=sp_list,w=w,h=h
	}
	s.draw=function(self,x,y)
		for sp in all(self.sp) do draw_sprite(sp,x,y)
		end
	end
	return s
end function init_sprites()

	add(sp_arrows,new_sprite(64,20,5,4,false,false,1,-6))

	add(sp_arrows,new_sprite(100,13,4,5,false,false,-7,2))

	add(sp_arrows,new_sprite(64,20,5,4,false,false,1,-6))

	add(sp_arrows,new_sprite(69,20,4,4,false,false,-4,-4))

	for i=1,2 do add(sp_arrows,new_sprite(100,13,4,5,true,false,11,2)) end

	for i=1,2 do add(sp_arrows,new_sprite(69,20,4,4,true,false,9,-4)) end

	for i=1,2 do add(sp_arrows,new_sprite(64,20,5,4,false,true,1,11))
		add(sp_arrows,new_sprite(69,20,4,4,false,true,-5,9))
	end

	for i=1,4 do add(sp_arrows,new_sprite(69,20,4,4,true,true,9,9)) end

	new_sprite_list(sp_coin1,{85,85,85,86,86,87,87,88,88,85,85,85,89,89,88,88,90,90},{10,11,12})
	new_sprite_list(sp_coin2,{69,69,69,91,91,87,87,93,93,69,69,69,94,94,92,92,95,95},{10,11,12})

	for i=1,4 do local i1,i2,f=36+(i-1)%2,38+(i-1)%2,i>2
		add(sp_fire_l,new_sprite_8x8(i1,true,f))
		add(sp_fire_r,new_sprite_8x8(i1,false,f))
		add(sp_fire_u,new_sprite_8x8(i2,f,false))
		add(sp_fire_d,new_sprite_8x8(i2,f,true))
	end

	local sp1=new_sprite(64,8,12,12,false,false,-2,-2)
	local sp2=new_sprite(76,8,10,12,false,false,-1,-2)
	local sp3=new_sprite(86,8,12,12,false,false,-2,-2)
	for s in all({sp1,sp2,sp1,sp3}) do add(sp_bubble,s)
		add(sp_bubble,s)
	end

	add(sp_trigger,new_sprite(98,8,6,5,false,false,0,3))
	add(sp_trigger,new_sprite(98,8,6,5,true,false,2,3))

	add(sp_plat1x3,new_tile_sprite({new_sprite_8tile(15,0,0),new_sprite_8tile(31,0,8),new_sprite_8tile(47,0,16)},8,24))
	add(sp_plat3x1,new_tile_sprite({new_sprite_8tile(61,0,0),new_sprite_8tile(62,8,0),new_sprite_8tile(63,16,0)},24,8))

	add(sp_plat2x1,new_tile_sprite({new_sprite_8tile(61,0,0),new_sprite_8tile(63,8,0)},16,8))
	add(sp_plat1x4,new_tile_sprite({new_sprite_8tile(15,0,0),new_sprite_8tile(31,0,8),new_sprite_8tile(31,0,16),new_sprite_8tile(47,0,24)},8,32))

	add(sp_plat2x3,new_tile_sprite({new_sprite_8tile(13,0,0),new_sprite_8tile(29,0,8),new_sprite_8tile(45,0,16),new_sprite_8tile(14,8,0),new_sprite_8tile(30,8,8),new_sprite_8tile(46,8,16)},16,24))
end function draw_sprite(self,x,y,flipx,flipy)
		if flipx then flipx=not self.flipx
		else
			flipx=self.flipx
		end
		if flipy then flipy=not self.flipy
		else
			flipy=self.flipy
		end
		sspr(self.x,self.y,self.w,self.h,x+self.offsetx,y+self.offsety,self.w,self.h,flipx,flipy)
end function lerp(x,y,a)
	return x+(y-x)*a
end function smooth_lerp(x,y,a)
	return lerp(x,y,a*a*(3-2*a))
end function distance(x1,y1,x2,y2)
 local xd,yd=abs(x1-x2),abs(y1-y2)
	local dsq=xd*xd+yd*yd

	if dsq > 0 then return sqrt(dsq)
	elseif dsq==0 then return 0
	end

	return 32761
end function rect_intersect(l1,t1,r1,b1,l2,t2,r2,b2)
	return not (r1 < l2 or b1 < t2 or l1 > r2 or t1 > b2)
end function clamp(v,x,y)
	if v < x then return x
	elseif v > y then return y
	end
	return v
end function rect_circ_intersect(circx,circy,circr,rectl,rectt,rectr,rectb)

	if circx+circr < rectl
		or circx-circr > rectr
		or circy+circr < rectt
		or circy-circr > rectb then return false
	end

	if distance(clamp(circx,rectl,rectr),clamp(circy,rectt,rectb),circx,circy) < circr then return true
	end

	return false
end
-->8
player_spawn,player={x=88,y=88},{}

accel,speedx_max,jump_speed=0.8,2.25,4.75

score,deaths=0,0

function make_player(x,y)
	return {
		x=x,y=y,xv=0,yv=0,face_l=true,frame=1,frame_delay=2,on_ground=false,was_ground=false,on_wall=false,wall_side=0,platform=nil,bubble=nil,fly_timer=0,aircontrol_timer=0,no_bubble_timer=0
	}
end function init_player()
	players[1]=make_player(player_spawn.x,player_spawn.y)
	players[2]=make_player(player_spawn.x+24,player_spawn.y)
	a=1
	player=players[1]
	camera_pos.x=player.x-64
	camera_pos.y=player.y-64
	jump_pressed_by_player={false,false}
	jump_pressed=false
	end_timer=0
	end_frame=1
end function select_player(pidx)
	a=pidx
	player=players[pidx]
	jump_pressed=jump_pressed_by_player[pidx]
end function save_active_player()
	players[a]=player
	jump_pressed_by_player[a]=jump_pressed
end function kill_player()
	r=30
	add_particle_burst(player.x+4,player.y+4,player.xv*0.25,player.yv*0.25,20,7,20)
	sfx(3)
	deaths+=1
end

end_frames,end_timer,end_frame={16,17,18,19,12},0,1

function update_player_endgame()
	player.face_l=false
	if player.on_ground then if player.x < 936 then player.xv=1
		else
			player.xv=0
			player.frame=8
			if end_timer > 20 then player.frame=end_frames[end_frame]
			if end_timer%4==0 then end_frame+=1
			end
			if end_frame > 5 then end_frame=5
			end
			if end_timer==40 then new_fragment(0.25,sp_coin1,false,false,933,81)
			new_fragment(0.5,sp_coin2,true,false,939,81)
			new_fragment(0.75,sp_coin1,true,true,939,87)
			new_fragment(0,sp_coin2,false,true,933,87)
			sfx(10)
			elseif end_timer==183
			or end_timer==186
			or end_timer==189
			or end_timer==192
			or end_timer==195 then for x=0,40 do local xv=sin(x/40)
			local yv=cos(x/40)
 		add_particle(940+xv*6,87.5+yv*6,xv*2,yv*2,10,20+flr(rnd(10)),1.5,0,1)
 	end
 	sfx(11)
			elseif end_timer > 196 then local t=end_timer%3
 	if t==0 then spawn_magic_bubble(9)
 	elseif t==1 then spawn_magic_bubble(10)
 	elseif t==2 then spawn_magic_bubble(7)
 	end
			end
			end

			end_timer+=1
		end
	end

	move_player()

	if end_timer==0 then animate_player()
	end
end function update_player_slot(pidx)
	select_player(pidx)
	update_input()
	move_player()
	animate_player()
	save_active_player()
end function update_input()
	if player.bubble !=nil then if btn_mapped(4) then if not jump_pressed then player.xv=0
			player.yv=0
			if btn_mapped(0) then player.xv=-1
			end
			if btn_mapped(1) then player.xv=1
			end
			if btn_mapped(2) then player.yv=-1
			end
			if btn_mapped(3) then player.yv=1
			end
			local d=distance(player.xv,player.yv,0,0)
			if d !=0 then player.xv=player.xv/d*jump_speed
			player.yv=player.yv/d*jump_speed
			else
			player.yv=-jump_speed
			end
			jump_pressed=true
			sfx(9)
			player.fly_timer=6
			player.aircontrol_timer=6
			player.no_bubble_timer=4
			player.bubble=nil
			end
		end
	else
		if player.fly_timer<=0 then if btn_mapped(0) then if player.on_ground then player.xv-=accel
			player.face_l=true
			elseif player.aircontrol_timer<=0 then player.xv-=accel/2.1
			player.face_l=true
			end
			elseif btn_mapped(1) then if player.on_ground then player.xv+=accel
			player.face_l=false
			elseif player.aircontrol_timer<=0 then player.xv+=accel/2.1
			player.face_l=false
			end
			elseif player.on_ground then if player.xv > 0 then player.xv-=accel
			if player.xv < 0 then player.xv=0
			end
			elseif player.xv < 0 then player.xv+=accel
			if player.xv > 0 then player.xv=0
			end
			end
			end
			if player.xv <-speedx_max then player.xv=-speedx_max
			elseif player.xv > speedx_max then player.xv=speedx_max
			end
		end

		if btn_mapped(4) then if (player.on_ground or player.on_wall) and not jump_pressed then player.yv=-jump_speed
			if player.platform !=nil then player.xv+=player.platform.xv
			player.platform=nil
			end
			jump_pressed=true
			sfx(0)
			if player.on_wall then player.aircontrol_timer=6
			player.xv=speedx_max*player.wall_side
			if player.wall_side > 0 then player.face_l=false
			elseif player.wall_side < 0 then player.face_l=true
			end
			end
			end
		end
 end

	if btnp_mapped(5) then for t in all(triggers) do if t.on==0
			and rect_intersect(player.x,player.y,player.x+8,player.y+8,t.x,t.y,t.x+8,t.y+8) then t:activate()
			sfx(2)
			break
			end
		end
	end

 if not btn_mapped(4) then jump_pressed=false
 end
end function move_player()
	player.was_ground=player.on_ground
	player.on_ground=false
	player.on_wall=false
	player.wall_side=0

	if player.fly_timer > 0 then if player.fly_timer%2==0 then add_particle(player.x+3,player.y+3,0,0,12,20,2,0,1)
		else
			add_particle(player.x+3,player.y+3,0,0,1,20,2,0,1)
		end
		player.fly_timer-=1
	end
	if player.aircontrol_timer > 0 then player.aircontrol_timer-=1
	end
	if player.no_bubble_timer > 0 then player.no_bubble_timer-=1
	end

	if player.platform !=nil then if not rect_intersect(player.x+player.xv,player.y+player.yv,player.x+player.xv+7,player.y+player.yv+8+player.platform.yv,player.platform.x,player.platform.y,player.platform.x+player.platform.w,player.platform.y+player.platform.h) then player.platform=nil
		else
			player.on_ground=true
		end
	end

	if player.platform !=nil then player.x+=player.platform.xv
		player.y+=player.platform.yv
	elseif player.bubble !=nil then player.x+=player.bubble.xv
		player.y+=player.bubble.yv
	elseif player.fly_timer<=0 then player.yv+=gravity
	end

	if player.yv > 7 then player.yv=7
	end

	if is_solid(player.x,player.y+player.yv+8)
		or is_solid(player.x+7,player.y+player.yv+8) then player.y=(flr((player.y+player.yv)/8)*8)
		player.yv=0
		player.on_ground=true
	end

	if is_solid(player.x+player.xv+8,player.y)
		or is_solid(player.x+player.xv+8,player.y+7) then player.x=(flr((player.x+player.xv)/8)*8)
		player.xv=0
	end

	if is_solid(player.x+player.xv,player.y)
		or is_solid(player.x+player.xv,player.y+7) then player.x=(flr((player.x+player.xv+8)/8)*8)
		player.xv=0
	end

	if is_solid(player.x,player.y+player.yv)
		or is_solid(player.x+7,player.y+player.yv) then player.y=(flr((player.y+player.yv+8)/8)*8)
		player.yv=0
	end

	for p in all(platforms) do if rect_intersect(player.x+player.xv,player.y+player.yv,player.x+player.xv+8,player.y+player.yv+8,p.x,p.y,p.x+p.w,p.y+p.h) then if player.x+8<=p.x-p.xv then if rect_intersect(player.x+player.xv,player.y+player.yv+1,player.x+player.xv+8,player.y+player.yv+7,p.x,p.y,p.x+p.w,p.y+p.h) then player.x=p.x-8
			player.xv=0
			if not player.was_ground
			and rect_intersect(player.x,player.y+player.yv+2,player.x+9,player.y+player.yv+5,p.x,p.y,p.x+p.w,p.y+p.h)	then player.on_wall=true
			player.wall_side=-1
			end
			end
			elseif player.x>=p.x+p.w-p.xv then if rect_intersect(player.x+player.xv,player.y+player.yv+1,player.x+player.xv+8,player.y+player.yv+7,p.x,p.y,p.x+p.w,p.y+p.h) then player.x=p.x+p.w
			player.xv=0
			if not player.was_ground
			and rect_intersect(player.x-1,player.y+player.yv+2,player.x+7,player.y+player.yv+5,p.x,p.y,p.x+p.w,p.y+p.h) then player.on_wall=true
			player.wall_side=1
			end
			end
			end
			if player.y+7 < p.y-p.yv then if rect_intersect(player.x+player.xv+1,player.y+player.yv,player.x+player.xv+7,player.y+player.yv+8,p.x,p.y,p.x+p.w,p.y+p.h) then player.y=p.y-8
			player.yv=0
			if not player.was_ground then sfx(1)
			end
			player.on_ground=true
			player.on_wall=false
			player.wall_side=0
			player.platform=p
			end
			elseif player.y>=p.y+p.h-p.yv then if rect_intersect(player.x+player.xv,player.y+player.yv,player.x+player.xv+7,player.y+player.yv+8,p.x,p.y,p.x+p.w,p.y+p.h) then player.y=p.y+p.h+p.yv
			player.yv=gravity
			end
			end
		end
	end

	player.x+=player.xv
	player.y+=player.yv

	if not player.on_ground then if is_solid(player.x-1,player.y+3)
			or is_solid(player.x-1,player.y+5) then player.on_wall=true
			player.wall_side=1
		elseif is_solid(player.x+8,player.y+3)
			or is_solid(player.x+8,player.y+5) then player.on_wall=true
			player.wall_side=-1
		end
	else
		player.fly_timer=0
		player.aircontrol_timer=0
	end

 local in_platform=false
	for p in all(platforms) do if rect_intersect(player.x+2,player.y+2,player.x+6,player.y+6,p.x,p.y,p.x+p.w,p.y+p.h) then in_platform=true
			break
		end
	end

 if player.y > 127*8
 	or in_platform
		or is_deadly(player.x,player.y)
 	or is_deadly(player.x+7,player.y)
 	or is_deadly(player.x,player.y+7)
 	or is_deadly(player.x+7,player.y+7)
 	or is_solid(player.x+4,player.y+4) then kill_player()
 end

 for k,v in pairs(checkpoints) do if k !=current_checkpoint
 		and hit_checkpoint(v) then current_checkpoint=k
 		break
 	end
 end

 local cl=mget(flr(player.x/8),flr(player.y/8))
 if cl==255 then game_state=2
 elseif cl>=240 then cl-=239
 	if l !=cl then l=cl
 		camera_limit=camera_limits[l]
 	end
 end

 for v in all(coins) do hit_coin(v)
 end
end function animate_player()
	if player.bubble !=nil then player.frame=8
 elseif player.on_ground then if not player.was_ground then sfx(1)
 		player.frame=10
 		if player.platform==nil then add_particle(player.x+2,player.y+7,-0.3,0,7,6+flr(rnd(8)),1.5,0)
 			add_particle(player.x+3,player.y+7,-0.1,-0.01,7,6+flr(rnd(8)),1.5,0)
 			add_particle(player.x+4,player.y+7,0.1,-0.01,7,6+flr(rnd(8)),1.5,0)
	 		add_particle(player.x+5,player.y+7,0.3,0,7,6+flr(rnd(8)),1.5,0)
 		end
 	elseif player.frame==10 then player.frame=11
 	else

 		if player.xv !=0 then player.frame_delay-=1

 if player.frame_delay<=0 then player.frame_delay=((3-(abs(player.xv)-0.5))*2)

 	player.frame+=1

 	if player.frame>=8 then player.frame=0
 	end
 end
 else
 	player.frame_delay=0
 	player.frame=8
 end
 end
 else

 	if player.yv < 0 then player.frame=9
 	else
 		player.frame=8
 	end
 end
end
-->8
particles,dust={},{}
for i=1,8 do add(dust,{x=-rnd(64)-10,y=rnd(128),s=1,sp=2+rnd(2),drift=rnd(0.2)-0.1,o=rnd(1),c=5+rnd(2)})
end function draw_dust()
	for p in all(dust) do p.x+=p.sp
		p.y+=sin(p.o)*0.5+p.drift
		p.o+=0.08

		pset(p.x,p.y,p.c)
		if rnd(1)>0.7 then pset(p.x+rnd(3)-1,p.y+rnd(3)-1,p.c)
		end

		if p.x>132 then p.x=-4
			p.y=rnd(128)
		end
	end
end function is_offscreen(x,y)
	return (abs(x-player.x-64) > 256
		or abs(y-player.y-64) > 256)
end function add_particle(x,y,xv,yv,col,timeout,start_radius,end_radius,draw_type)
	if is_offscreen(x,y) then return
	end
	p={
		x=x,y=y,xv=xv,yv=yv,start_radius=start_radius,end_radius=end_radius,col=col,totaltime=timeout,timeout=timeout,update=update_particle_directional
	}

 if draw_type==nil
 	or draw_type==0 then p.draw=draw_rect_particle
 else
 	p.draw=draw_circ_particle
 end

	add(particles,p)
end function add_particle_spin(x,y,spin_speed,spin_radius,col,timeout,start_radius,end_radius,draw_type)
	p={}
	p.x=x
	p.y=y
	p.start_x=x
	p.start_y=y
	p.sin_val=rnd(1)
	p.sin_inc=spin_speed
	p.sin_radius=spin_radius
	p.start_radius=start_radius
	p.end_radius=end_radius
	p.col=col
	p.totaltime=timeout
	p.timeout=timeout

	p.update=update_particle_spin

 if draw_type==nil
 	or draw_type==0 then p.draw=draw_rect_particle
 else
 	p.draw=draw_circ_particle
 end

	add(particles,p)
end function add_particle_burst(x,y,xv,yv,p_count,col,timeout)
	timeout=ceil(timeout/2)

	for i=0,p_count-1 do add_particle(x,y,sin(i/p_count)*rnd(1)+xv,cos(i/p_count)*rnd(1)+yv,col,timeout+flr(rnd(timeout)),1.5,0,0)
	end
end function spawn_magic_bubble(col)
	local p=rnd(1)
	local xv=sin(p)
	local yv=cos(p)
	add_particle_spin(940+xv*8,87.5+yv*8,0.01,16,col,8+flr(rnd(4)),1.5,0,1)
end function update_particle_directional(self)
	self.timeout-=1
	if self.timeout<=0 then del(particles,self)
	else
		self.x+=self.xv
		self.y+=self.yv
	end
end function update_particle_spin(self)
	self.timeout-=1
	if self.timeout<=0 then del(particles,self)
	else
		self.x=self.start_x+sin(self.sin_val)*self.sin_radius
		self.y=self.start_y+cos(self.sin_val)*self.sin_radius

		self.sin_val+=self.sin_inc

		if self.sin_val>=1 then self.sin_val-=1
		elseif self.sin_val < 0 then self.sin_val+=1
		end
	end
end function draw_rect_particle(p)
	local r=lerp(p.end_radius,p.start_radius,p.timeout/p.totaltime)
	rectfill(p.x-r,p.y-r,p.x+r,p.y+r,p.col)
end function draw_circ_particle(p)
	local r=lerp(p.end_radius,p.start_radius,p.timeout/p.totaltime)
	circfill(p.x,p.y,r,p.col)
end
-->8
triggers,platforms,fireball_shooters,fireballs,bubble_shooters,bubbles,anim_tiles,checkpoints,coins,current_checkpoint={},{},{},{},{},{},{},{},{},-1

function find_param(x,y)
	local param=0

	local sp=mget(x,y)
	if sp>=240 then if sp==253 then param=64
 	elseif sp==254 then param=96
 	elseif sp==255 then param=128
 	else
 		param=(sp-240)*4
 	end
	else
		return false,param
	end

 mset(x,y,0)
	return true,param
end function find_params(x,y,xv,yv)
	local found,param1=find_param(x+xv,y+yv)
	local param2=0

	if found then found,param2=find_param(x+xv*2,y+yv*2)
	else
		param1=64
	end

	return param1,param2
end function init_map()
	for x=0,127 do for y=0,59 do local sp=mget(x,y)

			if sp==32 then local p1,p2=find_params(x,y,1,0)
			add_shooter(fireball_shooters,add_fireball,x*8,y*8,1,0,p1,p2)
			elseif sp==33 then local p1,p2=find_params(x,y,0,-1)
			add_shooter(fireball_shooters,add_fireball,x*8,y*8,0,-1,p1,p2)
			elseif sp==34 then local p1,p2=find_params(x,y,-1,0)
			add_shooter(fireball_shooters,add_fireball,x*8,y*8,-1,0,p1,p2)
			elseif sp==35 then local p1,p2=find_params(x,y,0,1)
			add_shooter(fireball_shooters,add_fireball,x*8,y*8,0,1,p1,p2)

			elseif sp==48 then local p1,p2=find_params(x,y,1,0)
			add_shooter(bubble_shooters,add_bubble,x*8,y*8,1,0,p1,p2)
			elseif sp==49 then local p1,p2=find_params(x,y,0,-1)
			add_shooter(bubble_shooters,add_bubble,x*8,y*8,0,-1,p1,p2)
			elseif sp==50 then local p1,p2=find_params(x,y,-1,0)
			add_shooter(bubble_shooters,add_bubble,x*8,y*8,-1,0,p1,p2)
			elseif sp==51 then local p1,p2=find_params(x,y,0,1)
			add_shooter(bubble_shooters,add_bubble,x*8,y*8,0,1,p1,p2)

			elseif sp==70 then add_checkpoint(x,y)
			elseif sp==75 then current_checkpoint=add_checkpoint(x,y)
			player_spawn.x=checkpoints[current_checkpoint].x*8
			player_spawn.y=checkpoints[current_checkpoint].y*8

			elseif sp==86 then add_coin(x,y)
			mset(x,y,0)
			end
		end
	end

	t=add_trigger(212,248)
	t:add_targets({add_platform({216,216},{304,288},sp_plat1x3,{t},false)})

	add_platform({120,120},{264,240},sp_plat3x1,nil,false)

	add_platform({240,240},{176,200},sp_plat2x1,nil,false)
	add_platform({296,296},{200,176},sp_plat2x1,nil,false)
	add_platform({356,344,368},{200,200,200},sp_plat2x1,nil,false)
	add_platform({408,432},{200,200},sp_plat2x1,nil,false)
	add_platform({432,432},{136,112},sp_plat2x3,nil,false)

	add_platform({384,384},{16,64},sp_plat3x1,nil,false)
	add_platform({384,384},{120,72},sp_plat3x1,nil,false)

	add_platform({496,456,496,496},{64,64,64,104},sp_plat2x1,nil,false)
	add_platform({560,576,576,576,536},{104,104,64,104,104},sp_plat2x1,nil,false)
	add_platform({496,536,536,536},{24,24,64,24},sp_plat2x1,nil,false)

	t=add_trigger(424,24)
	t:add_targets({add_platform({368,368},{0,-16},sp_plat1x4,{t},false)})

	t=add_trigger(152,104)
	t:add_targets({add_platform({176,176},{48,152},sp_plat1x4,{t},false)})

	t=add_trigger(36,152)
	t:add_targets({add_platform({32,32},{168,208},sp_plat3x1,{t},false)})

	t=add_trigger(796,280)
	t:add_targets({add_platform({824,848},{296,296},sp_plat3x1,{t},false)})

	add_platform({936,888,888,984,984},{208,208,304,304,208},sp_plat2x1,nil,false)
	add_platform({984,984,888,888,984},{256,208,208,304,304},sp_plat2x1,nil,false)
	add_platform({936,984,984,888,888},{304,304,208,208,304},sp_plat2x1,nil,false)
	add_platform({888,888,984,984,888},{256,304,304,208,208},sp_plat2x1,nil,false)

	add_platform({768,816},{208,208},sp_plat2x1,nil,false)
	add_platform({744,696},{208,208},sp_plat2x1,nil,false)
	add_platform({632,632},{152,200},sp_plat3x1,nil,false)
	add_platform({632,632},{144,96},sp_plat3x1,nil,false)

end function add_platform(nodesx,nodesy,sp,ts,multi_trigger)
	plat={
		x=nodesx[1],y=nodesy[1],xv=0,yv=0,w=sp[1].w,h=sp[1].h,nodesx=nodesx,nodesy=nodesy,nodeslen=#nodesx,dest=2,sp=sp,frame=1,triggers=ts,dir=1,active=false,multi_trigger=multi_trigger,wait_target=true
	}
	if ts==nil then plat.active=true
	end

	plat.activate=function(self)
		local triggered=true
		if self.triggers !=nil
			and self.multi_trigger then for t in all(self.triggers) do if t.on==0 then triggered=false
			break
			end
			end
		end

		if triggered then self.active=true
		end
	end

	add(platforms,plat)

	return plat
end function add_trigger(x,y)
	t={
		x=x,y=y,sp=sp_trigger,frame=1,active=false,on=0,targets={},wait_target_count=0,wait_target=false
	}
	t.activate=function(self)
		local targets=self.targets
		self.on=self.wait_target_count
		self.active=true
		self.frame=2
		for t in all(self.targets) do if not t.active then t:activate()
			end
		end
	end
	t.add_targets=function(self,targets)
		for a in all(targets) do add(self.targets,a)
			if a.wait_target then self.wait_target_count+=1
			end
		end
	end
	add(triggers,t)
	return t
end function update_platform(a)
	if not a.active then a.xv=0
		a.yv=0
		return
	end

	local xd=a.x-a.nodesx[a.dest]
	local yd=a.y-a.nodesy[a.dest]
	local len=distance(xd,yd,0,0)
	local xnorm=xd/len
	local ynorm=yd/len
	local continue=true

	if len==0

		or (a.x < a.nodesx[a.dest]-xnorm
		and a.x > a.nodesx[a.dest]+xnorm
		and a.y < a.nodesy[a.dest]-ynorm
		and a.y > a.nodesy[a.dest]+ynorm) then a.dest+=a.dir

		if a.dir > 0 then if a.dest > a.nodeslen then if a.triggers==nil then a.dest=1
			else
			a.dest=a.nodeslen-1
			a.dir=-1
			a.active=false
			sfx(6)
			continue=false

			end
			end
		else
			if a.dest < 1 then if a.triggers==nil then a.dest=a.nodeslen
			else
			a.dest=2
			a.dir=1
			a.active=false
			sfx(6)
			continue=false

			end
			end
		end
	end

	if continue then xd=a.x-a.nodesx[a.dest]
 	yd=a.y-a.nodesy[a.dest]
 	len=distance(xd,yd,0,0)
 	xnorm=xd/len
 	ynorm=yd/len
		a.x-=xnorm
		a.y-=ynorm
		a.xv=-xnorm
		a.yv=-ynorm
	else
		a.xv=0
		a.yv=0
	end

end function add_shooter(list,spawn,x,y,fxv,fyv,fire_rate,start_delay)
	local s={
		x=x,y=y,fxv=fxv,fyv=fyv,fire_rate=fire_rate,timer=start_delay,active=true
	}
	s.fire=function(self)
		if not is_offscreen(self.x,self.y) then spawn(self.x+self.fxv*8,self.y+self.fyv*8,self.fxv,self.fyv)
		end
	end
	add(list,s)
	return s
end function add_fireball(x,y,xv,yv)
	f={
		x=x,y=y,xv=xv,yv=yv,sp=sp_fire_r,frame=1,frame_count=#sp_fire_r,timer=360
	}
	if (xv < 0) then f.sp=sp_fire_l
	elseif (xv > 0) then f.sp=sp_fire_r
	elseif (yv < 0) then f.sp=sp_fire_u
	elseif (yv > 0) then f.sp=sp_fire_d
	end

	add(fireballs,f)

	return f
end function update_shooter(s)
	if s.active then s.timer-=1
		if s.timer<=0 then s:fire()
			s.timer=s.fire_rate
		end
	end
end function hits_platform(x,y,r)
	for p in all(platforms) do if rect_circ_intersect(x,y,r,p.x,p.y,p.x+p.w,p.y+p.h) then return true
		end
	end
	return false
end function fire_burst(x,y,xv,yv)
	add_particle_burst(x,y,-xv/2,-yv/2,5,8,8)
	add_particle_burst(x,y,-xv/2,-yv/2,5,9,8)
end function update_fireball(f)
	f.timer-=1

	if f.timer<=0 then del(fireballs,f)
		return
	end

	local dead=false
	f.x+=f.xv
	f.y+=f.yv

	if is_solid(f.x+3+f.xv,f.y+3+f.yv)
		or hits_platform(f.x+3+f.xv,f.y+3+f.yv,3) then dead=true
	end

	if dead then del(fireballs,f)
		fire_burst(f.x+3,f.y+3,f.xv,f.yv)
		return
	end

	f.frame+=1

	if f.frame > f.frame_count then f.frame=1
	end

	if f.timer%6==0 then add_particle(f.x+2+rnd(4),f.y+2+rnd(4),0,0,8,10,1.5,0)
	end

	if r<=0
		and rect_circ_intersect(f.x+3,f.y+3,3,player.x,player.y,player.x+7,player.y+7) then kill_player()
	end
end function add_bubble(x,y,xv,yv)
	b={
		x=x,y=y,xv=xv,yv=yv,sp=sp_bubble,frame=1,frame_count=#sp_bubble,timer=360
	}
	add(bubbles,b)

	return b
end function update_bubble(b)
	local dead=false
	b.x+=b.xv
	b.y+=b.yv
	b.timer-=1

	if b.timer<=0 then dead=true
	end

	if not dead then if is_solid(b.x+3+b.xv*4,b.y+3+b.yv*4)
			or is_deadly(b.x+3+b.xv*2,b.y+3+b.yv*2)
			or hits_platform(b.x+3+b.xv,b.y+3+b.yv,6) then dead=true
		end

		for f in all(fireballs) do if not (abs(f.x-b.x) > 9
 		or abs(f.y-b.y) > 9) then if distance(b.x+3,b.y+3,f.x+3,f.y+3) < 9 then dead=true
 				del(fireballs,f)
 				fire_burst(f.x+3,f.y+3,f.xv,f.yv)
 				break
 			end
 		end
		end
	end

	if dead then if player.bubble==b then player.bubble=nil
		end
		del(bubbles,b)
		local p_count=10
		for i=0,p_count-1 do local xv=sin((i+rnd(1)*0.5)/p_count)
			local yv=cos((i+rnd(1)*0.5)/p_count)
			add_particle(b.x+3+xv*5,b.y+3+yv*5,xv*0.5,yv*0.5,12,2+flr(rnd(4)),1.5,0)
		end
		return
	end

	b.frame+=1

	if b.frame > b.frame_count then b.frame=1
	end

	if b.timer%10==5 then add_particle(b.x+3+rnd(2)-b.xv*5,b.y+3+rnd(2)-b.yv*5,0,0,12,20,3,0,1)
	end

	if r<=0
		and player.no_bubble_timer<=0
		and player.bubble !=b
		and rect_circ_intersect(b.x+3,b.y+3,4,player.x,player.y,player.x+7,player.y+7) then player.bubble=b
		player.platform=nil
		player.x=b.x
		player.y=b.y
		player.xv=0
		player.yv=0
		player.on_ground=false
		player.on_wall=false

		sfx(8)
	end
end function add_anim_tile(x,y,frames,play_once)
	a={
		x=x,y=y,frames=frames,frame=1,frame_count=#frames,play_once=play_once,}
	add(anim_tiles,a)
end function update_anim_tile(a)
	a.frame+=1
	if a.frame > a.frame_count then a.frame=1
		if a.play_once then a.frame=a.frame_count
			del(anim_tiles,a)
		end
	end
	mset(a.x,a.y,a.frames[a.frame])
end function add_checkpoint(x,y)
	local c={
		x=x,y=y-1
	}

	add(checkpoints,c)

	return #checkpoints
end function checkpoint_frames()
	local f={}
	for j=1,2 do for i=70,79 do add(f,i) end
	end
	for i=70,79 do add(f,i)
		add(f,i)
	end
	local h={3,4,5,6,6,1}
	for i=1,6 do for j=1,h[i] do add(f,69+i) end
	end
	return f
end function hit_checkpoint(c)
	local x=c.x*8
	local y=c.y*8
	if rect_intersect(player.x,player.y,player.x+7,player.y+7,x,y,x+8,y+8) then add_anim_tile(c.x,c.y+1,checkpoint_frames(),true)
		player_spawn.x=x
		player_spawn.y=y
		sfx(5)
		set_message("checkpoint")
		if current_checkpoint !=-1 then add_anim_tile(checkpoints[current_checkpoint].x,checkpoints[current_checkpoint].y+1,{76,76,77,77,78,78,79,79,70},true)
		end
		return true
	end
	return false
end function add_coin(x,y)
	local c={
 	x=x*8,y=y*8,sp=sp_coin1,frame=1,frame_count=#sp_coin1
	}
	add(coins,c)
end function hit_coin(c)
	if r<=0 and rect_intersect(player.x,player.y,player.x+7,player.y+7,c.x,c.y,c.x+8,c.y+8) then sfx(4)
		del(coins,c)
		g=30
		player.xv=0
		player.yv=0
 	for x=0,15 do add_particle(player.x+4,player.y+4,sin(x/15),cos(x/15),10,20+flr(rnd(10)),1.5,0,1)
 	end
		return true
	end
	return false
end function update_coin(c)
	c.frame+=1
	if c.frame > c.frame_count then c.frame=1
	end
end
-->8
fragments={}

function new_fragment(angle,sp,flipx,flipy,dest_x,dest_y)
	f={}
	f.x=937
	f.y=48
	f.radius=0
	f.angle=angle
	f.sp=sp
	f.frame=5
	f.flipx=flipx
	f.flipy=flipy
	f.timer=4
	f.nodes_x={937,937,dest_x,dest_x}
	f.nodes_y={56,56,dest_y,dest_y}
	f.nodes_r={0,32,32,0}
	f.nodes_t={0,14,84,145}
	f.node_i=1
	f.update=function(self)
		local i=self.node_i
		if i<=3 then self.frame+=1

 	if self.frame > #sp_coin1 then self.frame=1
 	end

 		add_particle(self.x+3,self.y+3,0,0,9,10,2,0,1)

 		self.angle+=0.01
 		if self.angle>=1 then self.angle-=1
 		end

			local y=i+1
 		local t=(self.timer-self.nodes_t[i])/(self.nodes_t[y]-self.nodes_t[i])
 		self.r=smooth_lerp(self.nodes_r[i],self.nodes_r[y],t)
 		self.x=lerp(self.nodes_x[i],self.nodes_x[y],t)+sin(self.angle)*self.r
 		self.y=lerp(self.nodes_y[i],self.nodes_y[y],t)+cos(self.angle)*self.r

			self.timer+=1
 		if self.timer==self.nodes_t[y] then self.node_i+=1
 		end
		else
			self.x=self.nodes_x[3]
			self.y=self.nodes_y[3]
		end
	end

	f.draw=function(self)
		draw_sprite(self.sp[self.frame],self.x,self.y,self.flipx,self.flipy)
	end

	add(fragments,f)
end
__gfx__
08328820088000000000000000328820083288200880000000000000003288200832882000328820000000000000000000888800777777777787888677777886
823888828232882808328820083888828238888282328828083288200838888282388882083888820000000000000000081ff18086888887dd2222228687dd22
80281f1f0038888f8238888828281f1f80281f1f0038888f8238888828281f1f80281f1f28281f1f08800000083288200ffffff086688887ddd222228867d2d2
000ffff000281f1f00281f1f800ffff0000ffff000281f1f00281f1f800ffff0000ffff0800ffff08232882882388888f0ffff0f86868887dd2d22228687dd22
00333000003ffff0003ffff00033300000333000003ffff0003ffff00033300000333000003330000038888f00281f1f0333333086688888ddd222228868d2d2
003333000f3333000f33300000333000003333000f3333000f333000003330000f333f000f33300003281f1ff33ffff00033330086868887dd2d22228687dd22
003f30000030f3003300f300033f300000f33000003003003300030003f03000003330000333f000f33ffff00033333f0033330086686888ddd2d2228868d2d2
003000000300000000000300000030000003000003000000000003000000300000300300303000000333333f033000300300003086868888dd2d22228688dd22
08830000000000000000000000088880566d55d55dd5df650000467dd77f40000000dddd0000000d66d000000000000000b3000086686888ddd2d2228868d2d2
82328820083288200328882000881f1f17f11ffddffd167d0001f7d77d677f0000d6776ccd00006776cc000000dddd00003b000086868888dd2d2d228688dd22
002888828238888283888882038fffff0f40f7fd5f7f147600064067670000000d7777cddcd00d777cdcd000d7776ccd0003b00086686888ddd2d2228868d2d2
0008888880288888822f1f1f032ffff00d067fd551f7601f0000007f4f400000067776ddddc007776dddc0067776cddcc000377086868688dd2d2d228688dd22
003ffff0003ffff0803ffff0083330000047611dd106740d0000007401600000d7776cddddcdd776cdddcdd776cdddddcd00766786686888ddd2d2228868d2d2
0033300000333000003330000f3333f000f4046f6f404f00000000f000000000d776cddddd6dd76cddddcd66cdddddddcc00007086868688dd2d2d228688dd22
00f33f00003ff00000f33f00003330000000177667fd00000000000000000000d6cddddddc7dd6cddddd6d6cdddddddd6c00070086686888ddd2d2228868d2d2
00300300003003000030030003000300000df6d5510000000000000000000000dcddddddd67ddcdddddc6ddcddddddd67d0076cd86668688dd2d2d228688dd22
15dd155dd5676d1dd551dd5115999811000000000000000000899800008998000cddddddc7600cddddc6700ccddddc676000070086686888ddd2d2228868d2d2
5d66000550051005500066d55d979811000899800008998008aaaa8008aaaa800dcdddc677d00dcddc67d000dcc6777d0000007086668688dddd2d228688dd22
99d7060650676d0560607d99d6d98155aa9aaaa8989aaaa809a77a9009a77a9000dcc6776d0000cc6776000000dddd000000000086666888ddd2d2228868d2d2
979757571005100175757979d6776dd508aa77a900aa77a909a77a9009a77a900000dddd0000000dccd00000000000000000000086668687dddd2d228687dd22
99861616d6776dd5616168991005100100aa77a909aa77a908aaaa9008aaaa90007007777000000000000000000000000000000086666868ddddd2228868d2d2
881d0d0dd6d98155d0d0d18850676d0589aaaaa89aaaaaa80899aa80009aaa80076707600000000000000000000000000000000086666687dddddd228687dd22
115d00015d9798111000d51150051005000899800008998000a8090000809a8070c0770c00000000000000000000000000000000887777777666d6d28877666d
1155155d15999811d5515511d5676d1d000000000000000000a008000090090000d00700d0000000000000000000000000000000d222222dddddddddd222dddd
15dd000dd67766ddd000dd5115cccd1100000600dff6400055d55dfd00000015000000155d6fd00000000000000000000000000078888888888888888888888d
5d66016606776dd0661066d55dc7cd1106000f00f7777f601dfd1f7f0046ffd50000df7667710000000000000000000000000015768686868686868686868682
ccd7d67701676d10776d7dccd6dcd1550f004740dff640000f7f0f7f6f7777fd00f404f6f6404f00000000000f00000000000165786868686868686868686872
c7c7677700d6d10077767c7cd6776dd547406760510000000f7f06760046ffd5d047601dd11674000000061047000000000016d1777787888888888888878772
ccd6d666d6776dd5666d6dcc00d6d1006760f7f05dff64000676047400000015f1067f155df760d0000004f4f700000000016d517ddddddddddddddddddddd6d
dd1d1dd6d6dcd1556dd1d1dd01676d10f7f0f7f0df7777f6047400f000046ffd6741f7f5df7f04f000000076760460000016d3518d2d2d2d2d2d2d2d2d2d2d6d
115d01dd5dc7cd11dd10d51106776dd0f7f1dfd15dff640000f0006006f7777fd761dffddff11f7100f776d77d7f10000163551182d2d2d2d2d2d2d2d2d2d26d
1155000d15cccd11d0005511d67766dddfd55d55510000000060000000046ffd56fd5dd55d55d6650004f77dd7640000155111116222222222222222222222dd
00011001d55111551001001000000000005d0000000000000eeeee8000eee600000e70000007d0000076560007755760007676000007700000078000007e8800
0151101d51000015510110110000000000d50000000047700e888880008e8600000e700000075000007d1d0007611660007d7600000770000007200000728200
1d11005100000000150151055100000001510000000a7aa00e88888000e8e600000e7000000710000071d1000516611000d7d600000670000007200000782800
55100110000000000110d5015d5100000510000000a7aa000e888880008e8600000e7000000710000071d1000516611000d7d600000670000007200000728200
510101000000000000105d100015100010000000047a97000e88888000e8e600000e700000075000007d1d0007611660007d7600000770000007200000782800
501501000000000000100550100010000000000007aa7a7008888880008e8600000e700000075000007d1d0006611660007d7600000770000007200000728200
105500000000000000000051011000000000000007aaa79000055000000550000005500000055000000550000005500000055000000550000005500000055000
005d100000000000000010110051000000000000000aa00000065000000650000006500000065000000650000006500000065000000650000006500000065000
101d5000000000000001010100000000151155100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105d0000000000000050510000000011115d5110000477000009a000009900000a90000007900000000990000009a000007a00000a900000079000000009900
05115100000000000015015000000050015d5151000a7aa000097900000aa0000079900000aa40000007990000097900000aa0000079900000aa400000079900
0150150000000000005500110000051001551d5100a7aaaa0007a94000077000097a900007799000000779900007a90000044000007a900000049000000a4000
1501001000000000055101010000151001156d10047a97aa009749400007a000097794000aa9940000a7a9900097490000094000007794000009940000794000
5d511000000000005d5055100000510001d6d51007aa7a7000779900000aa000007799000099990000779900007799000007a000007799000077990000779900
15dd55110000015dd5015d5100011010056d511007a0079000774900000aa0000074990000a949000074990000779900000aa0000077990000aa990000779900
0111111111011555100015d1001000011dd511100000000000000000000000000000000000000000000000000009900000099000000a900000094000000a9000
666666366666663166666666663666355dddddd5ddddd351666666316666666511111111111111110000000000000000d50dd351dddd335133dd35555555d555
3666335333333dd13663333335533d311dd355503315555136633dd1363333d115dd5510111110010dd5001000005100550d5551d35553515ddddd51dd51dddd
53663555533553d15633355555153d5113351110511115505d5555d1535555d11511110011ddd510051100000000110011135511d55555510000000000015100
5d335555553555d153d3555555155d511551111051111150151555d15d55553105111100105511100111051001100000001351111111555100000000000d1000
5ddd5515555555d15dd555555511111115511110111111505d1555315d5515110111110000511110000001100110000055151110d35155110017801000135000
11551113555555315dd555555553dd5115511110155511505d1555315d551d310111110000511110001100000000011051111000d55111111518801111165110
3333dd33555555315dd5555555555d51155111101511115055155551555515510000000000111110001101000000011011d3551155515511555101511d165151
5d333555555555515dd5555555555d1115111110111111501111111111111111000000000000000000000000000000000055111111111111155555111656d1d0
5ddd5555551111115d55555555555d11010000001111115066666665666366651110111115511111000000000055100011511111dddd551100000000155d5110
5ddd5555551d3dd115111111555553111335511000000010366333d1363133d115d501111511110100000000001110001111dd51d55111115100000011110001
55dd5555551355d155dd5331555553111351111010015530563555d15d5135d1151101011111dd5000011000001110001111355151111111d610000015dd5511
555d5555551355d153355531555555111511100000011150535555d15d51553101110550110151100001100000000000d5115551111111113d61000011000001
555d1555551555d155315531555ddd5111111011100111105d555531531111110000051005101110000000000000000055111111dd5111115ddd10000566d510
55551155551555d155511551555d551101000011000511105d511511531dd55100110000011000000000001000001100511d5511551155115ddd51001d111151
51ddd515d31155515155d3515d13551100000010000100101551dd51551511110011000000000000000000000000110011155511511151115d35351011551111
11d55111111115111151111115111111000000000000000011115111111111110000000000000000000000000000000011111111111111115511111115551111
460f0f0f0fc687b700b600b6d76753000000000000076686775666d6e6f6e600000000000000000000000000000000000000000000006163716687b700000000
00000000000000000000000000000000000000000000000000a7b7a797771776d666c676773753000000000f0f000000007347d693b3cfa3b300000000732636
c700000000c7460000a7a6c606365300000000000076179757c6261647f757001f0000a343b3000000000000000000000000000000000000002636a700000000
00000000000000000000000000000000000000000000000000b600b6d767000000000000006653000000000f64000000007366d7c7d613c793b3000000732737
d600000000d647a7000000c7d666934343b3000000278767a6c707374697560064000073d753000000a343b3000000000000000000000000002757b6b7000000
00000000000000000000000000000000000000000000000000a7a6c60636000000000000006753000000a3766667b3000073c65171006141d7530000007347a6
760000000077a6d60000a796976776776667000000668696479786d6263666767766d6677666677677d667766677b300000000000000000000c696a647000000
000000000000000000000000000000000000000000000000000000c7d66600000000000000d653000000732616d653000073775300000073d653000000736686
2700000000263687b600a6b747d60000000000000076174656d7d60027170000000000000000000000000000616371000000006766760000006697b700000000
0000000000000000000000000000000000000000000000000000a79697770000676676772636530000006107377753000061637100000061637100000073c687
4600000000273700b7b64676c6660000000000000066167657c66600d676000000000000000000000000000000000000000000616371000000d6b600a7000000
0000000000000000000000000000000000000000000000000000a6b747d6000000000061412753000000000000d6530000000000000000000000009fef227646
960000000047a600a7b7475706160000007667667707376607677700073700000000000000000000000000000000000000000000000000000077c647b6000000
00000000000000000000000000000000000000000000000000b64676c66600650000000073c753000000a30636c753000000000000000000000000000073d647
c7000000006686a700a6009707170000000000000000000000002f001f00000000001f00000000000000000000000000000000000000000000061686a6000000
000000000000a7b600000000b7b60000000000000000000000b747570616e6f6e6000f00616371000000736617d75300000000000000000000000000007377a6
1600000000c687b70000b6b7a6670000000000000000000000002f001f0000000000b4000000000000000000000000000000000000000000000717b7d6b60000
0000000000b7a69600a7000000a6a7000000000000000000000000b7071787f79700640000000000000073679687934343434343434343434343434343830616
1700000000c746000000a6c6a72636660616b300000000000000a30616266766760636776776b300a30616763666b3000000a3762636d616667696a796b70000
000000b6a70000a7b6b7000000000000000000000000000000000000b6a700b7b6d62636b3000000000073c6a67626366687968697464777c7d797a686470717
5600000000d647a700a7b7a79627379666175300000000000000730717763777960717c6574693438307177737679343434383465617273756c6970087000000
a700a7a697b687a7a60000b6b70000b6000000a7b7000000000000a700000000a797273793b300000000736687b7073786b7a7b6c687a7579687b60000b786b6
d70000000077a6d6b6000000b64796a60786934343432636434383862746564797a6b697b747a686c696d6c7c647764656d64747a686b69686a6b70000000000
00b74647c696c6b777a7a69787a700000000b69700a7b60000a7a6b60000b7a697d78696c65300000000733686a7a697b60000a7a6b700a7b60000000000a700
c6000000000616869700000000875787a7b7966717d62737465637b78747578700a796d776b6c6a7a687970616b7a69687a6b60000a7a687b6a7000000000000
a78687c7d67767d676c66756c7d7a600b6b7465697b70000b6978776870096d7d66677c7517100000000732757b6b70000000000000000000000000000000000
d6000000000717b7a700b6b7465697b70000b69787768786a64796a6a797b700a70000a79677c74786d666072776c6b797b700a7000000b70000000000000000
a69756d751710000000000616341c787a7a69686c7a6a7008757b7a6b7b6765171336163710000000000736796a6470000000000000000000000000000000000
360000000076d687b677a7a69686c7a6a7008757b7a6b70097b700b68700000000b6b700a65163636371000000006141c696b60000000000a7000000000000b6
96c6675171000000000f0000006141d647b6063677d7b7a696568647a7a6975300cf000000000000000073c797b7000000000000000000000000000000000000
370000000067c796978747b6063677d7b7a696568647a700b60000000000b6b700a7a6b6c653000000000000000000614177a6a700b7a7a6b600000000a700b7
97c7667100000000006400000000614167660737676677d66646c7d6c6878653000f0000a343b3000000737687b6a70000000000000000000000000000000000
76000000002616d686d767660737676677d66646c7d6c687a7a60000b6b7a7000000a787d75300000000003f0000000061418697b6a60097a700a7b600b7a700
00d65600000000a306776600000000616363636363636363636363634166c753000000a38366530000007377c647b70000000000000000000000000000000000
67000000002737c6263600000000000000000000000073c6b777a7a697874696b6b7a6967753000000000064000000000073c6a6a787b7061687b76796b60000
b69767000000007327530000000000000000000000000000000000006106165300000073d6775300af0073261686a60000000000000000000000000000000000
66000000000000770717000000000000000000000000738696a647c686c74757768746566653000000a376772616b30000736687b7967627174686b6d7c7a7b7
87967700000000737753000000000000000000000000000000000fcf2366175300000073468693b3cfa3830717b7d6b600000000000000000000000000000000
77000000000000000f3f0000000000000000000000006163636363636363416686a757d751710000007367862717530000732636465651636363636341c67686
c6d666b300000067d653000000000000000000000000000000000000a367d75300000073c687a6931383677696a796b700000000000000000000000000000000
16000f00000000000f3f00000000002636760000000000000000000000007397b6b7d651710000000073d6d79687530000730737d6517100000000006141d626
367776530f0f0f66c79343434343434343434343434343b300a34343434656530000007367969776772636c69700870000000000000000000000000000000000
17006400000000000f3f0000000000276603cf6f0000000000000000000073a6c6675171000000000073c7c697b6530000736777517100000000000000614107
376651710000a377c67626366616d676d746968697575171006141c6874737530000007306168747c76637a6b700000000000000000000000000000000000000
d6662636160000000f3f00000000007636530000000000000000000000006163636371000000000f0073d651636371000061636371000000a34343b300006163
636371000000730737465617273756c697475163636371000000616363636371000000730717b6a6978687b70000000000000000000000000000000000000000
c6562776170000000f3f0000000000733793434343434343b30000000000000000000000000000cf007377710000000000000000000000a38367667100000000
00000000000061634147a686b69686a6b7c7710000000000000000000000000000000073c697b700a700b6a70000000000000000000000000000000000000000
9796c70703df00000f3f000000000073061667d6c7d7d67603cf9f0000000000000000000000a31343833603df0f0000000000000000a383777603df4f000000
000000000000cfdf2286b6a7a687b6a74603cf8f0000000000000000000000000000a38356860000000000000000000000000000000000000000000000000000
a787d7d6660000000f3f000000000073077797a68687567753000000000000000000000000a38376d62737b3000000000000000000a383c64656c7b300000000
000000000000a3438397a6b700a7000047d6b30000000000000000000000000000a3834647a70000000000000000000000000000000000000000000000000000
00b69756370000000f3f0000000000675687b70000b6579693434343434343434343434343832636c74656934343434343434343438306d64796979343434343
4343434343438366d7578700b60000b7a697934343434343434343434343434343838696b6000000000000000000000000000000000000000000000000000000
00a7b7577667d64656667706167646d796b60000000000b7868797a6b6b787c6969786d676667717c64757979686c6c7d6c667776676d6d7a686b696c6261666
76d6c7d7968697c647b6b7a700000000a7b687869647574656c6d666c7d7968747a6b70000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000015dd1000000066666666dd310000155533d55d5510001511110110000000
eeee7eeeeeeee7eeeeee7eeeee7e77eeee7ee7eee7eee7eee7eeee7ee7eee7ee001d636d33100000366333d55550000015113555555510005dd5000051000000
eee7e7eeeeee77eeeee7e7eee77eee7eee7e7eeeee7e7e7eee7ee77eee7e7e7e01d665355d3100005633555551500000005155513d5110005355011011000000
eee7e7eeeee7e7eeeeee7eeeee7ee7eeee7e77eeee7e7e7eee7e7e7eee7ee7ee056d513555d5000053d511110110000001105511550110005551011000000000
eee7e7eeeee777eeeee7e7eeee7e7eeeee7e7e7ee7ee7e7ee7ee777ee7ee7e7e1dd51555555310005dd510000000000001101551110000001111000010000000
eeee7eeeeeeee7eeeeee7eeeee7e777eee7ee7eee77ee7eee77eee7ee77ee7ee5d555111555550005d55ddd35000000000051100100100001000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5d555101d51150005d5535535000000001011005100000000051000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5355d5005dd150005d5555555000000000000001100000000011000000000000
__label__
0000000001000000d50dd351000000001551111111111111dddd55111111111100000000010000001111115000000000d50dd3515d6fd0000000060000000600
0000000013355110550d55510dd500101511110111111001d551111115dd551000005100133551100000001000005100550d55516771000006000f0006000f00
000110001351111011135511051100001111dd5011ddd51051111111151111000000110013511110100155300000110011135511f6404f000f0047400f004740
00011000151110000013511101110510110151101055111011111111051111000110000015111000000111500110000000135111d11674004740676047406760
000000001111101155151110000001100510111000511110dd5111110111110001100000111110111001111001100000551511105df760d06760f7f06760f7f0
00000010010000115111100000110000011000000051111055115511011111000000011001000011000511100000011051111000df7f04f0f7f0f7f0f7f0f7f0
000000000000001011d3551100110100000000000011111051115111000000000000011000000010000100100000011011d35511dff11f71f7f1dfd1f7f1dfd1
000000000000000000551111000000000000000000000000111111110000000000000000000000000000000000000000005511115d55d665dfd55d55dfd55d55
666666316666666566636665dddd3351dddd55111151111166636665dddd335111511111111111110000000015511111ddddd3515dddddd5d50dd35111101111
36633dd1363333d1363133d1d3555351d55111111111dd51363133d1d35553511111dd51111110010dd5001015111101331555511dd35550550d555115d50111
5d5555d1535555d15d5135d1d555555151111111111135515d5135d1d55555511111355111ddd510051100001111dd5051111550133511101113551115110101
151555d15d5555315d5155311111555111111111d51155515d51553111115551d511555110551110011105101101511051111150155111100013511101110550
5d1555315d55151153111111d3515511dd5111115511111153111111d35155115511111100511110000001100510111011111150155111105515111000000510
5d1555315d551d31531dd551d551111155115511511d5511531dd551d5511111511d551100511110001100000110000015551150155111105111100000110000
551555515555155155151111555155115111511111155511551511115551551111155511001111100011010000000000151111501551111011d3551100110000
11111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000011111150151111100055111100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000467d566d55d5dddd3351115111115dd5df6555d55dfd55d55dfd
0000000000000000000000000000000000000000000000000000000000000000000000000001f7d717f11ffdd35553511111dd51dffd167d1dfd1f7f1dfd1f7f
000000000000000000000000000000000000000000000000000000000000000000000000000640670f40f7fdd5555551111135515f7f14760f7f0f7f0f7f0f7f
0000000000000000000000000000000000000000000000000000000000000000000000000000007f0d067fd511115551d511555151f7601f0f7f06760f7f0676
000000000000000000000000000000000000000000000000000000000000000000000000000000740047611dd351551155111111d106740d0676047406760474
000000000000000000000000000000000000000000000000000000000000000000000000000000f000f4046fd5511111511d55116f404f00047400f0047400f0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001776555155111115551167fd000000f0006000f00060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000df6d51111111111111111510000000060000000600000
000000000000000000000000000000000000000000000000000000000000000000083288200000000000467d566d55d5dddd5511dff640000000000000000000
000000000000000000000000000000000000000000000000000000000000000000823888820000000001f7d717f11ffdd5511111f7777f600000000000000000
00000000000000000000000000000000000000000000000000000000000000000080281f1f000000000640670f40f7fd51111111dff640000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000ffff00000000000007f0d067fd511111111510000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000333000000000000000740047611ddd5111115dff64000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000f333f00000000000000f000f4046f55115511df7777f60000000000000000
000000000000000000000000000000000000000000000000000000000000000000003330000000000000000000001776511151115dff64000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000030030000000000000000000df6d511111111510000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000467d55d55dfdd77f40000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f7d71dfd1f7f7d677f000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000640670f7f0f7f670000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f0f7f06764f4000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007406760474016000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0047400f0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00060000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000
00000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0047400f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
47406760470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6760f7f0f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f7f0f7f0760460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f7f1dfd17d7f10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dfd55d55d76400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddd3351dff640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d3555351f7777f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5555551dff640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11115551510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d35155115dff64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5511111df7777f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555155115dff64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111115100000000000000788888888888888d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666665dff640000000000076868686868686820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
363333d1f7777f600000000078686868686868720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
535555d1dff640000000000077778788888787720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d55553151000000000000007ddddddddddddd6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d5515115dff6400000000008d2d2d2d2d2d2d6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d551d31df7777f60000000082d2d2d2d2d2d26d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555515515dff64000000000062222222222222dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d555555dff640000000000000000000000000000000000000000600000006000000000000000000000000000000000000000000000000000000000000000000
15111111f7777f600000000000000000000000000000000006000f0006000f000000000000000000000000000000000000000000000000000000000000000000
55dd5331dff64000000000000000000000000000000000000f0047400f0047400f00000000000000000000000000000000000000000000000000000000000000
53355531510000000000000000000000000000000000061047406760474067604700000000000000000000000000000000000000000000000000000000000000
553155315dff6400000000000000000000000000000004f46760f7f06760f7f0f700000000000000000000000000000000000000000000000000000000000000
55511551df7777f600000000000000000000000000000076f7f0f7f0f7f0f7f07604600000000000000000000000000000000000000000000000000000000000
5155d3515dff640000000000000000000000000000f776d7f7f1dfd1f7f1dfd17d7f100000000000000000000000000000000000000000000000000000000000
11511111510000000000000000000000000000000004f77ddfd55d55dfd55d55d764000000000000000000000000000000000000000000000000000000000000
5dddddd5dff640000000000000000000000000000000001566636665dddd3351dff640000000000000000000000788888888888888d000000000000000000600
1dd35550f7777f600000000000000000000000000046ffd5363133d1d3555351f7777f6000000000000000000007686868686868682000000000000006000f00
13351110dff640000000000000000000000000006f7777fd5d5135d1d5555551dff640000000000000000000000786868686868687200000000000000f004740
15511110510000000000000000000000000000000046ffd55d515531111155515100000000000000000000000007777878888878772000000000061047406760
155111105dff64000000000000000000000000000000001553111111d35155115dff640000000000000000000007ddddddddddddd6d00000000004f46760f7f0
15511110df7777f600000000000000000000000000046ffd531dd551d5511111df7777f600000000000000000008d2d2d2d2d2d2d6d0000000000076f7f0f7f0
155111105dff640000000000000000000000000006f7777f55151111555155115dff6400000000000000000000082d2d2d2d2d2d26d0000000f776d7f7f1dfd1
151111105100000000000000000000000000000000046ffd111111111111111151000000000000000000000000062222222222222dd000000004f77ddfd55d55
11111111dff640000000000000000000000000000000001511511111ddddd351dff6400000000000000000000000000000000000000000000000001566666665
11111001f7777f600000000000000000000000000046ffd51111dd5133155551f7777f6000000000000000000000000000000000000000000046ffd5366333d1
11ddd510dff640000000000000000000000000006f7777fd1111355151111550dff6400000000000000000000000000000000000000000006f7777fd563555d1
10551110510000000000000000000000000000000046ffd5d5115551511111505100000000000000000000000000000000000000000000000046ffd5535555d1
005111105dff64000000000000000000000000000000001555111111111111505dff64000000000000000000000000000000000000000000000000155d555531
00511110df7777f600000000000000000000000000046ffd511d551115551150df7777f6000000000000000000000000000000000000000000046ffd5d511511
001111105dff640000000000000000000000000006f7777f11155511151111505dff6400000000000000000000000000000000000000000006f7777f1551dd51
000000005100000000000000000000000000000000046ffd111111111111115051000000000000000000000000000000000000000000000000046ffd11115111
115111115d6fd0000000060000000600000006000000001501000000111111505d6fd000000006000000060000000600000006000000060000000015dddd5511
1111dd516771000006000f0006000f0006000f000000df7613355110000000106771000006000f0006000f0006000f0006000f0006000f000000df76d5511111
11113551f6404f000f0047400f0047400f00474000f404f61351111010015530f6404f000f0047400f0047400f0047400f0047400f00474000f404f651111111
d5115551d1167400474067604740676047406760d047601d1511100000011150d11674004740676047406760474067604740676047406760d047601d11111111
551111115df760d06760f7f06760f7f06760f7f0f1067f1511111011100111105df760d06760f7f06760f7f06760f7f06760f7f06760f7f0f1067f15dd511111
511d5511df7f04f0f7f0f7f0f7f0f7f0f7f0f7f06741f7f50100001100051110df7f04f0f7f0f7f0f7f0f7f0f7f0f7f0f7f0f7f0f7f0f7f06741f7f555115511
11155511dff11f71f7f1dfd1f7f1dfd1f7f1dfd1d761dffd0000001000010010dff11f71f7f1dfd1f7f1dfd1f7f1dfd1f7f1dfd1f7f1dfd1d761dffd51115111
111111115d55d665dfd55d55dfd55d55dfd55d5556fd5dd500000000000000005d55d665dfd55d55dfd55d55dfd55d55dfd55d55dfd55d5556fd5dd511111111
11111111d50dd351ddddd351dddd33516666666666366635dddd335111111111ddddd351dddd55110100000015511111111011111111111111111111d50dd351
15dd5510550d555133155551d35553513663333335533d31d35553511111100133155551d5511111133551101511110115d501111111100115dd5510550d5551
151111001113551151111550d55555515633355555153d51d555555111ddd5105111155051111111135111101111dd501511010111ddd5101511110011135511
0511110000135111511111501111555153d3555555155d5111115551105511105111115011111111151110001101511001110550105511100511110000135111
011111005515111011111150d35155115dd5555555111111d35155110051111011111150dd511111111110110510111000000510005111100111110055151110
011111005111100015551150d55111115dd555555553dd51d5511111005111101555115055115511010000110110000000110000005111100111110051111000
0000000011d3551115111150555155115dd5555555555d5155515511001111101511115051115111000000100000000000110000001111100000000011d35511
000000000055111111111150111111115dd5555555555d1111111111000000001111115011111111000000000000000000000000000000000000000000551111
d50dd35166666665dddd5511666366655ddd55555d5555556666666566666631dddd335166636665115111115dddddd5ddddd351dddd33511151111101000000
550d5551366333d1d5511111363133d15ddd555515111111366333d136633dd1d3555351363133d11111dd511dd3555033155551d35553511111dd5113355110
11135511563555d1511111115d5135d155dd555555dd5331563555d15d5555d1d55555515d5135d1111135511335111051111550d55555511111355113511110
00135111535555d1111111115d515531555d555553355531535555d1151555d1111155515d515531d5115551155111105111115011115551d511555115111000
551511105d555531dd51111153111111555d1555553155315d5555315d155531d351551153111111551111111551111011111150d35155115511111111111011
511110005d51151155115511531dd55155551155555115515d5115115d155531d5511111531dd551511d55111551111015551150d5511111511d551101000011
11d355111551dd51511151115515111151ddd5155155d3511551dd51551555515551551155151111111555111551111015111150555155111115551100000010
0055111111115111111111111111111111d551111151111111115111111111111111111111111111111111111511111011111150111111111111111100000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000467d55d55dfd55d55dfd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f7d71dfd1f7f1dfd1f7f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000640670f7f0f7f0f7f0f7f
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f0f7f06760f7f0676
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000740676047406760474
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0047400f0047400f0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0006000f00060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
00000000000000000000000000010101000000008080a0c00000000000010101010101010000000000000000000101010101010180808080808088900001010100000000000000000000000000000000000000000100000000000000000000000101010101010101010101010101010101010101010101010101010101010000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000
__map__
6676676670712367727673707d77666061717c7d67617773647c6063776766727370716777667d6c766670736777006d646c7d7c657c6d7d666666666d70737667776c786d687869677c6261686b000000000000007a00000000000000000000000000000000000000000000000000000000007a7b6a6b7a0000000000000000
630000000000f5000000000000006d707120fcf0000000000000707300000000000000000000777d6d153636170000163636366d0000000000000000f40000000016363636363614667d72717400000000000000006b00000000000000000000000000000000000000000000000000007a6b6a79696869796a7b7a0000000000
730000000000f30000000000000000000000000000000000000000000000f0000000000000006d72731700000000000000000066000000005600000046000000000000000000001614677c6c786a0000000000007a7b0000000000000000000000000000000000000000000000007a6b6a7978697d6d7c6878796a6b7a000000
67000000003a343b0000f6f4f2f0000000000000000000000000000000004600003a3b00000064686500000000000000000000670000006e6f6e656762630000000000000000000016146d797b7a000000000000006a000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7600000000376d350000f8f8f8f862776320fcf60000000000006261676663766777350000007c60610000000062616300000070716d64707f737c7d7271343434343b0000000000001614746a000000007a00007b74000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d0000667667777666712121212172707377766d6766777667606371777273163636170000006670710000000070733500000000000000000000163614766d7c646c35000000000000003766687a006b0000007a6a6c0000000000000000000000000000000000000000000000000000000000ffffffffff0000000000000000
6100000000000000000000000000000000000000000000f0fe227c00000000000000000000f0626176000000006d773500000000000000000000000016363636147d3500000000000000376c787b00000000006b696d0000000000000000000000000000000000000000000000000000000000ffffffffff0000000000000000
7100000000000000000000000000000000000000000000f1fe227700000000000000000000f772736600000000767c350000000000006263000000000000000016361700003a343b0000377c6400007a7b007a787d770000000000000000000000000000000000000000000000000000000000ffffffffff0000000000000000
7600000000000000000000000000000000000000000000f2fe22720000003a6061676d7760216762630000000064693500000000000072733b000000000000000000000000377d350000376d747a6a007a6b7b6c62630000000000000000000000000000000000000000000000000000000000646e6f6e650000000000000000
6600000000000000003a343b0000003a343b00003a3400f3fe22610000003772237c7d67707723767300000000707d35000000000000606139343434343b00000000000000377c35000037776a6d696b6a6979766673000000000000000000000000000000000000000000000000000000000054797f78540000000000000000
720000003a343b0000377c35000000376d350000376600000070710000001617f50000000000f80000000000006367350000006676677071777d7c6967350000000000000016361700003762616b7968767615170000000000000000000000000000000000000000000000000000000000005354404142544300000000000000
63000000166c656d66676d7767766d7d77667667607600000062633b00000000f00000000000f200000000000072733500000000000000000016146d7d3500003a343b00000000000000377271741536363617000000000000000000000000000000000000000000000000000000000000646554505152546465000000000000
7300f0000000000000000000000000000000f000707100000066733500000000000000f1000000000000f000006d663500000000f4000000000000146c350000376c350000000000000037666c79350000000000000000f5006667766d6477656c677c686566766d6263776c6d6567767774406061766263427566676d6c796a
76004600000000000000560000000000000046006263000000777c393b000000000000f50000000000004600007c653500000000460000000000001660350000376d35000000000000003762636935000000003a343b0046006d6c4050425069785042437542524372734052437578796b7b507071777273526a6b786b7a0000
67626320fdf00000006e6f6e000000f0fd22626172730000006d69666d767760616d772166766263676d77766769753500000066766700000000000070393434347c393434343434343438707315170000003a387666676061695350686a4243536b7a4453406a007a42445044536b7b007a78687d6d7c69797b007a7b000000
67617320fdf8000000657f64000000f8fd22726d656700000072787968657564717d796b7868727c6679696465787435000000377735000000000000776465667c7d6764656d746661676465661700000000376762637d726d79006b7a0040440000007a0044006b79007a6b00007a6a7a00007a7b6a6b7a6a7a000000000000
6d706276716566767767666777766677667260611517000000776b7a746b6a686c787a746c6a79697d686b74756b6c393434343865350000000000003762616c79676a69786a6b7571787475770000000000376465716c69686a7b00000044007b000000006b7b6465797b00006b79786b006b7b7a6b7a7b6b00000000000000
7d6c72650000000000000000000000000000707117000000006466786c7d66777c646667776d7d7c776d7c696a7965646c7874696d35000000000000377271746b7b687b006b007a796b007b76000000000037746a687b786b7b7a00007b6a7a00007a7b007a6a69687c6a7a0078756b7a7b6a64787a6b6a7a006b0000000000
646568750000000000000000000000000000000000000000007c606115170000000000000000000000000016146d7c15363636147d3500000000000037666c786a006b0000007a0000007a796d3b000000003768696b6a746567746a6b7a69796b7a786b6a746b6063777d7b6a6965686a007a7567777968697b000000000000
747579770000460000000000000000000000000000000076677772711700000000000000000000000000000016147d35000000377735000000000000167d797b7a0000000000000000007b6465393b000000377679786c6d7c7d6669676865646d78676568766670737666776d66647c797b6b6465153614786a7a7b00000000
7166606376677760613434347634343467610000000000376d151700000000000000000000000000000000000016361700000016361700000000000062616a0000000000000000000000006a757d35000000163623363636363614776d69751536361466697c15170000000000f516147c786a7415170016146b79007a6b0000
7771727300000070717673726667766672730000000000377c35000000000000003a343b0000000000000000000000000000000000000000000000007071696b000000000000000000000000697c350000000000f60000000000161464661517000016147715170000000000f5f50016146d7d7635000000376465797b000000
660000000000000000000000000000000000000000000016361700000000000000376d350000000000000000000000000000000000000000000000003a6c787b00000000000000000000006b786c350000000000f200000000f5fc326815170000000016361700000000000046f5000016147661350000003767687c6a7a0078
610000000000000000000000000000000000000000000000000000000000000000376735000000000000000000000000000000000000000000000000377c6400000000000000000000007b007466350000000000000000000000001636170000000000000000003a6263776660613b000037727135000000376063777d7b6a69
71000000000000000000000000000000000000f2000000000000000000000000003772350000003a34343bf2f2f2f2f2f2f2f4f4f4f4f4f4f4f4f4f4376d747a0000000000000000007a6a7a7b68350000003a3434343434343b000000003a3434343b0000003a38727d69726771350000163636170000003770737666776866
6600000000000000000000000000f2f2f2f2f246f2f2f2f2f2f20000000000000037643500000037776d3500000000003a343b00000000000000000037776a6d000000000000000000007a6c697d350000003764656d7c6c6517000000001666676517000000166664686a786864350000000000000000001636363636146364
6700000000000000000000003a60610000006667766660616662633b0000000000376935000000377c65350000000000377635000000000000000000376263786b000000000000000000007a6a6639343434386979697d00000000000000006d00000000000000006d787b7a7977350000000000000000000000000000376d74
63f2f2f23a343434343434343870710000003777617c706d657273393434343434387c39343434387475393434343434387d39343434343434343434387273007b000000000000000000007b6b79696c776768747b6b7864773434343434347c767734343434346c796b006b69763500003a34343b0000003a343b000037767d
7300000037667767626377666164350000003772736d646979686d6465776766676d686c656d62636d69657d74797869686c786d687879677460616764657a00000000000000000000000000007a7868796b7a00000000756869796a6b74786979686a697d67696b7b756a6c7d66350000376979350000003768350000376c78
6d0000001663646572796972677c3500000016363666787a787d6777666c6d77657c6c767d77707276666d777c64656d7c74697c7d796c7864657178747500000000000000000000000000000000006a7b000000007a7b006a6b7b007a7b00006b00007b797b6a7478657968606335000037786b350000001636170000377c64
77000000006d74686a006a78686235000000000000776c6a60610000000000000000000000000000000000000000001636361700163614657568796b0000000000000000000000000000000000006b7a0000006b000000007a7b006b6a696b64656a7b7a6b6d7c7d676465777073170000376c68350000000000000000376d74
6700000000767d786b7a7b7a79773500000000000062767c70710000005600000000000000000000000000000000000000000000000037697c6c6a0000000000000000000000000000000000000000000000000000000000000000786862617c7574686967631536363617f000000000003764653500f800000000000037776a
__sfx__
0001000002311033210432106321080310a7310c0310e741100411374115041197411c7412074123731277212a721013000130002300023000130001300013000130001300013000000000000000000000000000
00020000033200562002610016100e600106001160011600136001360015600156001560015600156001560015600000000000000000000000000000000000000000000000000000000000000000000000000000
000200003263001220085302065019620196101961000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000016630276701b6600d6501a64011640176300d63011620176200f620076200a610056100b610076100361006610026100161003402034020340203405047000470004700004020040200402004050b700
0008000018050240601f0502b060240502b050300602b050300703003030020300203001030010300150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001d755187551c7551d7501d7301d7201d71500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000017760126602776026320c222016220a01201612080120501204012020120201504002030020200200302003020000000000000000000000000000000000000000000000000000000000000000000000
00060000376243b6313a62137621356113461132611306152e6002d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001d51121521167150971107711067110571104711047110000000000000002170003700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000320110a7212c0210e731270311374121041197511d0512074123731277212a7212e713317132151321513205131f5131d5131b517185171651713717117170f7170d7170c7170b710000000000000000
001000002204102551260510655129051095512c0410b5512f0310e551330311155137021155513a021175513d0111b5513f0111d5513f011215513f011245413f011275313f0112a5213f0112d5113f01130515
010800002b05030070300403003030020300103001030015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000016630276701b6600d6501a64011640176300d63011620176200f620076200a610056100b610076100361006610026100161003402034020340203405047000470004700004020040200402004050b700
0008000018050240601f0502b060240502b050300602b050300703003030020300203001030010300150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001d755187551c7551d7501d7301d7201d71500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000017760126602776026320c222016220a01201612080120501204012020120201504002030020200200302003020000000000000000000000000000000000000000000000000000000000000000000000
00060000376243b6313a62137621356113461132611306152e6002d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001d51121521167150971107711067110571104711047110000000000000002170003700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000320110a7212c0210e731270311374121041197511d0512074123731277212a7212e713317132151321513205131f5131d5131b517185171651713717117170f7170d7170c7170b710000000000000000
001000002204102551260510655129051095512c0410b5512f0310e551330311155137021155513a021175513d0111b5513f0111d5513f011215513f011245413f011275313f0112a5213f0112d5113f01130515
010800002b05030070300403003030020300103001030015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
