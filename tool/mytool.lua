function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


table.print = print_r

function debugPrintTable(table)
    for k,v in pairs(table) do
        print(k,v:getName())
    end
end

gtool = {}

function gtool:ccpToInt(pos)
    if type(pos) == type({}) and pos.x and pos.y then
        return pos.x*10+pos.y
    else
        print("gtool:ccpToInt warning: pos is type: "..type(pos))
        return pos 
    end
end

function gtool:intToCcp(num)
    if type(num) == type(1) then 
        return cc.p(math.modf(num/10),num%10) 
    else
        print("gtool:intToCcp warning: num is type: "..type(num))
        return num
    end
end

function gtool:normalizeTowards(towards)
    local normal_towards = towards
    if towards%6 == 0 then
        normal_towards = 6
    elseif towards > 6 then
        normal_towards = towards%6
    elseif towards < 0 then
        normal_towards = math.abs(-math.floor(towards/6)*6 + 6 + towards)%6
    end

    return normal_towards
end

function gtool:isLegalPosNum( pos )
    if pos > 11 and pos%10<8 and pos%10 > 0
        and pos ~= 17 and (pos < 78 or pos == 83 or pos == 85) then
        return true
    end

    return false
end