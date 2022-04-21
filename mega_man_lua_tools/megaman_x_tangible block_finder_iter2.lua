current_stage_number = mainmemory.read_u8(0x1f7A)
function getPositions()
		MMan_X_pos_two_most_sig_bit = mainmemory.read_u8(0x0BAE); --megamans x position for how many rooms (aka 16 by 16 tiles) megaman is from the left edge of the stage
		MMan_X_pos_two_least_sig_bit = mainmemory.read_u8(0x0BAD); --megamans x position tile and pixel count
		MMan_Y_pos_two_most_sig_bit = mainmemory.read_u8(0x0BB1); --megamans Y position for how many rooms (aka 16 by 16 tiles) megaman is from the top edge of the stage
		MMan_Y_pos_two_least_sig_bit = mainmemory.read_u8(0x0BB0); --megamans y position tile and pixel count	
		MegaManX =  MMan_X_pos_two_most_sig_bit*0x100 + MMan_X_pos_two_least_sig_bit;
		MegaManY =  MMan_Y_pos_two_most_sig_bit*0x100 + MMan_Y_pos_two_least_sig_bit;
		MMan_X_pos = memory.read_u32_le(0x0BAC);
		MMan_Y_pos = memory.read_u32_le(0x0BB0);
end
function moveMegaman()
	X_write = math.floor(MMan_X_pos/0x1000)*0x1000 + 0x800
	Y_write = MMan_Y_pos - 0x10
	print(x_write)
	memory.write_u32_le(0x0BAC, X_write)
	memory.write_u32_le(0x0BB0, Y_write)
end
function hex_address_finder_iter_2(X_most_sig_bit,X_second_least_sig_bit,Y_most_sig_bit,Y_second_least_sig_bit) --oficiall hexidecial address return
	--this will need more 
	local offset_input = 0x2000
	if(current_stage_number == 0) --this if state hiearchy is meant to database the offsets all megaman stages and levels have
		then
		if(Y_most_sig_bit==1) then
			offset_input = 0x2200;
	elseif(Y_most_sig_bit==2)
		then
			offset_input = 0x4C00;
		end
	elseif(current_stage_number == 8) then -- chill penguin stage
		if(Y_most_sig_bit==0x4) then
			offset_input = 0x6E00
		end
	elseif(current_stage_number == 3) then -- armor armadillo stage
		if(Y_most_sig_bit==0x1) then
			offset_input = 0x2400
		end
	elseif(current_stage_number == 6) then -- spark mandrill stage
		if(Y_most_sig_bit==0x3) then
			offset_input = 0x3A00
		end
	elseif(current_stage_number == 7) then -- Kuwanger stage
		if(Y_most_sig_bit==0x17) then
			offset_input = 0x7200
		end
	elseif(current_stage_number == 4) then -- Mammoth stage
		if(Y_most_sig_bit==0x2) then
			offset_input = 0x3800
		end
	elseif(current_stage_number == 2) then -- Chameleon stage
		if(Y_most_sig_bit==0x2) then
			offset_input = 0x5600
		end
	end
	hex_address_return = 0x200*X_most_sig_bit + 0x2*X_second_least_sig_bit + 0x20*Y_second_least_sig_bit + offset_input;
	return hex_address_return
end

--should start before the do while loop and 	
getPositions()
x = MegaManX
y1 = MegaManY + 0x20
y2 = MegaManY + 16
new_block_under_MMan = hex_address_finder_iter_2(math.floor(x/0x100),math.floor((x%0x100)/0x10),math.floor(y2/0x100),math.floor((y2%0x100)/0x10))
solid_tile_value = memory.read_u32_le(hex_address_finder_iter_2(math.floor(x/0x100),math.floor((x%0x100)/0x10),math.floor(y1/0x100),math.floor((y1%0x100)/0x10)))%0x10000
moveMegaman()
Y_write1 = Y_write
X_write1 = X_write
memory.write_u32_le(new_block_under_MMan, solid_tile_value)
frame_count = 0
loop_count = 0;
tile_value = 857--0x0
passable_tile = {}
hard_tile = {};
incline_tile = {};
hurt_tile = {};
--passable_tile[1] = solid_tile_value
--print(memory.read_u32_le(0x0BAC))
--varibles for controlling timming

