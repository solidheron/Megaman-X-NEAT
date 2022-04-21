function position_parser(pos_x,pos_y)
    --this is to only be used for finding the hexidecimal address
    X_most_sig_bit=math.floor(pos_x/0x100);
    X_second_least_sig_bit=math.floor((pos_x%0x100)/0x10);
    Y_most_sig_bit=math.floor(pos_y/0x100);
    Y_second_least_sig_bit=math.floor((pos_y%0x100)/0x10);
    return_data = {X_most_sig_bit,X_second_least_sig_bit,Y_most_sig_bit,Y_second_least_sig_bit}
    --for i =1,4 do
    --    print(return_data[i])
    --end
end
function offest_calc(pos_x,pos_y,hex_address)
    X_most_sig_bit=math.floor(pos_x/0x100);
    X_second_least_sig_bit=math.floor((pos_x%0x100)/0x10);
    Y_second_least_sig_bit=math.floor((pos_y%0x100)/0x10);
    --print(X_most_sig_bit)
    --print(X_second_least_sig_bit)
    --print(Y_second_least_sig_bit)
    offset = hex_address - 0x200*X_most_sig_bit - 0x2*X_second_least_sig_bit - 0x20*Y_second_least_sig_bit
    print(offset)
    return offset
end
