$fa = 1;
$fs = 0.4;

use <Chamfers-for-OpenSCAD/Chamfer.scad>;

fi=0.01;
chamfer_size = 1;

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
    difference(){
        union(){
            difference(){
                chamferCube([load_plate_side_len, load_plate_side_len, load_plate_height], [[0, 0, 1, 1], [0, 1, 1, 0], [1, 1, 1, 1]], chamfer_size);
                translate([load_plate_thickness_side,load_plate_thickness_side,-fi]){
                    cube([load_plate_side_len-load_plate_thickness_side*2,load_plate_side_len-load_plate_thickness_side*2,load_plate_height-load_plate_thickness_top+fi]);
                }
            }
            
            translate([
                (load_plate_side_len-load_cell_attachment_top_x)/2,
                (load_plate_side_len - load_plate_thickness_side*2 - load_cell_length)/2,
                load_plate_height-load_plate_thickness_top-load_plate_attachment_thickness
            ]){
                cube([load_cell_attachment_top_x,load_cell_attachment_top_y,load_plate_attachment_thickness+fi]);
            }
        }
        translate([
            (load_plate_side_len-load_cell_attachment_top_x)/2,
            (load_plate_side_len - load_plate_thickness_side*2 - load_cell_length)/2,
            load_plate_height-load_plate_thickness_top-load_plate_attachment_thickness-fi
        ]){
            translate([(load_cell_attachment_top_x - load_cell_attachment_screw_spacing)/2,load_cell_attachment_top_y/2]){
                cylinder(r=load_plate_attachment_screw_radious, h=load_plate_attachment_screw_hole_depth+fi, center=true);
                translate([load_cell_attachment_screw_spacing,0]) {
                    cylinder(r=load_plate_attachment_screw_radious, h=load_plate_attachment_screw_hole_depth+fi, center=true);
                }
            }
        }
    }
}

load_plate();