while true do
	getPositions()
	y3 = MMan_Y_pos-Y_write1
	MMan_state = mainmemory.read_u8(0x0BAA)
	if(frame_count == 35) then
	frame_count = 0
	end
	if(frame_count == 0) then
	memory.write_u32_le(new_block_under_MMan, tile_value)
	
	elseif(frame_count == 29 and y3 ==16) then
	table.insert(passable_tile,tile_value)
	memory.write_u32_le(new_block_under_MMan, solid_tile_value)
	memory.write_u32_le(0x0BAC, X_write1)
	memory.write_u32_le(0x0BB0, Y_write1)
	memory.write_u32_le(new_block_under_MMan, solid_tile_value)
	print('passable_tile', passable_tile[#passable_tile])
	tile_value = tile_value+1
	elseif(frame_count == 29 and y3 ==0) then
		table.insert(hard_tile,tile_value)
		tile_value = tile_value+1
		print('hard_tile', hard_tile[#hard_tile])
	elseif(frame_count == 29 and y3 ~=0 and y3 ~=16) then
	table.insert(incline_tile,tile_value)
	memory.write_u32_le(new_block_under_MMan, solid_tile_value)
	memory.write_u32_le(0x0BAC, X_write1)
	memory.write_u32_le(0x0BB0, Y_write1)
	tile_value = tile_value+1
	print('incline_tile', incline_tile[#incline_tile])
	elseif(MMan_state == 0xE) then
		table.insert(hurt_tile,tile_value)
		for n = 1,300 do
			emu.frameadvance()
		end	
	memory.write_u32_le(new_block_under_MMan, solid_tile_value)
	memory.write_u32_le(0x0BAC, X_write1)
	memory.write_u32_le(0x0BB0, Y_write1)
	mainmemory.write_u8(0x0BAA,0x0200)
	mainmemory.write_u16_le(0x0BCE,0x1000)
	frame_count = 30
	tile_value = tile_value+1
	print('hurt_tile', hurt_tile[#hurt_tile])
	end
	getPositions()
	health = memory.read_u32_le(0x0BCE)%0x10000;
	--print(health)
	if(health == 0 or MMan_state == 0xC) then
	--print(tile_value)
	return 0
	end
	
	--print(loop_count)
	if (loop_count == 200 and hard_tile[1] ~= nil and passable_tile[1] ~= nil )		
		then
		loop_count = 0
		current_level = current_stage_number
		OpenFolder =  bizstring.hex(current_level)..'.txt'
		passable_tile_info_pass = tostring(passable_tile[1])
		for i = 2, #passable_tile do
			passable_tile_info_pass = passable_tile_info_pass.. ',' ..tostring(passable_tile[i])
		end
		hard_tile_info_pass = tostring(hard_tile[1])
		for i = 2, #hard_tile do
			hard_tile_info_pass = hard_tile_info_pass.. ',' ..tostring(hard_tile[i])
		end
		file_to_hold_values= io.open( OpenFolder, "w" )
		file_to_hold_values:write('passables_set = ')
		file_to_hold_values:write('{')
		file_to_hold_values:write(passable_tile_info_pass)
		file_to_hold_values:write('} \n')
		file_to_hold_values:write('hard_tile_set = {')
		file_to_hold_values:write(hard_tile_info_pass)
		file_to_hold_values:write('}')
		
		if(incline_tile[1] ~= nil) then
		incline_tile_info_pass = tostring(incline_tile[1])
		for i = 2, #incline_tile do
			incline_tile_info_pass = incline_tile_info_pass.. ',' ..tostring(incline_tile[i])
		end
		file_to_hold_values:write('\n')
		file_to_hold_values:write('incline_tile_set = {')
		file_to_hold_values:write(incline_tile_info_pass)
		file_to_hold_values:write('}')
		end
		
		if(hurt_tile[1] ~= nil) then
		hurt_tile_info_pass = tostring(hurt_tile[1])
		for i = 2, #hurt_tile do
			hurt_tile_info_pass = hurt_tile_info_pass.. ',' ..tostring(hurt_tile[i])
		end
		file_to_hold_values:write('\n')
		file_to_hold_values:write('hurt_tile = {')
		file_to_hold_values:write(hurt_tile_info_pass)
		file_to_hold_values:write('}')
		end
		
		
		io.close(file_to_hold_values)
	elseif(loop_count == 200) then
		loop_count = 0
	end
	
	
	--moveMegaman()
	emu.frameadvance();
	frame_count = frame_count + 1
	loop_count = loop_count + 1
	if(tile_value > 1400) then
	return 0
	end
end