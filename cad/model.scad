$fa = 1;
$fs = 0.4;

use <Chamfers-for-OpenSCAD/Chamfer.scad>;
use <display_cover.scad>;
use <util.scad>

fi=0.01;
chamfer_size = 1;

module load_plate(
    size_vec,
    side_thickness,top_thickness,
    load_cell_attachment_top_x,load_cell_attachment_top_y,attachment_thickness,
    load_cell_length
){
    load_plate_attachment_top_vec = [
        (size_vec[0]-load_cell_attachment_top_x)/2,
        (size_vec[1] - load_cell_length)/2,
        size_vec[2]-top_thickness-attachment_thickness
    ];

    difference(){
        union(){
            chamfered_open_box(size_vec,top_thickness,side_thickness);
            
            translate([
                load_plate_attachment_top_vec[0]-attachment_thickness,
                load_plate_attachment_top_vec[1]+attachment_thickness+load_cell_attachment_top_y,
                load_plate_attachment_top_vec[2]+attachment_thickness+fi
            ]){
                rotate([180,0,0]){
                    load_cell_attachment([load_cell_attachment_top_x,load_cell_attachment_top_y,attachment_thickness+fi]);
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

module chamfered_open_box(size_vec,top_thickness,side_thickness){
    difference(){
        chamferCube(size_vec, [[0, 0, 1, 1], [0, 1, 1, 0], [1, 1, 1, 1]], chamfer_size);
        translate([side_thickness,side_thickness,-fi]){
            cube([size_vec[0]-side_thickness*2,size_vec[1]-side_thickness*2,size_vec[2]-top_thickness+fi]);
        }
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


module base(
    size_vec,
    side_thickness,bottom_thickness,
    attachment_top_x,attachment_top_y,attachment_thickness,
    load_cell_length,
    perf_board_wall_thickness,perf_board_offset_inside_base,perf_board_size_vec,
    display_cover_width
){
    difference(){
        load_plate(
            size_vec,
            side_thickness,bottom_thickness,
            attachment_top_x,attachment_top_y,attachment_thickness,
            load_cell_length
        ){
            children(0);
        };


        translate([
            (size_vec[0]-load_cell_attachment_top_x)/2+attachment_top_x/2,
            (size_vec[1] - load_cell_length)/2+attachment_top_y/2,
            size_vec[2]+fi
        ]){
            rotate([0,180,0]){
                children(1);
            }
        }


        translate([
            perf_board_wall_thickness,
            size_vec[1]-side_thickness-perf_board_offset_inside_base,
            perf_board_size_vec[2]-fi]
        ){
            rotate([180,0,0]){
                children(2);
            }
        }


        load_plate_attachment_top_vec = [
            (size_vec[0]-load_cell_attachment_top_x)/2,
            (size_vec[1] - load_cell_length)/2,
            size_vec[2]-bottom_thickness-attachment_thickness
        ];
        translate([
            load_plate_attachment_top_vec[0]- attachment_thickness,
            load_plate_attachment_top_vec[1]-(attachment_thickness+fi),
            size_vec[2]-bottom_thickness- attachment_thickness
        ]){
            cube([
                perf_board_size_vec[0]-(size_vec[0]/2-(attachment_top_x/2+attachment_thickness)-side_thickness)+0.5,
                attachment_thickness*4,
                attachment_thickness
            ]);
        }


        translate([size_vec[0]/2,size_vec[1]-side_thickness/2-fi,(size_vec[2]-bottom_thickness)/2])
        children(5);
    }
    translate([
        side_thickness-fi,
        size_vec[1]-side_thickness-perf_board_offset_inside_base-perf_board_size_vec[1],
        size_vec[2]-bottom_thickness+fi
    ]){
        children(3);
    }
    translate([size_vec[0]/2 - display_cover_width/2,size_vec[1]-fi,size_vec[2]]){
        children(4);
    }
}


module perf_board_rails(perf_board_size_vec,rails_size_vec,wall_thickness){
    rail_size_vec = [perf_board_size_vec[0],rails_size_vec[0],rails_size_vec[1]];
    translate([0,0,-rails_size_vec[1]]){
        cube(rail_size_vec);
        translate([0,perf_board_size_vec[1],0]){
            cube(rail_size_vec);
        }
    }
}


load_plate_size_vec = [125,125,12];
load_plate_thickness_side = 2.4;
load_plate_thickness_top = 5.2;
load_plate_gap = 3;

load_cell_attachment_screw_spacing = 6;
load_plate_attachment_screw_radious = 1.6;
load_plate_attachment_screw_hole_depth = 6;


load_cell_thickness = 6;
load_cell_length = 47;

load_cell_attachment_top_x = 12;
load_cell_attachment_top_y = 7;


base_size_vec = [load_plate_size_vec[0],load_plate_size_vec[1],16.6];
base_thickness_bottom = load_plate_thickness_side;
base_attachment_screw_radious = 1.5;
base_attachment_screw_head_radious = 3;
base_attachment_screw_head_height = 2.5;
base_attachment_screw_hole_depth = base_size_vec[2]*2;
attachment_thickness = (load_plate_size_vec[2]+base_size_vec[2]+load_plate_gap-(load_plate_thickness_top+base_thickness_bottom+load_cell_thickness))/2;
// translate([load_plate_size_vec[0],0,-load_plate_gap]){
//     rotate([0,180,0]){
//         load_plate(
//             load_plate_size_vec,
//             load_plate_thickness_side,load_plate_thickness_top,
//             load_cell_attachment_top_x,load_cell_attachment_top_y,attachment_thickness,
//             load_cell_length
//         ){            
//             screw_holes(load_cell_attachment_screw_spacing,load_plate_attachment_screw_radious,load_plate_attachment_screw_hole_depth+fi);
//         };
//     }
// }


charger_usb_hole_offset_on_perf_board = 11.4;
nano_usb_hole_offset_on_perf_board = 30.4;

perf_board_size_vec = [50,70,13+fi];
perf_board_offset_inside_base = 30;
perf_board_attachment_rails_height = 1.7;
perf_board_attachment_rails_width = 3.5;
perf_board_wall_thickness = 0.4;


display_cover_width = 60;
display_cover_length = 20;
display_cover_slant_offset = 8.3;
display_cover_wall_thickness = 2;

display_cover_top_thickness = 2.4;

display_cover_cable_clearence_height = 2;
display_cover_cable_clearence_width = 10;

// base(
//     base_size_vec,
//     load_plate_thickness_side,base_thickness_bottom,
//     load_cell_attachment_top_x,load_cell_attachment_top_y,attachment_thickness,
//     load_cell_length,
//     perf_board_wall_thickness,perf_board_offset_inside_base,perf_board_size_vec,
//     display_cover_width
// ){            
//     screw_holes(
//         load_cell_attachment_screw_spacing,
//         base_attachment_screw_radious,
//         base_attachment_screw_hole_depth
//     );
//     screw_holes(
//         load_cell_attachment_screw_spacing,
//         base_attachment_screw_head_radious+fi,
//         base_attachment_screw_head_height+fi
//     );

//     perf_board_cutout(
//         perf_board_size_vec,
//         [nano_usb_hole_offset_on_perf_board,charger_usb_hole_offset_on_perf_board],
//         [[8.6,6],[9.6,4.6]]
//     );
//     perf_board_rails(perf_board_size_vec,[3.5,1.7]);

    display_cover(
        base_size_vec,
        display_cover_length,
        display_cover_width,
        display_cover_wall_thickness,
        display_cover_slant_offset,
        chamfer_size,
        display_cover_top_thickness,
        display_pcb_height,display_pcb_width,
        display_height,display_width,
        display_wall_thickness,display_cutout_offset_on_top,
        display_offset_on_pcb
    );


    // cube([display_cover_cable_clearence_width,load_plate_thickness_side+fi*2,display_cover_cable_clearence_height],center= true);
// };

display_offset_on_pcb = 6.5;
display_pcb_width = 33;
display_pcb_height = 13;
display_width = 21;
display_height = 11;
display_wall_thickness = 0.2;
display_cutout_offset_on_top = 2;


