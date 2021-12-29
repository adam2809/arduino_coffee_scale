
/*
 * Copyright (c) 2019, Gilles Bouissac
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * 
 * Description: Snap Joint tests
 * Author:      Gilles Bouissac
 */

use <agentscad/snap-joint.scad>

// ----------------------------------------
//    API
// ----------------------------------------

// part=0: mutiple parts at the same time in position
// part=1: same joints in printable position
// part=2: Just 4 circular joints for fast test print
//   cut/cut_rotation: cut position/rotation (ex:0) to see inside (undef for no cut)
// $fn:    Rendering precision
SMOOTH  = 100;
FAST    = 50;
LOWPOLY = 6;
showSnapJointParts ( part=1, cut=0, cut_rotation=undef, $fn=FAST );


// ----------------------------------------
//    Showcase
// ----------------------------------------

SHOW_ROTATE  = 0;
SHOW_ITV_V   = 10;
SHOW_ITV_H   = 30;
SHOW_TUBE_H  = 10;

module showSnapJointTube (joint) {
    width = getSnapJointRadialT(joint);
    difference() {
        cylinder ( r=getSnapJointR(joint)+width, h=SHOW_TUBE_H-getSnapJointVGap(joint));
        cylinder ( r=getSnapJointR(joint)-0.1, h=SHOW_TUBE_H-getSnapJointVGap(joint));
    }
}
module showSnapJoint (joint) {
    fn = getSnapJointIsPolygon(joint) ? getSnapJointLeaves(joint) : $fn ;
    rotate( [0,0,SHOW_ROTATE] ) {
        translate( [0,0,-getSnapJointH(joint)] )
            snapJoint( joint );
        translate( [0,0,getSnapJointIsInt(joint)?0:-SHOW_TUBE_H+getSnapJointHGap()] )
            rotate( [0,0,180/fn] )
            showSnapJointTube(joint, $fn=fn);
    }
}

module showSnapJointParts (part=0, sub_part=0, cut=undef, cut_rotation=undef) {
    r =10;

    joint_quad_i = newSnapPolygonInt (radius=r, leaves=4, springs=true );
    joint_quad_e = newSnapPolygonExt ( source=joint_quad_i );

    ext_h = 0;
    int_h = -SHOW_TUBE_H;
    if ( part==1 ) {
        linear_snap(r){
            showSnapJoint(joint_quad_e);
        }
        linear_snap(r){
            showSnapJoint(newSnapPolygonInt(radius=r, leaves=4, springs=true));
        }
    }
}
module linear_snap(r){
    translate([7,0.5,0.06])
    cutoff_snaps_support(){
        get_snap_cross_section(r){
            children(0);
        }
    }
}

module get_snap_cross_section(r){
    difference(){
        intersection(){
            children(0);
            translate([-r/2,0,0]) cube(size = [r,1,100],center = true);
        }
    }
}
module cutoff_snaps_support(){
    difference(){
        children(0);
        translate([-57,0,0])
        cube(100,center = true);
    }
}