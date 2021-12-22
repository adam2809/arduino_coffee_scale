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

module load_plate(){
    load_plate_side_len = 130;
    load_plate_height = 12;
    load_plate_thickness_top = 5.2;
    load_plate_thickness_side = 3.2;
    load_plate_gap = 3;

    load_cell_thickness = 6;
    load_cell_length = 47;

    load_cell_attachment_top_x = 12;
    load_cell_attachment_top_y = 7;
    load_cell_attachment_screw_spacing = 6;
    load_plate_attachment_screw_radious = 1.6;
    load_plate_attachment_screw_hole_depth = 6;
    load_plate_attachment_thickness = load_plate_height - load_plate_thickness_top + load_plate_gap - load_cell_thickness;

    load_plate_attachment_top_vec = [
        (load_plate_side_len-load_cell_attachment_top_x)/2,
        (load_plate_side_len-load_plate_thickness_side)-(load_plate_side_len - load_plate_thickness_side*2 - load_cell_length)/2,
        load_plate_height-load_plate_thickness_top-load_plate_attachment_thickness
    ];

    difference(){
        union(){
            chamfered_open_box([load_plate_side_len, load_plate_side_len, load_plate_height],load_plate_thickness_top,load_plate_thickness_side);
            
            translate([
                load_plate_attachment_top_vec[0]-load_plate_attachment_thickness,
                load_plate_attachment_top_vec[1]-load_plate_attachment_thickness,
                load_plate_attachment_top_vec[2]
            ]){
                difference(){
                    cube([
                        load_cell_attachment_top_x+load_plate_attachment_thickness*2,
                        load_cell_attachment_top_y+load_plate_attachment_thickness*2,
                        load_plate_attachment_thickness+fi
                    ]);
                    rotate([0,90,0]){
                        cylinder(h=load_cell_attachment_top_x+load_plate_attachment_thickness*2,r=load_plate_attachment_thickness);
                    }
                    rotate([-90,0,0]){
                        cylinder(h=load_cell_attachment_top_y+load_plate_attachment_thickness*2,r=load_plate_attachment_thickness);
                    }
                    
                    translate([
                        load_cell_attachment_top_x+load_plate_attachment_thickness*2,
                        load_cell_attachment_top_y+load_plate_attachment_thickness*2,
                        0
                    ]){
                        rotate([0,-90,0]){
                            cylinder(h=load_cell_attachment_top_x+load_plate_attachment_thickness*2,r=load_plate_attachment_thickness);
                        }
                        rotate([90,0,0]){
                            cylinder(h=load_cell_attachment_top_y+load_plate_attachment_thickness*2,r=load_plate_attachment_thickness);
                        }
                    }
                }
            }
        }
        // screw holes
        translate([
            load_plate_attachment_top_vec[0]+load_cell_attachment_top_x/2,
            load_plate_attachment_top_vec[1]+load_cell_attachment_top_y/2,
            load_plate_attachment_top_vec[2]-fi
        ]){
            screw_holes(load_cell_attachment_screw_spacing,load_plate_attachment_screw_radious,load_plate_attachment_screw_hole_depth+fi);
        }
    }
}

load_plate();

