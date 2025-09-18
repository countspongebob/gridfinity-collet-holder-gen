// Gridfinity Parametric Collet Holder - Flat Top Box Design
// Version 2.0 - Using proper Gridfinity base construction
// Based on gridfinity_extended_openscad

// ============= USER PARAMETERS =============
// Grid dimensions (in Gridfinity units, 1 unit = 42mm)
grid_x = 2; // [1:10]
grid_y = 2; // [1:10]

// Collet type selection
collet_type = "ER-20"; // ["ER-11", "ER-16", "ER-20", "ER-25", "ER-32", "ER-40", "5C", "R8"]

// Layout options
finger_clearance = 3; // [2:10] Additional space between holes (mm)
wall_thickness = 2; // [1.5:0.5:4] Minimum wall thickness between holes (mm)
holder_depth_ratio = 0.75; // [0.5:0.1:1.0] Depth as ratio of collet height

// Feature toggles
add_magnets = true; // Add magnet holes to base
add_chamfer = true; // Add chamfer to hole entries
add_labels = true; // Add labels

// ============= CONSTANTS =============
// Gridfinity dimensions
GF_PITCH = 42;
GF_CLEARANCE = 0.5;
GF_ZPITCH = 7;
GF_BASE_HEIGHT = 5;

// Cup/top dimensions
GF_CUP_CORNER_RADIUS = 3.75;
GF_WALL_THICKNESS = 1.2;
GF_LIP_HEIGHT = 0.8;
GF_LIP_WIDTH = 2.15;

// Bottom dimensions
GF_BOTTOM_CORNER_RADIUS = 1.6;
GF_BOTTOM_TAB_HEIGHT = 4.75;  // Standard Gridfinity tab depth (was 2.15)
GF_BOTTOM_TAB_WIDTH = 40.4;   // Width of the raised tab that fits into grid
GF_BOTTOM_SURFACE_HEIGHT = 0.8;

// Magnet specifications
MAGNET_DIAMETER = 6.5;
MAGNET_DEPTH = 2.4;

// ============= COLLET DATA =============
function get_collet_diameter(type) = 
    type == "ER-11" ? 11.5 :
    type == "ER-16" ? 17 :
    type == "ER-20" ? 21 :
    type == "ER-25" ? 26 :
    type == "ER-32" ? 33 :
    type == "ER-40" ? 41 :
    type == "5C" ? 26 :
    type == "R8" ? 20 : 21;

function get_collet_height(type) = 
    type == "ER-11" ? 28 :
    type == "ER-16" ? 30 :
    type == "ER-20" ? 32 :
    type == "ER-25" ? 34 :
    type == "ER-32" ? 40 :
    type == "ER-40" ? 46 :
    type == "5C" ? 100 :
    type == "R8" ? 40 : 35;

function get_collet_clearance(type) = 
    type == "ER-11" ? -2 :   // 11.5mm collet, 9.5mm hole
    type == "ER-16" ? -3 :   // 17mm collet, 14mm hole
    type == "ER-20" ? -3 :   // 21mm collet, 18mm hole
    type == "ER-25" ? -4 :   // 26mm collet, 22mm hole
    type == "ER-32" ? -5 :   // 33mm collet, 28mm hole
    type == "ER-40" ? -6 :   // 41mm collet, 35mm hole
    type == "5C" ? -4 :      // 26mm collet, 22mm hole
    type == "R8" ? -3 : -3;  // 20mm collet, 17mm hole

// ============= CALCULATED DIMENSIONS =============
// Base dimensions
base_width = grid_x * GF_PITCH - GF_CLEARANCE;
base_length = grid_y * GF_PITCH - GF_CLEARANCE;

// Collet dimensions
collet_dia = get_collet_diameter(collet_type);
collet_h = get_collet_height(collet_type);
collet_clear = get_collet_clearance(collet_type);

// Hole dimensions
hole_dia = collet_dia + collet_clear;  // This is the BOTTOM diameter
hole_depth = collet_h * holder_depth_ratio;

