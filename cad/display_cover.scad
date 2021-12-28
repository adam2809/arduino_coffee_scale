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
    
    translate([width,0,0]){
        rotate([-90,0,90]){
            display_cover_body(
                base_size_vec,
                length+fi,
                width,
                wall_thickness,
                slant_offset,
                chamfer_size
            );
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

pitagora = function (x,y) sqrt(pow(x,2) + pow(y,2));
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
    screw_support_height = 3;

    screw_support(screw_support_radious,screw_support_height,wall_thickness,-atan((slant_offset)/length),wall_thickness);
    screw_support(screw_support_radious,screw_support_height,wall_thickness,-atan((slant_offset)/length),width-wall_thickness);
}

module screw_support(radious,height,wall_thickness,angle,x_offset){
    translate([0,height,x_offset])
    rotate([90,0,0])
    translate([0,0,-12])
    rotate([0,angle,0])
    color("blue")
    cylinder(h=height,r=radious);
}
