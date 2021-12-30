use <util.scad>
use <BOSL/transforms.scad>
use <agentscad/snap-joint.scad>

fi=0.01;
snaps_clearence = 0.2;

module display_cover(
    base_size_vec,
    length,width,wall_thickness,
    slant_offset,chamfer_size,top_thickness,
    display_pcb_height,display_pcb_width,
    display_height,display_width,
    display_wall_thickness,display_cutout_offset_on_top,
    display_offset_on_pcb,
    button_cutout_r,buttons_offset,buttons_spacing
){
    
    // translate([width,0,0]){
    //     rotate([-90,0,90]){
    //         display_cover_body(
    //             base_size_vec,
    //             length+fi,
    //             width,
    //             wall_thickness,
    //             slant_offset,
    //             chamfer_size
    //         );
    //     }
    // }


    joint_quad_e = newSnapPolygonInt (radius=10, leaves=4, springs=true );
    joint_quad_i = newSnapPolygonExt ( source=joint_quad_e );

    internal_joint_hight = 5.832;
    external_joint_hight = getSnapJointR(joint_quad_e)/sqrt(2);


    y = -slant_offset/length*wall_thickness+base_size_vec[2];
    top_length = pitagora(length,slant_offset)-pitagora(base_size_vec[2]-y,wall_thickness);


    forward(fi)
    snap_joints(
        [width-wall_thickness*2,length-wall_thickness+fi*2],
        wall_thickness,
        joint_quad_i,5,external_joint_hight,true,slant_offset
    );
    snap_joints(
        [width-wall_thickness*2,length-wall_thickness],
        wall_thickness,
        joint_quad_e,5,external_joint_hight,false,slant_offset
    );

    // translate([wall_thickness,0,-base_size_vec[2]]){
        display_cover_top(
            base_size_vec,
            length+fi,
            width,
            wall_thickness,
            slant_offset,
            top_thickness,
            display_pcb_height,display_wall_thickness,display_cutout_offset_on_top,
            buttons_offset
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
            screw_holes(buttons_spacing,button_cutout_r,top_thickness*3);
        };
    // }
}

pitagora = function (x,y) sqrt(pow(x,2) + pow(y,2));
module display_cover_top(
    base_size_vec,
    length,width,wall_thickness,
    slant_offset,top_thickness,
    display_pcb_height,display_wall_thickness,display_cutout_offset_on_top,buttons_offset

){
    intersection(){
        rotate([atan((slant_offset)/length),0,0]){
            y = -slant_offset/length*wall_thickness+base_size_vec[2];
            top_length_inc_wall = pitagora(length,slant_offset);
            difference(){
                cube([width,length*2,top_thickness]);
                translate([display_cutout_offset_on_top,(top_length_inc_wall-display_pcb_height)/2,display_wall_thickness-top_thickness]){
                    children(0);

                }
                translate([buttons_offset,top_length_inc_wall/2,-top_thickness]) children(1);
            }
        }
        translate([0,0,-fi])
        cube([width-wall_thickness*2,length-wall_thickness,length]);
    }
}

module snap_joints(size_vec,wall_thickness,source,joints_width,joints_height,extra_support=false,slant_offset){
    upper_offset = slant_offset-wall_thickness/4-joints_height;
    lower_offset = joints_height-wall_thickness/2;
    translate([size_vec[0],0,0]){
        mirror([1,0,0]){
            rotate([0,0,90]){
                forward(joints_width) down(lower_offset){
                    linear_snap(source,joints_width,extra_support);
                }
            }
            back(size_vec[1]) up(upper_offset){
                rotate([0,0,-90]) linear_snap(source,joints_width,extra_support);
            }
        }
    }
    rotate([0,0,90]){
        forward(joints_width) down(lower_offset){
            linear_snap(source,joints_width,extra_support);
        }
    }
    back(size_vec[1]) up(upper_offset){
        rotate([0,0,-90]) linear_snap(source,joints_width,extra_support);
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
}