// Calculate TOP diameter based on 8-degree taper
taper_angle = 8;  // degrees
hole_top_dia = hole_dia + 2 * hole_depth * tan(taper_angle);

// Total height
total_height = GF_BASE_HEIGHT + hole_depth + 3;

// Grid layout calculations - use TOP diameter for spacing
// For larger collets, we may need to reduce spacing to fit reasonable number
min_wall = 1.5;  // Absolute minimum wall between holes
spacing = hole_top_dia + min_wall + finger_clearance;  // Use TOP diameter!
margin = 10;  // Edge margin
available_x = base_width - 2 * margin - hole_top_dia;  // Account for TOP diameter at edges
available_y = base_length - 2 * margin - hole_top_dia;

// Calculate how many holes can fit (including the first hole)
holes_x = max(1, 1 + floor(available_x / spacing));
holes_y = max(1, 1 + floor(available_y / spacing));

// If we're getting too few holes for the grid size, try tighter packing
if (holes_x * holes_y < grid_x * grid_y && finger_clearance > 0) {
    // Try with minimal spacing using TOP diameter
    tight_spacing = hole_top_dia + min_wall;
    holes_x = min(grid_x * 2, max(1, 1 + floor(available_x / tight_spacing)));
    holes_y = min(grid_y * 2, max(1, 1 + floor(available_y / tight_spacing)));
}

// Recalculate spacing to evenly distribute holes
actual_spacing_x = holes_x > 1 ? available_x / (holes_x - 1) : 0;
actual_spacing_y = holes_y > 1 ? available_y / (holes_y - 1) : 0;

// Starting positions
start_x = margin + hole_top_dia/2;  // Use TOP diameter for positioning
start_y = margin + hole_top_dia/2;

// Warning if spacing is too tight (check against TOP diameter)
actual_wall = min(actual_spacing_x, actual_spacing_y) - hole_top_dia;
if (actual_wall < min_wall && holes_x * holes_y > 1) {
    echo(str("WARNING: Wall thickness ", round(actual_wall*10)/10, "mm may be too thin!"));
}

// ============= MODULES =============

// Rounded square
module rounded_square(size, radius) {
    offset(r=radius) 
    offset(r=-radius) 
    square(size, center=true);
}

// Create the complete base with proper Gridfinity bottom
module gridfinity_base_proper() {
    difference() {
        union() {
            // Main base block
            linear_extrude(GF_BASE_HEIGHT)
            rounded_square([base_width, base_length], GF_CUP_CORNER_RADIUS);
            
            // Add individual solid TAPERED tabs for EACH grid unit
            for (gx = [0:grid_x-1]) {
                for (gy = [0:grid_y-1]) {
                    grid_pos_x = -base_width/2 + (gx + 0.5) * GF_PITCH - GF_CLEARANCE/2;
                    grid_pos_y = -base_length/2 + (gy + 0.5) * GF_PITCH - GF_CLEARANCE/2;
                    
                    // Tapered tab using hull to create angled sides
                    // Tab is WIDE where it connects to box, NARROW at the bottom
                    translate([grid_pos_x, grid_pos_y, 0])
                    hull() {
                        // Top of tab (WIDE - where it connects to the box at z=0)
                        translate([0, 0, -0.1])
                        linear_extrude(0.1)
                        rounded_square([GF_BOTTOM_TAB_WIDTH, GF_BOTTOM_TAB_WIDTH], 
                                     GF_BOTTOM_CORNER_RADIUS);  // Full size, no offset
                        
                        // Bottom of tab (NARROW - furthest from box at z=-2.15)
                        translate([0, 0, -GF_BOTTOM_TAB_HEIGHT])
                        linear_extrude(0.1)
                        offset(delta=-1.5)  // Reduce size by 1.5mm all around
                        rounded_square([GF_BOTTOM_TAB_WIDTH, GF_BOTTOM_TAB_WIDTH], 
                                     GF_BOTTOM_CORNER_RADIUS);
                    }
                }
            }
        }
        
        // Top stacking lip (recessed into top)
        translate([0, 0, GF_BASE_HEIGHT - GF_LIP_HEIGHT])
        linear_extrude(GF_LIP_HEIGHT + 0.1)
        rounded_square([base_width - 2*GF_LIP_WIDTH, 
                      base_length - 2*GF_LIP_WIDTH], 
                     GF_CUP_CORNER_RADIUS - GF_LIP_WIDTH);
        
        // Magnet holes
        if (add_magnets) {
            for (gx = [0:grid_x-1]) {
                for (gy = [0:grid_y-1]) {
                    grid_pos_x = -base_width/2 + (gx + 0.5) * GF_PITCH - GF_CLEARANCE/2;
                    grid_pos_y = -base_length/2 + (gy + 0.5) * GF_PITCH - GF_CLEARANCE/2;
                    
                    for (cx = [-1, 1]) {
                        for (cy = [-1, 1]) {
                            translate([grid_pos_x + cx*13.2, 
                                     grid_pos_y + cy*13.2, 
                                     GF_BASE_HEIGHT - MAGNET_DEPTH])
                            cylinder(d=MAGNET_DIAMETER, h=MAGNET_DEPTH + 0.1, $fn=24);
                        }
                    }
                }
            }
        }
    }
}

