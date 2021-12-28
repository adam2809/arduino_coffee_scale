use <util.scad>

fi=0.01;

module display_cover(
    base_size_vec,
    length,width,wall_thickness,
    slant_offset,chamfer_size,top_thickness,
    display_pcb_height,display_pcb_width,
    display_height,display_width,
    display_wall_thickness,display_cutout_offset_on_top,
    display_offset_on_pcb
){
    small_screw_r = 1;
    small_screw_head_r = 1.5;
    small_screw_length = 6;
    small_screw_head_height = 2;

    y = -slant_offset/length*wall_thickness+base_size_vec[2];
    top_length = pitagora(length,slant_offset)-pitagora(base_size_vec[2]-y,wall_thickness);
    
    translate([width,0,0]){
        rotate([-90,0,90]){
            display_cover_body(
                base_size_vec,
                length+fi,
                width,
                wall_thickness,
                slant_offset,
                chamfer_size
            ){
                translate([0,base_size_vec[2]-(top_thickness),width-wall_thickness])
                rotate([90,90,-atan((slant_offset)/length)])
                display_cover_base_screw_holes(
                    small_screw_r,
                    small_screw_head_r,
                    small_screw_length,
                    0.12+small_screw_head_r,
                    [width-wall_thickness*2,top_length]
                );
            };
        }
    }


    translate([wall_thickness,0,-base_size_vec[2]]){
        display_cover_top(
            base_size_vec,
            length+fi,
            width,
            wall_thickness,
            slant_offset,
            top_thickness,
            display_pcb_height,display_wall_thickness,display_cutout_offset_on_top
        ){
            translate([display_pcb_width,display_pcb_height,top_thickness]){
                rotate([0,270,90]){
                    perf_board_cutout(
                        [top_thickness,display_pcb_width,display_pcb_height],
                        [display_offset_on_pcb],
                        [[display_width,display_height]],
                        (display_pcb_height-display_height)/2
                    );
                }
            }
        };
    }
}

module display_cover_top(
    base_size_vec,
    length,width,wall_thickness,
    slant_offset,top_thickness,
    display_pcb_height,display_wall_thickness,display_cutout_offset_on_top

){
    intersection(){
        rotate([atan((slant_offset)/length),0,0]){
            y = -slant_offset/length*wall_thickness+base_size_vec[2];
            top_length = pitagora(length,slant_offset)-pitagora(base_size_vec[2]-y,wall_thickness);
            difference(){
                cube([width,length,top_thickness]);
                translate([display_cutout_offset_on_top,(top_length-display_pcb_height)/2,-top_thickness+display_wall_thickness]){
                    children(0);

                }
            }
        }
        translate([0,0,-fi])
        cube([width-wall_thickness*2,length-wall_thickness,length]);
    }
}


module display_cover_body(base_size_vec,length,width,wall_thickness,slant_offset,chamfer_size){
    difference(){
        linear_extrude(height=width){
            polygon([
                [0,0],
                [0,base_size_vec[2]],
                [length,base_size_vec[2]-slant_offset],
                [length,chamfer_size],
                [length-chamfer_size,0],
                [length,0]
            ]);
            translate([-(chamfer_size),0]){
                square(chamfer_size+fi);
            }
        }
        translate([-fi,wall_thickness,wall_thickness]){
            cube([length-wall_thickness+fi,base_size_vec[2]+fi,width-wall_thickness*2]);
        }
        translate([length*0.5,0,0]){
            translate([0,0,width]){
                rotate([45,0,0]){
                    cube([length*2,chamfer_size*sqrt(2),chamfer_size*sqrt(2)],center=true);
                }
            }
            rotate([45,0,0]){
                cube([length*2,chamfer_size*sqrt(2),chamfer_size*sqrt(2)],center=true);
            }
        }
    }
    screw_support_radious = 2.5;
    screw_support_height = 4 ;

    z_offset = base_size_vec[2]-wall_thickness;
    y_offset = -19.5;
    difference(){
        // intersection(){
        //     union(){
        //         screw_support(
        //             screw_support_radious+0.5,screw_support_height,
        //             wall_thickness,-atan((slant_offset)/length),
        //             [wall_thickness,0,z_offset]
        //         );
        //         screw_support(
        //             screw_support_radious+0.5,screw_support_height,
        //             wall_thickness,-atan((slant_offset)/length),
        //             [width-wall_thickness,0,z_offset]
        //         );
                
        //         screw_support(
        //             screw_support_radious,screw_support_height,
        //             wall_thickness,-atan((slant_offset)/length),
        //             [wall_thickness,y_offset,z_offset]
        //         );
        //         screw_support(
        //             screw_support_radious,screw_support_height,
        //             wall_thickness,-atan((slant_offset)/length),
        //             [width-wall_thickness,y_offset,z_offset]
        //         );
        //     }
        //     rotate([0,-90,0])
        //     translate([0,0,-length])
        //     cube([width,base_size_vec[2],length]);
        // }
        children(0);
    }
}

module screw_support(radious,height,wall_thickness,angle,offset_vec){
    translate([0,0,offset_vec[0]])
    rotate([90,0,0])
    translate([0,0,-offset_vec[2]+0.150])
    rotate([0,angle,0])
    translate([-offset_vec[1],0,0])
    color("blue")
    cylinder(h=height,r=radious);
}



module display_cover_base_screw_holes(
    r,
    head_r,
    length,
    spacing_from_corners,
    size_vec
){
    translate([size_vec[0]/2,0]){
        translate([0,spacing_from_corners])
        screw_holes(size_vec[0]-spacing_from_corners*2,r,length);

        translate([0,size_vec[1]-spacing_from_corners])
        screw_holes(size_vec[0]-spacing_from_corners*2,r,length);
    }
}
