use <agentscad/snap-joint.scad>
use <BOSL/transforms.scad>
use <NopSCADlib/vitamins/box_section.scad>

module box_body(){
    translate([wall_thickness-fi,wall_thickness+wall_clearence,bottom_clearence]){
        snap_joints(joint_quad_e);
    }

    difference(){
        cube(size_vec);
        translate([wall_thickness,wall_thickness,wall_thickness]){
            cube([size_vec[0]-wall_thickness*2,size_vec[1]-wall_thickness*2+wall_clearence*2,size_vec[2]]);
        }
    }
}

module box_top(){
    box_top_org = [wall_thickness,wall_thickness,size_vec[2]-wall_thickness];
    box_top_size = [size_vec[0]-wall_thickness*2,size_vec[1]-wall_thickness*2+wall_clearence*2,wall_thickness];
    intersection(){
        union(){
            translate([wall_thickness,wall_thickness+wall_clearence,bottom_clearence]){
                snap_joints(joint_quad_i);
            }
            translate(box_top_org){
                cube(box_top_size);
            }
        }
        translate([box_top_org[0],box_top_org[1]]){
            translate([wall_clearence,wall_clearence]){
                cube([box_top_size[0]-wall_clearence*2,box_top_size[1]-wall_clearence*2,size_vec[2]*2]);
            }
        }

    }
}

module snap_joints(source){
    translate([size_vec[0]-wall_thickness*2,0,0]){
        mirror([1,0,0]){
            linear_snap(source,joints_width);
            back(joints_spacing+joints_width+wall_clearence*2) 
                linear_snap(source,joints_width);
        }
    }

    linear_snap(source,joints_width);
    back(joints_spacing+joints_width+wall_clearence*2) 
        linear_snap(source,joints_width);
}


wall_thickness = 1.6;
wall_clearence = 0.3;
bottom_clearence = 10;
joints_spacing = 20;
joints_width = 5;
fi = 0.001;


joint_quad_i = newSnapPolygonInt (radius=10, leaves=4, springs=true );
joint_quad_e = newSnapPolygonExt ( source=joint_quad_i );

internal_joint_hight = 5.832;
external_joint_hight = getSnapJointR(joint_quad_e)/sqrt(2);


size_vec = [20,wall_thickness*2+wall_clearence*2+joints_spacing+joints_width*2,wall_thickness+bottom_clearence+internal_joint_hight];
// difference(){
//     union(){
//         box_body();
//         box_top();
//     }
//     cube(size=[100,10,100],center= true);
// }

box_body();

// box_top();
