
def load_plate(
  side = 125.0,
  height = 12.0,
  wall_thickness = 2.4,
  top_thickness = 5.2,
  chamfer = 1.0,
  screw_spacing = 6,
  screw_diameter = 3.2,
  screw_hole_depth = 6,
  load_cell_length = 47,
  attachment_width = 12,
  attachment_thickness = 7,
  attachment_height = 7,
  attachment_spacing = 30
):
    chamfered_plate = (cq
      .Workplane("XY")
      .box(side, side, height).tag('just_box')
      .faces('<Z').workplane()
      .rect(side-wall_thickness*2,side-wall_thickness*2)
      .extrude(-(height-top_thickness),'cut')
      .edges('|Z or >Z',tag='just_box')
      .chamfer(chamfer)
      .faces('<Z[-2]').tag('inside_top_face')
    )

    attachment_point_x = (load_cell_length-attachment_thickness/2)/2
    attachment_point_right = (attachment_spacing/2,attachment_point_x,0)
    attachment_point_left = (-attachment_spacing/2,attachment_point_x,0)
    screws_right = (attachment_spacing/2,attachment_point_x)
    screws_left = (-attachment_spacing/2,attachment_point_x)
    with_attachments = (chamfered_plate
      .faces(tag='inside_top_face').workplane()
      .pushPoints([attachment_point_right,attachment_point_left])
      .box(attachment_width+attachment_height,
           attachment_thickness+attachment_height,
           attachment_height)
     #.faces('<X[2]').workplane()
     #.pushPoints([((attachment_thickness+attachment_height)/2,attachment_height/2)])
    )

    with_screw_holes = (with_attachments
      .faces('<Z[-2]')
      .translate((screw_spacing/2,0))
      .hole(screw_diameter,screw_spacing)
      .faces('<Z[-2]')
      .translate((-screw_spacing/2,0))
      .hole(screw_diameter,screw_spacing)
    )

    return with_screw_holes


lp = load_plate()
show_object(lp)
