%inputs: v,o where v is vicon data and o is odometry data (visual
%odometrey)
%output: visual odometry data that is position (x,y,z) aligned with vicon 
%data

function out = offset(v,o)

if v(1) > 0 && o(1) > 0
    if v(1) > v(1)
        o_offset = v(1) - o(1);
        out = o + o_offset;
    else o_offset = o(1) - v(1);
        out = o - o_offset;
    end
end

if v(1) > 0 && o(1) < 0
    o_offset = v(1) - o(1);
    out = o + o_offset;
end
 
if v(1) < 0 && o(1) > 0
   o_offset = o(1) - v(1);
   out = o - o_offset;
end

if v(1) < 0 && o(1) < 0
   if v(1) > o(1)
      o_offset = v(1) - o(1);
      out = o + o_offset;
   else o_offset = o(1) - v(1);
       out = o - o_offset;
   end
end
   
if v(1) == 0
    out = o - o(1);
end
    
end