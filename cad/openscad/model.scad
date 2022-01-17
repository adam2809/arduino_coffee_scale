$fa = 1;
$fs = 0.4;

use <Chamfers-for-OpenSCAD/Chamfer.scad>;
use <display_cover.scad>;
use <util.scad>
use <BOSL/transforms.scad>

fi=0.01;
chamfer_size = 1.5;
sack_layer_t = 0.2;

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
    display_cover_width,screw_head_height
){
    
    switch_cutout_w=15.2;
    switch_cutout_h=8.75;
    switch_cutout_pos=[size_vec[0],size_vec[1]*2/3,switch_cutout_h/2];
    switch_support_len=5;
    switch_border_t=(10.45-switch_cutout_h)/2;
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
            perf_board_size_vec[2]-fi
        ]){
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
                perf_board_size_vec[0]-(size_vec[0]/2-(attachment_top_x/2+attachment_thickness)-side_thickness)+3,
                attachment_thickness*4,
                attachment_thickness
            ]);
        }


        translate([size_vec[0]/2,size_vec[1]-side_thickness/2-fi,(size_vec[2]-bottom_thickness)/2])
        children(5);

        translate(switch_cutout_pos) up((size_vec[2]-chamfer_size)/2 - switch_cutout_h/2)
        cube([side_thickness*3,switch_cutout_w,switch_cutout_h],center = true);
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
    translate([switch_cutout_pos[0]-switch_support_len-side_thickness,switch_cutout_pos[1]]){
        forward(switch_cutout_w/2+side_thickness)
        cube([switch_support_len,side_thickness,size_vec[2]-bottom_thickness]);
        back(switch_cutout_w/2)
        cube([switch_support_len,side_thickness,size_vec[2]-bottom_thickness]);

    }

    translate([
        (size_vec[0]-load_cell_attachment_top_x)/2+attachment_top_x/2,
        (size_vec[1] - load_cell_length)/2+attachment_top_y/2,
        size_vec[2]-screw_head_height
    ]){
        rotate([0,180,0]){
            children(6);
        }
    }
}


module perf_board_rails(perf_board_size_vec,rails_size_vec,wall_thickness){
    rail_size_vec = [perf_board_size_vec[0],rails_size_vec[0],rails_size_vec[1]];
    translate([0,0,-rails_size_vec[1]]){
        cube(rail_size_vec);
        translate([0,perf_board_size_vec[1],0]){
            forward(rails_size_vec[0]) cube(rail_size_vec);
        }
    }
}


load_plate_size_vec = [125,125,12];
load_plate_thickness_side = 2.4;
load_plate_thickness_top = 3.2;
load_plate_gap = 3;

load_cell_attachment_screw_spacing = 6;
load_plate_attachment_screw_radious = 1.35;
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


charger_usb_hole_offset_on_perf_board = 10.55;
nano_usb_hole_offset_on_perf_board = 29.5;

perf_board_size_vec = [50.5,70.5,13+fi];
perf_board_offset_inside_base = 30;
perf_board_attachment_rails_height = 1.7;
perf_board_attachment_rails_width = 3.5;
perf_board_wall_thickness = 0.6;




display_offset_on_pcb = 6.5;
display_pcb_width = 38.2;
display_pcb_height = 13;
display_width = 29.5;
display_height = 11;
display_wall_thickness = 0.4;
cutouts_offset_from_ends_of_top = 5.5;

button_cutout_r = 1.8;
buttons_spacing = 10;
buttons_display_spacing = 6;
buttons_offset = cutouts_offset_from_ends_of_top+display_pcb_width+buttons_spacing/2+button_cutout_r+buttons_display_spacing;

display_cover_length = 20;
display_cover_slant_offset =6.5;
display_cover_wall_thickness = 2;
display_cover_width = buttons_offset+buttons_spacing/2+button_cutout_r+display_cover_wall_thickness*2+cutouts_offset_from_ends_of_top+display_offset_on_pcb;

display_cover_top_thickness = 2;

display_cover_cable_clearence_height = 2;
display_cover_cable_clearence_width = 7;

intersection(){
base(
    base_size_vec,
    load_plate_thickness_side,base_thickness_bottom,
    load_cell_attachment_top_x,load_cell_attachment_top_y,attachment_thickness,
    load_cell_length,
    perf_board_wall_thickness,perf_board_offset_inside_base,perf_board_size_vec,
    display_cover_width,base_attachment_screw_head_height
){
    screw_holes(
        load_cell_attachment_screw_spacing,
        base_attachment_screw_radious,
        base_attachment_screw_hole_depth
    );
    screw_holes(
        load_cell_attachment_screw_spacing,
        base_attachment_screw_head_radious+fi,
        base_attachment_screw_head_height+fi
    );

    perf_board_cutout(
        perf_board_size_vec,
        [[nano_usb_hole_offset_on_perf_board,5.5],[charger_usb_hole_offset_on_perf_board,5.9]],
        [[8,4.2],[8.2,3.1]]
    );
    perf_board_rails(perf_board_size_vec,[3.5,1.7]);

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
        display_wall_thickness,cutouts_offset_from_ends_of_top,
        display_offset_on_pcb,
        button_cutout_r,buttons_offset,buttons_spacing
    );
    cube([display_cover_cable_clearence_width,load_plate_thickness_side+fi*3,display_cover_cable_clearence_height],center= true);

    down(sack_layer_t)
    cube(size=[
        base_attachment_screw_head_radious*4+load_cell_attachment_screw_spacing,
        base_attachment_screw_head_radious*2,
        sack_layer_t
    ],center=true);
};
// translate([base_size_vec[0],base_size_vec[0]-42])
// cube([16,22,1000],center = true);
// cube([2000,250.01,100],center=true);
}


