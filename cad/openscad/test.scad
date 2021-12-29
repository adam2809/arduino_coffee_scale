use <agentscad/snap-joint.scad>
use <BOSL/transforms.scad>
use <NopSCADlib/vitamins/box_section.scad>


wall_thickness = 1.6;
wall_clearence = 0.3;
bottom_clearence = 3;
joints_spacing = 20;
joints_width = 5;
fi = 0.001;


joint_quad_i = newSnapPolygonInt (radius=10, leaves=4, springs=true );
joint_quad_e = newSnapPolygonExt ( source=joint_quad_i );

internal_joint_hight = 5.832;
external_joint_hight = getSnapJointR(joint_quad_e)/sqrt(2);

size_vec = [20,wall_thickness*2+wall_clearence*2+joints_spacing,wall_thickness+bottom_clearence+internal_joint_hight];

translate([wall_thickness-fi,wall_thickness+wall_clearence,wall_thickness+bottom_clearence]){
    linear_snap(joint_quad_i,joints_width);
    linear_snap(joint_quad_e,joints_width);

    back(joints_spacing-wall_clearence*2-joints_width){
        linear_snap(joint_quad_i,joints_width);
        linear_snap(joint_quad_e,joints_width);
    }
}

difference(){
    cube(size_vec);
    translate([wall_thickness,wall_thickness,wall_thickness]){
        cube([size_vec[0]-wall_thickness*2,size_vec[1]-wall_thickness*2+wall_clearence*2,size_vec[2]]);
    }
}


