
module screw_holes(spacing,radious,depth){
    translate([-spacing/2,0]){
        cylinder(r=radious, h=depth);
    }
    translate([spacing/2,0]) {
        cylinder(r=radious, h=depth);
    }
}

module perf_board_cutout(size_vec,offsets_vec,cutout_sizes_vec,offset_from_top=0){
    cube(size_vec);
    for(i=[0:len(offsets_vec)-1]){
        translate([-size_vec[0],offsets_vec[i],size_vec[2]-cutout_sizes_vec[i][1]-offset_from_top]){
            cube([size_vec[0]*1.5, cutout_sizes_vec[i][0], cutout_sizes_vec[i][1]]);
        }
    }
}
function pitagora(x,y) = sqrt(pow(x,2) + pow(y,2));