// Main body with holes
module main_body() {
    difference() {
        // Solid top section
        translate([0, 0, GF_BASE_HEIGHT])
        linear_extrude(total_height - GF_BASE_HEIGHT)
        rounded_square([base_width, base_length], GF_CUP_CORNER_RADIUS);
        
        // Collet holes with 8-degree taper
        for (i = [0:holes_x-1]) {
            for (j = [0:holes_y-1]) {
                translate([
                    -base_width/2 + start_x + i * actual_spacing_x,
                    -base_length/2 + start_y + j * actual_spacing_y,
                    total_height - hole_depth
                ]) {
                    // Tapered hole - 8 degree half angle (16 degree included)
                    // Bottom diameter is SMALLER, top diameter is LARGER
                    taper_angle = 8;  // degrees
                    bottom_dia = hole_dia;  // This is the narrow end
                    // Calculate top diameter based on taper angle
                    top_dia = bottom_dia + 2 * hole_depth * tan(taper_angle);
                    
                    cylinder(d1=bottom_dia, d2=top_dia, h=hole_depth, $fn=48);
                    
                    // Add extra clearance at the very top if chamfer enabled
                    if (add_chamfer) {
                        translate([0, 0, hole_depth - 1])
                        cylinder(d1=top_dia, d2=top_dia + 3, h=1.1, $fn=48);
                    }
                }
            }
        }
        
        // Label
        if (add_labels) {
            translate([0, -base_length/2 + 1, GF_BASE_HEIGHT + (total_height - GF_BASE_HEIGHT)/2])
            rotate([90, 0, 0])
            linear_extrude(2)
            text(str(collet_type, " x", holes_x * holes_y), 
                 size=5, halign="center", valign="center");
        }
    }
}

// ============= MAIN MODEL =============
module gridfinity_collet_holder() {
    gridfinity_base_proper();
    main_body();
}

// ============= RENDER =============
echo("=== Gridfinity Collet Holder ===");
echo(str("Grid: ", grid_x, "x", grid_y, " (", base_width, "x", base_length, " mm)"));
echo(str("Height: ", total_height, " mm"));
echo(str("Collet: ", collet_type, " (Ø", hole_dia, " mm)"));
echo(str("Holes: ", holes_x, "x", holes_y, " = ", holes_x * holes_y));
echo(str("Hole spacing: ", round(actual_spacing_x), "x", round(actual_spacing_y), " mm"));
echo(str("Bottom tabs: ", grid_x * grid_y, " (one per grid unit)"));

// Render
gridfinity_collet_holder();
