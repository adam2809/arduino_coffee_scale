// $fa = 1;
// $fs = 0.4;

use <Chamfers-for-OpenSCAD/Chamfer.scad>;

fi=0.01;
chamfer_size = 1;

module chamfered_open_box(size_vec,top_thickness,side_thickness){
    difference(){
        chamferCube(size_vec, [[0, 0, 1, 1], [0, 1, 1, 0], [1, 1, 1, 1]], chamfer_size);
        translate([side_thickness,side_thickness,-fi]){
            cube([size_vec[0]-side_thickness*2,size_vec[1]-side_thickness*2,size_vec[2]-top_thickness+fi]);
        }
    }
}

module screw_holes(spacing,radious,depth){
    translate([-spacing/2,0]){
        cylinder(r=radious, h=depth);
    }
    translate([spacing/2,0]) {
        cylinder(r=radious, h=depth);
    }
}

module load_cell_attachment(size_vec){
    difference(){
        cube([
            size_vec[0]+size_vec[2]*2,
            size_vec[1]+size_vec[2]*2,
            size_vec[2]
        ]);

        translate([
            0,
            0,
            size_vec[2]
        ]){
            rotate([0,90,0]){
                cylinder(h=size_vec[0]+size_vec[2]*2,r=size_vec[2]);
            }
            rotate([-90,0,0]){
                cylinder(h=size_vec[1]+size_vec[2]*2,r=size_vec[2]);
            }
        }
        
        translate([
            size_vec[0]+size_vec[2]*2,
            size_vec[1]+size_vec[2]*2,
            size_vec[2]
        ]){
            rotate([0,-90,0]){
                cylinder(h=size_vec[0]+size_vec[2]*2,r=size_vec[2]);
            }
            rotate([90,0,0]){
                cylinder(h=size_vec[1]+size_vec[2]*2,r=size_vec[2]);
            }
        }
    }
}

module load_plate(
    size_vec,
    side_thickness,top_thickness,
    gap,
    load_cell_thickness,load_cell_length,
    load_cell_attachment_top_x,load_cell_attachment_top_y
){
    load_plate_attachment_thickness = size_vec[2] - top_thickness + gap - load_cell_thickness;

    load_plate_attachment_top_vec = [
        (size_vec[0]-load_cell_attachment_top_x)/2,
        (size_vec[1]-side_thickness)-(size_vec[1] - side_thickness*2 - load_cell_length)/2,
        size_vec[2]-top_thickness-load_plate_attachment_thickness
    ];

    difference(){
        union(){
            chamfered_open_box(size_vec,top_thickness,side_thickness);
            
            translate([
                load_plate_attachment_top_vec[0]-load_plate_attachment_thickness,
                load_plate_attachment_top_vec[1]+load_plate_attachment_thickness+load_cell_attachment_top_y,
                load_plate_attachment_top_vec[2]+load_plate_attachment_thickness+fi
            ]){
                rotate([180,0,0]){
                    load_cell_attachment([load_cell_attachment_top_x,load_cell_attachment_top_y,load_plate_attachment_thickness+fi]);
                }
            }
        }
        // screw holes
        translate([
            load_plate_attachment_top_vec[0]+load_cell_attachment_top_x/2,
            load_plate_attachment_top_vec[1]+load_cell_attachment_top_y/2,
            load_plate_attachment_top_vec[2]-fi
        ]){
            children(0);
        }
    }
}

module body(size_vec,side_thickness,bottom_thickness,gap){

    translate([0,size_vec[1],-gap]){
        rotate([180,0,0]){
            chamfered_open_box(size_vec,bottom_thickness,side_thickness);
        }
    }
}
load_plate_size_vec = [130,130,12];
load_plate_thickness_side = 3.2;
load_plate_thickness_top = 5.2;
load_plate_gap = 3;

load_cell_attachment_screw_spacing = 6;
load_plate_attachment_screw_radious = 1.6;
load_plate_attachment_screw_hole_depth = 6;


load_cell_thickness = 6;
load_cell_length = 47;

load_cell_attachment_top_x = 12;
load_cell_attachment_top_y = 7;


load_plate(
    load_plate_size_vec,
    load_plate_thickness_side,load_plate_thickness_top,
    load_plate_gap,
    load_cell_thickness,load_cell_length,
    load_cell_attachment_top_x,load_cell_attachment_top_y
){            
    screw_holes(load_cell_attachment_screw_spacing,load_plate_attachment_screw_radious,load_plate_attachment_screw_hole_depth+fi);
};
// body(
//     [load_plate_side_len,load_plate_side_len,load_plate_height],
//     load_plate_thickness_side,
//     load_plate_thickness_top,
//     load_plate_gap
// );

